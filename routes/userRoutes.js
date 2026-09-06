import express from "express";
import { getAllUsers, getUserById, createUser, updateUserById, deleteUserById } from "../controllers/userController.js";
import requireRole from "../middleware/requireRole.js";

const router = express.Router();

router.get("/", requireRole("admin"), getAllUsers);
router.get("/:id", requireRole("admin"), getUserById);
router.put("/:id", requireRole("admin"), updateUserById);
router.post("/", requireRole("admin"), createUser);
router.delete("/:id", requireRole("admin"), deleteUserById);

router.param("id", (req, res, next, id) => {
    const userId = parseInt(id, 10);
    if (isNaN(userId)) {
        return res.status(400).json({ message: "Invalid user ID format" });
    }
    req.params.id = userId;
    next();
});

export default router;
