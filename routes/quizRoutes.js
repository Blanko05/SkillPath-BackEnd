import express from "express";
import { submitQuiz, getQuizResponseById } from "../controllers/quizController.js";

const router = express.Router();

router.post("/", submitQuiz);
router.get("/:id", getQuizResponseById);

router.param("id", (req, res, next, id) => {
  if (!id.startsWith("qz_")) {
    return res.status(400).json({ message: "Invalid quiz response ID format" });
  }
  let quizId = id.replace("qz_", "");
  quizId = parseInt(quizId, 10);
  if (isNaN(quizId)) {
    return res.status(400).json({ message: "Invalid quiz response ID format" });
  }
  req.params.id = quizId;
  next();
});

export default router;
