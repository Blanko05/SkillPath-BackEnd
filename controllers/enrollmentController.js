import { pool } from "../config/db.js";
import formatId from "../utils/formatId.js";
import { fetchUserById } from "./userController.js";
import { fetchCourseById } from "./courseController.js";

const formatEnrollment = (enrollment) => {
  return {
    id: formatId("enr", enrollment.id),
    userId: enrollment.user_id,
    courseId: enrollment.course_id,
    enrolledAt: enrollment.enrolled_at,
  };
};
const extendEnrollment = async (enrollment) => {
  return {
    id: formatId("enr", enrollment.id),
    user: await fetchUserById(enrollment.user_id),
    course: await fetchCourseById(enrollment.course_id),
    enrolledAt: enrollment.enrolled_at,
  };
};
//@desc Get all enrollments
//@route GET /api/enrollments
export const getAllEnrollments = async (req, res, next) => {
  try {
    if (req.query.extended === "true") {
      const results = await pool.query("SELECT * FROM enrollments");
      const enrollments = await Promise.all(
        results.rows.map((enrollment) => extendEnrollment(enrollment)),
      );
      return res.status(200).json(enrollments);
    }

    const results = await pool.query("SELECT * FROM enrollments");
    res.status(200).json(results.rows.map(formatEnrollment));
  } catch (error) {
    next(error);
  }
};

//@desc Get enrollment by ID
//@route GET /api/enrollments/:id
export const getEnrollmentById = async (req, res, next) => {
  const enrollmentId = req.params.id;

  try {
    if (req.query.extended === "true") {
      const results = await pool.query(
        "SELECT * FROM enrollments WHERE id = $1",
        [enrollmentId],
      );
      if (results.rows.length === 0) {
        return res.status(404).json({ message: "Enrollment not found" });
      }
      const extendedEnrollment = await extendEnrollment(results.rows[0]);
      return res.status(200).json(extendedEnrollment);
    }

    const results = await pool.query(
      "SELECT * FROM enrollments WHERE id = $1",
      [enrollmentId],
    );
    if (results.rows.length === 0) {
      return res.status(404).json({ message: "Enrollment not found" });
    }
    res.status(200).json(formatEnrollment(results.rows[0]));
  } catch (error) {
    next(error);
  }
};

//@desc Create a new enrollment
//@route POST /api/enrollments
export const createEnrollment = async (req, res, next) => {
  try {
    const { userId, courseId } = req.body;

    // Check if the user exists
    const userResult = await pool.query(
      "SELECT * FROM users WHERE id = $1 AND role = $2",
      [userId, "student"],
    );
    if (userResult.rows.length === 0) {
      return res
        .status(400)
        .json({ message: "user not found or not a student" });
    }
    // Check if the course exists
    const courseResult = await pool.query(
      "SELECT * FROM courses WHERE id = $1",
      [courseId],
    );
    if (courseResult.rows.length === 0) {
      return res.status(400).json({ message: "Course not found" });
    }
    //check if exisiting enrollment exists
    const enrollmentResult = await pool.query(
      "SELECT * FROM enrollments WHERE user_id = $1 AND course_id = $2",
      [userId, courseId],
    );
    //if it exists
    if (enrollmentResult.rows.length !== 0) {
      return res
        .status(400)
        .json({ message: "User already enrolled in this course!" });
    }

    const results = await pool.query(
      "INSERT INTO enrollments (user_id, course_id) VALUES ($1, $2) RETURNING *",
      [userId, courseId],
    );
    res.status(201).json(formatEnrollment(results.rows[0]));
  } catch (error) {
    next(error);
  }
};

//@desc Delete enrollment by ID
//@route DELETE /api/enrollments/:id
export const deleteEnrollmentById = async (req, res, next) => {
  const enrollmentId = req.params.id;
  try {
    const existingEnrollment = await pool.query(
      "SELECT * FROM enrollments WHERE id = $1",
      [enrollmentId],
    );
    if (existingEnrollment.rows.length === 0) {
      return res.status(404).json({ message: "Enrollment not found" });
    }
    const results = await pool.query(
      "DELETE FROM enrollments WHERE id = $1 RETURNING *",
      [enrollmentId],
    );
    res.status(200).json({ message: "Enrollment deleted successfully" });
  } catch (error) {
    next(error);
  }
};
