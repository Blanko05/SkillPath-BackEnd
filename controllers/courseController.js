import {pool} from '../config/db.js'

const formatCourse = (course) => {
    return {
        id: course.id,
        title: course.title,
        description: course.description,
        content: course.content,
        category: course.category,
        skillLevel: course.skill_level,
        durationHours: course.duration_hours,
        status: course.status,
        createdAt: course.created_at,
        manager: {
            id: course.manager_id,
            name: course.manager_name
        }
    };
};

export const fetchCourseById = async (courseId) => {
    const result = await pool.query('SELECT c.id, c.title, c.description, c.content, c.category, c.skill_level, c.duration_hours, c.status, c.created_at, u.id AS manager_id, u.name AS manager_name FROM courses c inner join users u on c.manager_id = u.id WHERE c.id = $1', [courseId]);
    if (result.rows.length === 0) {
        return null;
    }
    return formatCourse(result.rows[0]);
};

//@desc Get all courses
//@route GET /api/courses
export const getAllCourses = async (req, res, next) => {
  try {
    const results = await pool.query('SELECT c.id, c.title, c.description, c.category, c.skill_level, c.duration_hours, c.status, c.created_at, u.id AS manager_id, u.name AS manager_name FROM courses c inner join users u on c.manager_id = u.id ');
    res.status(200).json(results.rows.map(formatCourse));
  } catch (error) {
    next(error);
  }
};

//@desc Get course by ID
//@route GET /api/courses/:id
export const getCourseById = async (req, res, next) => {
    const courseId = req.params.id;
    try {
        const course = await fetchCourseById(courseId);
        if (!course) {
            return res.status(404).json({ message: "Course not found" });
        }
        res.status(200).json(course);
    } catch (error) {
        next(error);
    }
};

//@desc Create a new course, owned by the requesting manager
//@route POST /api/courses
export const createCourse = async (req, res, next) => {
    // The creating manager always owns the course - managerId is never taken
    // from the body, only from the trusted-client x-user-id header.
    const managerId = parseInt(req.headers['x-user-id'], 10);
    const { title, description, content, category, skillLevel, durationHours, status } = req.body;
    try {
        const existingManager = await pool.query('SELECT * FROM users WHERE id = $1', [managerId]);
        if (existingManager.rows.length === 0) {
            return res.status(404).json({ message: `Manager with ID ${managerId} not found` });
        }
        const result = await pool.query(
            'INSERT INTO courses (title, description, content, category, skill_level, duration_hours, status, manager_id) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id',
            [title, description, content, category, skillLevel, durationHours, status, managerId]);
        const newCourse = await fetchCourseById(result.rows[0].id);
        res.status(201).json(newCourse);
    } catch (error) {
        next(error);
    }
};
//@desc Update a course's own content - the owning manager only, manager_id can't change here
//@route PUT /api/courses/:id
export const updateCourseById = async (req, res, next) => {
    const courseId = req.params.id;
    const requesterId = parseInt(req.headers['x-user-id'], 10);
    const { title, description, content, category, skillLevel, durationHours, status } = req.body;
    try {
        const existingCourse = await pool.query('SELECT * FROM courses WHERE id = $1', [courseId]);
        if (existingCourse.rows.length === 0) {
            return res.status(404).json({ message: `Course with ID ${courseId} not found` });
        }
        if (existingCourse.rows[0].manager_id !== requesterId) {
            return res.status(403).json({ message: "You can only edit your own courses" });
        }
        const result = await pool.query(
            'UPDATE courses SET title = $1, description = $2, content = $3, category = $4, skill_level = $5, duration_hours = $6, status = $7 WHERE id = $8 RETURNING id',
            [title, description, content, category, skillLevel, durationHours, status, courseId]);
        const updatedCourse = await fetchCourseById(result.rows[0].id);
        res.status(200).json(updatedCourse);
    } catch (error) {
        next(error);
    }
};

//@desc Delete a course by ID - the owning manager only
//@route DELETE /api/courses/:id
export const deleteCourseById = async (req, res, next) => {
    const courseId = req.params.id;
    const requesterId = parseInt(req.headers['x-user-id'], 10);
    try {
        const existingCourse = await pool.query('SELECT * FROM courses WHERE id = $1', [courseId]);
        if (existingCourse.rows.length === 0) {
            return res.status(404).json({ message: `Course with ID ${courseId} not found` });
        }
        if (existingCourse.rows[0].manager_id !== requesterId) {
            return res.status(403).json({ message: "You can only delete your own courses" });
        }
        await pool.query('DELETE FROM courses WHERE id = $1', [courseId]);
        res.status(200).json({ message: `Course with ID ${courseId} deleted successfully` });
    } catch (error) {
        next(error);
    }
};

//@desc Reassign which manager owns a course - admin-only carve-out, no other field changes here
//@route PUT /api/courses/:id/manager
export const reassignCourseManager = async (req, res, next) => {
    const courseId = req.params.id;
    const { managerId } = req.body;
    try {
        const existingCourse = await pool.query('SELECT * FROM courses WHERE id = $1', [courseId]);
        if (existingCourse.rows.length === 0) {
            return res.status(404).json({ message: `Course with ID ${courseId} not found` });
        }
        const existingManager = await pool.query("SELECT * FROM users WHERE id = $1 AND role = 'manager'", [managerId]);
        if (existingManager.rows.length === 0) {
            return res.status(404).json({ message: `Manager with ID ${managerId} not found` });
        }
        const result = await pool.query(
            'UPDATE courses SET manager_id = $1 WHERE id = $2 RETURNING id',
            [managerId, courseId]);
        const updatedCourse = await fetchCourseById(result.rows[0].id);
        res.status(200).json(updatedCourse);
    } catch (error) {
        next(error);
    }
};

