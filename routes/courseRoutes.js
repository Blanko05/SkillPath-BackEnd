import express from "express";
import { getAllCourses, getCourseById, createCourse, updateCourseById, deleteCourseById, reassignCourseManager } from "../controllers/courseController.js";
import requireRole from "../middleware/requireRole.js";

const router = express.Router();

router.get("/", getAllCourses);
router.get("/:id", getCourseById);
router.post("/", requireRole("manager"), createCourse);
router.put("/:id", requireRole("manager"), updateCourseById);
router.delete("/:id", requireRole("manager"), deleteCourseById);
router.put("/:id/manager", requireRole("admin"), reassignCourseManager);

router.param("id", (req, res, next, id) => {
    const courseId = parseInt(id, 10);
    if (isNaN(courseId)) {
        return res.status(400).json({ message: "Invalid course ID format" });
    }
    req.params.id = courseId;
    next();
});

export default router;
