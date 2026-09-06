# ⚙️ SkillPath Backend (Express + PostgreSQL)

This is the **backend** for SkillPath. It provides APIs for authentication, users, courses, enrollments, and AI-powered quiz recommendations.

## 🏗️ Tech Stack

- Node.js + Express
- PostgreSQL (via `pg`)
- OpenAI SDK (course recommendations)
- `dotenv`, `cors`

## 🚀 Getting Started

```bash
# 1. Install dependencies
cd BackEnd
npm install

# 2. Create a PostgreSQL database (e.g. `SkillPathDB`)

# 3. Configure environment variables - copy .env.sample to .env and fill in
#    your DB credentials and OpenAI API key

# 4. Create the tables (safe to re-run - IF NOT EXISTS everywhere)
psql -d SkillPathDB -f db/schema.sql

# 5. Seed the database (safe to re-run any time - it truncates and reseeds)
psql -d SkillPathDB -f db/seed.sql

# 6. Start the server
npm start
```

The API runs at `http://localhost:5000`. All seeded users share the password `password123` (see `db/seed.sql` for the full list of accounts and roles).

## 📁 Project Structure

```text
BackEnd/
├── config/
│   ├── db.js              # PostgreSQL connection pool
│   └── openai.js          # OpenAI client
├── controllers/
│   ├── authController.js       # signup & login
│   ├── userController.js       # user CRUD
│   ├── courseController.js     # course CRUD + manager reassignment
│   ├── enrollmentController.js # enrollment CRUD
│   └── quizController.js       # quiz submission + AI recommendations
├── middleware/
│   ├── requireRole.js     # role-based route guard
│   └── error.js           # centralized error handler
├── routes/
│   ├── authRoutes.js
│   ├── userRoutes.js
│   ├── courseRoutes.js
│   ├── enrollmentRoutes.js
│   └── quizRoutes.js
├── db/
│   ├── schema.sql          # table definitions, constraints, indexes
│   └── seed.sql            # full reseed script
└── server.js               # app entry point
```

## 🔐 Authentication & Authorization

This app does **not** use JWTs or password hashing - both by design, matching the course's specified auth pattern rather than production practice:

- Passwords are stored and compared as plaintext.
- There is no token. After login, the client just holds the returned user object and, on every subsequent request, sends two headers that the server trusts outright with no verification:

| Header | Meaning |
| --- | --- |
| `x-role` | The user's role (`student`, `manager`, or `admin`) |
| `x-user-id` | The user's id |

Routes that require a specific role check `x-role` via the `requireRole` middleware; routes scoped to "your own" resource (e.g. a manager editing their own course) additionally compare `x-user-id` against the resource's owner. Since none of this is signed or verified against the database, it's trivially spoofable from the browser console - acceptable for this assignment's purposes, not for production.

## 📡 API Endpoints

Base URL: `http://localhost:5000/api`

### 🔓 Auth Routes

**Base URL**: `/api/auth` &middot; no headers required

| Method | Endpoint | Description |
| --- | --- | --- |
| POST | `/signup` | Register a new user (always created as `student`) |
| POST | `/login` | Log in with email + password |

#### 🔶 POST `/api/auth/signup`

```json
{
  "name": "Sara Khaled",
  "email": "sara@example.com",
  "password": "password123"
}
```

Returns `201` with `{ "user": { "id", "name", "email", "role", "createdAt" } }` (password never included in the response). `role` is always `student`, regardless of what's sent.

#### 🔶 POST `/api/auth/login`

```json
{
  "email": "sara@example.com",
  "password": "password123"
}
```

Returns `200` with `{ "user": { ... } }` on success, `401` on a bad email/password.

### 👤 User Routes

**Base URL**: `/api/users` &middot; every route requires `x-role: admin`

| Method | Endpoint | Description |
| --- | --- | --- |
| GET | `/` | List all users |
| GET | `/:id` | Get one user |
| POST | `/` | Create a user (any role) |
| PUT | `/:id` | Update a user's name/email/role |
| DELETE | `/:id` | Delete a user |

#### 🔶 POST `/api/users`

```json
{
  "name": "Fatima Zahra",
  "email": "fatima@skillpath.com",
  "role": "manager",
  "password": "password123"
}
```

#### 🔶 PUT `/api/users/:id`

```json
{
  "name": "Fatima Zahra",
  "email": "fatima@skillpath.com",
  "role": "admin"
}
```

`password` is optional here - omit it to keep the user's existing password. Deleting a user with role `student` cascades to their enrollments and quiz history; deleting a `manager` who still owns courses is blocked with a `400` until those courses are reassigned or deleted.

### 📖 Course Routes

**Base URL**: `/api/courses`

| Method | Endpoint | Auth | Description |
| --- | --- | --- | --- |
| GET | `/` | none | List all courses |
| GET | `/:id` | none | Get one course |
| POST | `/` | `x-role: manager` | Create a course (owned by `x-user-id`) |
| PUT | `/:id` | `x-role: manager`, must own the course | Edit a course's own content |
| DELETE | `/:id` | `x-role: manager`, must own the course | Delete a course |
| PUT | `/:id/manager` | `x-role: admin` | Reassign the course to a different manager |

#### 🔶 POST `/api/courses`

```json
{
  "title": "Intro to SQL",
  "description": "Learn the fundamentals of relational databases and SQL queries.",
  "content": "The longer write-up shown on the course detail page...",
  "category": "Databases",
  "skillLevel": "beginner",
  "durationHours": 24,
  "status": "published"
}
```

`managerId` is never taken from the body - the course is always owned by whoever's `x-user-id` sent the request. `PUT /api/courses/:id` takes the same body shape (minus ownership, which can't change via this route).

#### 🔶 PUT `/api/courses/:id/manager`

```json
{
  "managerId": 3
}
```

Admin-only carve-out - changes which manager owns the course and nothing else about it.

### 🎓 Enrollment Routes

**Base URL**: `/api/enrollments`

| Method | Endpoint | Auth | Description |
| --- | --- | --- | --- |
| GET | `/` | none | List all enrollments (add `?extended=true` for nested user/course objects) |
| GET | `/:id` | none | Get one enrollment |
| POST | `/` | `x-role: student` | Enroll in a course |
| DELETE | `/:id` | `x-role: student` | Unenroll |

#### 🔶 POST `/api/enrollments`

```json
{
  "userId": 6,
  "courseId": 1
}
```

Rejects with `400` if the user isn't a student, the course doesn't exist, or the enrollment already exists.

### 🧠 Quiz Routes

**Base URL**: `/api/quiz`

| Method | Endpoint | Auth | Description |
| --- | --- | --- | --- |
| POST | `/` | `x-role: student` | Submit quiz answers, get AI-ranked recommendations |
| GET | `/?userId=X` | none | List a student's past quiz submissions |
| GET | `/:id` | none | Get one past quiz result (cached - no new AI call) |

#### 🔶 POST `/api/quiz`

```json
{
  "userId": 6,
  "skillLevel": "beginner",
  "timeAvailability": "5-10 hours/week",
  "goals": ["backend development", "databases"],
  "freeTextPrompt": "I want to get better at building APIs"
}
```

This is the only endpoint that calls OpenAI - it scores every currently published course against the answers using Structured Outputs (an `enum`-constrained schema, so the model can only return course ids that actually exist and are published) and saves the result. `GET /api/quiz/:id` and `GET /api/quiz?userId=X` are both pure reads afterward and never trigger another AI call.
