import express from "express";
import { getAllCourses, getCourseById, createCourse, updateCourseById, deleteCourseById } from "../controllers/courseController.js";

const router = express.Router();

router.get("/", getAllCourses);
router.get("/:id", getCourseById);
router.put("/:id", updateCourseById);
router.post("/", createCourse);
router.delete("/:id", deleteCourseById);

router.param("id", (req, res, next, id) => {
    if(!id.startsWith('crs_')) {
        return res.status(400).json({ message: "Invalid course ID format" });
    }
    let courseId = id.replace('crs_', '');
    courseId = parseInt(courseId, 10);
    if(isNaN(courseId)) {
        return res.status(400).json({ message: "Invalid course ID format" });
    }
    req.params.id = courseId;
    next();
});

export default router;