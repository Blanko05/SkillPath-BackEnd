import express from "express";
import { getAllEnrollments, getEnrollmentById, createEnrollment, deleteEnrollmentById } from "../controllers/enrollmentController.js";

const router = express.Router();

router.get("/", getAllEnrollments);
router.get("/:id", getEnrollmentById);
router.post("/", createEnrollment);
router.delete("/:id", deleteEnrollmentById);

router.param("id", (req, res, next, id) => {
    if(!id.startsWith('enr_')) {
        return res.status(400).json({ message: "Invalid enrollment ID format" });
    }
    let enrollmentId = id.replace('enr_', '');
    enrollmentId = parseInt(enrollmentId, 10);
    if(isNaN(enrollmentId)) {
        return res.status(400).json({ message: "Invalid enrollment ID format" });
    }
    req.params.id = enrollmentId;
    next();
});

export default router;