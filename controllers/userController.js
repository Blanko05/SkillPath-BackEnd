import {pool} from '../config/db.js'
import formatId from '../utils/formatId.js'

function formatUser(user) {
  return {
    id: formatId('usr', user.id),
    name: user.name,
    email: user.email,
    role: user.role,
    createdAt: user.created_at
  };
}
export const fetchUserById = async (userId) => {
  const result = await pool.query('SELECT id, name, email, role, created_at FROM users WHERE id = $1', [userId]);
    if (result.rows.length === 0) {
        return null;
    }
    return formatUser(result.rows[0]);
}

//@desc Get all users
//@route GET /api/users
export const getAllUsers = async (req, res, next) => {
  try {
    const results = await pool.query('SELECT id, name, email, role, created_at FROM users');

    const formattedResults = results.rows.map((user) => (formatUser(user)));

    res.status(200).json(formattedResults);
  } catch (error) {
    return next(error);
  }
};

//@desc Get user by ID
//@route GET /api/users/:id
export const getUserById = async (req, res, next) => {
  const userId = req.params.id;
  try {
    const result = await pool.query('SELECT id, name, email, role, created_at FROM users WHERE id = $1', [userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: `User with ID ${req.params.id} not found`});
    }
    const user = result.rows[0];
    const formattedUser = formatUser(user);
    res.status(200).json(formattedUser);
    console.log('User fetched:', formattedUser);
  } catch (error) {
    return next(error);
  }
};

//desc Post new user
//route POST /api/users
export const createUser = async (req, res, next) => {
  const { name, email, role, password } = req.body;
  try {
    // Check if the user already exists
    const existingUser = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
    if (existingUser.rows.length > 0) {
        return res.status(400).json({ message: `User with email ${email} already exists` });
    }
    const passwordhash = password; // In a real application, you should hash the password before storing it

    const result = await pool.query(
      'INSERT INTO users (name, email, password_hash, role) VALUES ($1, $2, $3, $4) RETURNING id, name, email, password_hash, role, created_at',
      [name, email, passwordhash, role]
    );
    const user = result.rows[0];
    const formattedUser = formatUser(user);
    res.status(201).json(formattedUser);
    console.log('User created:', formattedUser);
  } catch (error) {
    return next(error);
  }
};

//@desc Update user by ID
//@route PUT /api/users/:id
export const updateUserById = async (req, res, next) => {
  const userId = req.params.id;
  const { name, email, role, password } = req.body;
  try {
    const existingUser = await pool.query('SELECT id FROM users WHERE id = $1', [userId]);
    if (existingUser.rows.length === 0) {
      return res.status(404).json({ message: `User with ID ${userId} not found` });
    }
    const passwordhash = password; // In a real application, you should hash the password before storing it
    const result = await pool.query(
      'UPDATE users SET name = $1, email = $2, password_hash = $3, role = $4 WHERE id = $5 RETURNING id, name, email, password_hash, role, created_at',
      [name, email, passwordhash, role, userId]
    );
    const user = result.rows[0];
    const formattedUser = formatUser(user);
    res.status(200).json(formattedUser);
    console.log('User updated:', formattedUser);
  } catch (error) {
    return next(error);
  }
};

//@desc Delete user by ID
//@route DELETE /api/users/:id
export const deleteUserById = async (req, res, next) => {
    const userId = req.params.id;
    try {
      const existingUser = await pool.query('SELECT id FROM users WHERE id = $1', [userId]);
        if (existingUser.rows.length === 0) {
            return res.status(404).json({ message: `User with ID ${userId} not found` });
        }
        await pool.query('DELETE FROM users WHERE id = $1', [userId]);
        res.status(200).json({ message: `User with ID ${userId} deleted successfully` });
        console.log(`User with ID ${userId} deleted successfully`);
    } catch (error) {
        return next(error);
    }
}
