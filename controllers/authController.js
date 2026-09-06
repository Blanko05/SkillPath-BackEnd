import { pool } from "../config/db.js";

function formatAuthUser(user) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
    createdAt: user.created_at,
  };
}

//@desc Register a new student account
//@route POST /api/auth/signup
export const registerUser = async (req, res, next) => {
  const { name, email, password } = req.body;
  try {
    const existing = await pool.query("SELECT id FROM users WHERE email = $1", [email]);
    if (existing.rows.length > 0) {
      return res.status(400).json({ message: "User already exists" });
    }

    // Public signup always creates a student - role escalation only happens
    // through the admin's user management, never trusted from this request.
    const result = await pool.query(
      "INSERT INTO users (name, email, password_hash, role) VALUES ($1, $2, $3, $4) RETURNING id, name, email, role, created_at",
      [name, email, password, "student"],
    );
    res.status(201).json({ user: formatAuthUser(result.rows[0]) });
  } catch (error) {
    next(error);
  }
};

//@desc Log in with email + password
//@route POST /api/auth/login
export const loginUser = async (req, res, next) => {
  const { email, password } = req.body;
  try {
    const result = await pool.query(
      "SELECT id, name, email, role, created_at FROM users WHERE email = $1 AND password_hash = $2",
      [email, password],
    );
    if (result.rows.length === 0) {
      return res.status(401).json({ message: "Invalid credentials" });
    }
    res.json({ user: formatAuthUser(result.rows[0]) });
  } catch (error) {
    next(error);
  }
};
