import express from "express";
import { submitQuiz, getQuizResponseById, getQuizResponsesByUser } from "../controllers/quizController.js";
import requireRole from "../middleware/requireRole.js";

const router = express.Router();

router.post("/", requireRole("student"), submitQuiz);
router.get("/", getQuizResponsesByUser);
router.get("/:id", getQuizResponseById);

router.param("id", (req, res, next, id) => {
  const quizId = parseInt(id, 10);
  if (isNaN(quizId)) {
    return res.status(400).json({ message: "Invalid quiz response ID format" });
  }
  req.params.id = quizId;
  next();
});

export default router;
