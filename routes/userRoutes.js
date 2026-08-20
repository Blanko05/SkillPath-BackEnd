import express from "express";
import { getAllUsers, getUserById, createUser, updateUserById, deleteUserById } from "../controllers/userController.js";

const router = express.Router();

router.get("/", getAllUsers);
router.get("/:id", getUserById);
router.put("/:id", updateUserById);
router.post("/", createUser);
router.delete("/:id", deleteUserById);

router.param("id", (req, res, next, id) => {
    if(!id.startsWith('usr_')) {
        return res.status(400).json({ message: "Invalid user ID format" });
    }
    let userId = id.replace('usr_', '');
    userId = parseInt(userId, 10);
    if(isNaN(userId)) {
        return res.status(400).json({ message: "Invalid user ID format" });
    }
    req.params.id = userId;
    next();
});

export default router;