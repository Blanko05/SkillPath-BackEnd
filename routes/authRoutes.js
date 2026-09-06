import express from "express";
import { registerUser, loginUser } from "../controllers/authController.js";

const router = express.Router();

// localhost:5000/api/auth/signup
// body >> { name, email, password }
router.post("/signup", registerUser);

// localhost:5000/api/auth/login
// body >> { email, password }
router.post("/login", loginUser);

export default router;
