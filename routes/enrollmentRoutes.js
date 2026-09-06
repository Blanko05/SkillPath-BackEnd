import express from "express";
import { getAllEnrollments, getEnrollmentById, createEnrollment, deleteEnrollmentById } from "../controllers/enrollmentController.js";
import requireRole from "../middleware/requireRole.js";

const router = express.Router();

router.get("/", getAllEnrollments);
router.get("/:id", getEnrollmentById);
router.post("/", requireRole("student"), createEnrollment);
router.delete("/:id", requireRole("student"), deleteEnrollmentById);

router.param("id", (req, res, next, id) => {
    const enrollmentId = parseInt(id, 10);
    if (isNaN(enrollmentId)) {
        return res.status(400).json({ message: "Invalid enrollment ID format" });
    }
    req.params.id = enrollmentId;
    next();
});

export default router;
