import express from "express";
import { registerUser, loginUser } from "../controllers/authController.js";

const router = express.Router();

router.post("/", registerUser);
router.post("/:id", loginUser);

export default router;
