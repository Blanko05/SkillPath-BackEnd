import {Pool} from 'pg';
import dotenv from 'dotenv';

dotenv.config();

// DATABASE_URL (a single connection string, e.g. from Neon/Render) takes
// priority when set - it needs ssl since those hosts require it. Local dev
// keeps using the separate DB_* vars against a local Postgres with no ssl.
export const pool = process.env.DATABASE_URL
  ? new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false },
    })
  : new Pool({
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      database: process.env.DB_NAME
    });

const connectDB = async () => {

  try {
    await pool.query('SELECT NOW()');
    console.log('Connected to PostgreSQL database');
  } catch (error) {
    console.error('Error connecting to PostgreSQL database:', error);
  }
};

export default connectDB;