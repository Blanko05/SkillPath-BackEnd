import { pool } from "../config/db.js";
import openai from "../config/openai.js";
import { fetchCourseById } from "./courseController.js";

const MODEL = process.env.OPENAI_MODEL || "gpt-4o-mini";

function buildRecommendationSchema(courseIds) {
  return {
    name: "course_recommendations",
    strict: true,
    schema: {
      type: "object",
      properties: {
        recommendations: {
          type: "array",
          items: {
            type: "object",
            properties: {
              // enum constrains the model to only ids that actually exist and
              // are published - it cannot emit an id outside this list
              courseId: { type: "integer", enum: courseIds },
              rationale: { type: "string" },
            },
            required: ["courseId", "rationale"],
            additionalProperties: false,
          },
        },
      },
      required: ["recommendations"],
      additionalProperties: false,
    },
  };
}

async function fetchPublishedCourses() {
  const result = await pool.query(
    "SELECT id, title, description, category, skill_level, duration_hours FROM courses WHERE status = 'published'",
  );
  return result.rows;
}

function buildPrompt(quizAnswers, courses) {
  const courseList = courses
    .map(
      (c) =>
        `- id: ${c.id}, title: "${c.title}", category: ${c.category}, skillLevel: ${c.skill_level}, durationHours: ${c.duration_hours}, description: ${c.description}`,
    )
    .join("\n");

  return `Student quiz answers:
- Skill level: ${quizAnswers.skillLevel}
- Time availability: ${quizAnswers.timeAvailability}
- Goals: ${quizAnswers.goals.join(", ") || "none provided"}
- Additional context: ${quizAnswers.freeTextPrompt || "none provided"}

Available published courses:
${courseList}

Recommend the top 3 courses from the list above for this student. List them in order, best fit first. For each, give a short (1-2 sentence) rationale tied to the student's answers.`;
}

//@desc Submit quiz answers and get AI-ranked course recommendations
//@route POST /api/quiz
export const submitQuiz = async (req, res, next) => {
  try {
    const { userId, skillLevel, timeAvailability, goals, freeTextPrompt } =
      req.body;

    if (!userId || !skillLevel || !timeAvailability || !goals) {
      return res.status(400).json({
        message: "userId, skillLevel, timeAvailability, and goals are required",
      });
    }

    const userResult = await pool.query(
      "SELECT * FROM users WHERE id = $1 AND role = $2",
      [userId, "student"],
    );
    if (userResult.rows.length === 0) {
      return res
        .status(400)
        .json({ message: "User not found or not a student" });
    }

    const courses = await fetchPublishedCourses();
    if (courses.length === 0) {
      return res
        .status(503)
        .json({ message: "No published courses available to recommend" });
    }

    const prompt = buildPrompt(
      { skillLevel, timeAvailability, goals, freeTextPrompt },
      courses,
    );

    let recommendations;
    try {
      const completion = await openai.chat.completions.create({
        model: MODEL,
        messages: [
          {
            role: "system",
            content:
              "You are a course recommendation engine for SkillPath, an online learning platform. Recommend courses strictly from the provided list.",
          },
          { role: "user", content: prompt },
        ],
        response_format: {
          type: "json_schema",
          json_schema: buildRecommendationSchema(courses.map((c) => c.id)),
        },
      });
      recommendations = JSON.parse(
        completion.choices[0].message.content,
      ).recommendations;
    } catch (aiError) {
      console.error("OpenAI request failed:", aiError.message);
      return res.status(502).json({
        message:
          "AI recommendation service is currently unavailable. Please try again.",
      });
    }

    if (!recommendations || recommendations.length === 0) {
      return res.status(502).json({
        message: "AI did not return any recommendations. Please try again.",
      });
    }

    const quizInsert = await pool.query(
      "INSERT INTO quiz_responses (user_id, skill_level, time_availability, goals, free_text_prompt) VALUES ($1, $2, $3, $4, $5) RETURNING id",
      [userId, skillLevel, timeAvailability, goals, freeTextPrompt || null],
    );
    const quizResponseId = quizInsert.rows[0].id;

    const savedRecommendations = [];
    for (let i = 0; i < recommendations.length; i++) {
      const rec = recommendations[i];
      const result = await pool.query(
        "INSERT INTO recommendations (quiz_response_id, course_id, rank, ai_rationale) VALUES ($1, $2, $3, $4) RETURNING *",
        [quizResponseId, rec.courseId, i + 1, rec.rationale],
      );
      savedRecommendations.push(result.rows[0]);
    }

    const formattedRecommendations = await Promise.all(
      savedRecommendations.map(async (rec) => ({
        rank: rec.rank,
        course: await fetchCourseById(rec.course_id),
        aiRationale: rec.ai_rationale,
      })),
    );

    res.status(201).json({
      quizResponseId: quizResponseId,
      recommendations: formattedRecommendations,
    });
  } catch (error) {
    next(error);
  }
};

//@desc List a user's past quiz submissions and their recommendations
//@route GET /api/quiz?userId=X
export const getQuizResponsesByUser = async (req, res, next) => {
  const userId = req.query.userId;
  if (!userId) {
    return res.status(400).json({ message: "userId query parameter is required" });
  }
  try {
    const quizResult = await pool.query(
      "SELECT id, created_at FROM quiz_responses WHERE user_id = $1 ORDER BY created_at DESC",
      [userId],
    );

    const results = await Promise.all(
      quizResult.rows.map(async (quiz) => {
        const recResult = await pool.query(
          "SELECT * FROM recommendations WHERE quiz_response_id = $1 ORDER BY rank ASC",
          [quiz.id],
        );
        const recommendations = await Promise.all(
          recResult.rows.map(async (rec) => ({
            rank: rec.rank,
            course: await fetchCourseById(rec.course_id),
            aiRationale: rec.ai_rationale,
          })),
        );
        return {
          quizResponseId: quiz.id,
          createdAt: quiz.created_at,
          recommendations,
        };
      }),
    );

    res.status(200).json(results);
  } catch (error) {
    next(error);
  }
};

//@desc Get a previously saved quiz response and its recommendations (no new AI call)
//@route GET /api/quiz/:id
export const getQuizResponseById = async (req, res, next) => {
  const quizResponseId = req.params.id;
  try {
    const quizResult = await pool.query(
      "SELECT id FROM quiz_responses WHERE id = $1",
      [quizResponseId],
    );
    if (quizResult.rows.length === 0) {
      return res.status(404).json({ message: "Quiz response not found" });
    }

    const recResult = await pool.query(
      "SELECT * FROM recommendations WHERE quiz_response_id = $1 ORDER BY rank ASC",
      [quizResponseId],
    );

    const formattedRecommendations = await Promise.all(
      recResult.rows.map(async (rec) => ({
        rank: rec.rank,
        course: await fetchCourseById(rec.course_id),
        aiRationale: rec.ai_rationale,
      })),
    );

    res.status(200).json({
      quizResponseId: quizResponseId,
      recommendations: formattedRecommendations,
    });
  } catch (error) {
    next(error);
  }
};
