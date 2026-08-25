-- SkillPath seed data: a larger, coherent dataset for demo purposes.
-- Wipes existing rows in these 5 tables and resets id sequences back to 1.
-- Run with: psql -d SkillPathDB -f db/seed.sql   (or paste into pgAdmin's Query tool)

TRUNCATE TABLE recommendations, quiz_responses, enrollments, courses, users
  RESTART IDENTITY CASCADE;

-- ===== Users =====
INSERT INTO users (name, email, password_hash, role) VALUES
    ('Admin User', 'admin@skillpath.com', 'placeholder_hash', 'admin'),
    ('Omar Nasser', 'omar@skillpath.com', 'placeholder_hash', 'manager'),
    ('Layla Hassan', 'layla@skillpath.com', 'placeholder_hash', 'manager'),
    ('Fatima Zahra', 'fatima@skillpath.com', 'placeholder_hash', 'manager'),
    ('Kareem Fahad', 'kareem@skillpath.com', 'placeholder_hash', 'manager'),
    ('Sara Khaled', 'sara@example.com', 'placeholder_hash', 'student'),
    ('Yousef Ali', 'yousef@example.com', 'placeholder_hash', 'student'),
    ('Maya Odeh', 'maya@example.com', 'placeholder_hash', 'student'),
    ('Ali Hamdan', 'ali@example.com', 'placeholder_hash', 'student'),
    ('Noor Saleh', 'noor@example.com', 'placeholder_hash', 'student'),
    ('Tariq Younis', 'tariq@example.com', 'placeholder_hash', 'student'),
    ('Rana Aziz', 'rana@example.com', 'placeholder_hash', 'student'),
    ('Hassan Khoury', 'hassan@example.com', 'placeholder_hash', 'student'),
    ('Dina Mansour', 'dina@example.com', 'placeholder_hash', 'student'),
    ('Zaid Barakat', 'zaid@example.com', 'placeholder_hash', 'student'),
    ('Lina Farouk', 'lina@example.com', 'placeholder_hash', 'student'),
    ('Karim Sabbagh', 'karim@example.com', 'placeholder_hash', 'student');

-- ===== Courses =====
-- Omar Nasser: Databases / Backend
INSERT INTO courses (manager_id, title, description, category, skill_level, duration_hours, status) VALUES
    ((SELECT id FROM users WHERE email = 'omar@skillpath.com'),
        'Intro to SQL', 'Learn the fundamentals of relational databases and SQL queries.',
        'Databases', 'beginner', 24, 'published'),
    ((SELECT id FROM users WHERE email = 'omar@skillpath.com'),
        'Advanced PostgreSQL', 'Indexing, query planning, and performance tuning for production databases.',
        'Databases', 'advanced', 18, 'published'),
    ((SELECT id FROM users WHERE email = 'omar@skillpath.com'),
        'Node.js & Express Fundamentals', 'Build REST APIs from scratch with Node.js and Express.',
        'Web Development', 'beginner', 20, 'published');

-- Layla Hassan: Data Science / ML
INSERT INTO courses (manager_id, title, description, category, skill_level, duration_hours, status) VALUES
    ((SELECT id FROM users WHERE email = 'layla@skillpath.com'),
        'Python for Data Analysis', 'Using pandas and numpy to explore and clean real datasets.',
        'Data Science', 'intermediate', 15, 'published'),
    ((SELECT id FROM users WHERE email = 'layla@skillpath.com'),
        'Machine Learning Foundations', 'Core ML concepts: regression, classification, and model evaluation.',
        'Machine Learning', 'intermediate', 30, 'published'),
    ((SELECT id FROM users WHERE email = 'layla@skillpath.com'),
        'Data Visualization with Tableau', 'Turn raw data into clear, presentable dashboards.',
        'Data Science', 'beginner', 10, 'published');

-- Fatima Zahra: DevOps / Security
INSERT INTO courses (manager_id, title, description, category, skill_level, duration_hours, status) VALUES
    ((SELECT id FROM users WHERE email = 'fatima@skillpath.com'),
        'Docker Fundamentals', 'Containerize applications from scratch.',
        'DevOps', 'beginner', 8, 'draft'),
    ((SELECT id FROM users WHERE email = 'fatima@skillpath.com'),
        'Kubernetes in Practice', 'Deploy and scale containerized workloads on a real cluster.',
        'DevOps', 'advanced', 25, 'published'),
    ((SELECT id FROM users WHERE email = 'fatima@skillpath.com'),
        'Introduction to Cybersecurity', 'Core security principles: threats, defenses, and best practices.',
        'Cybersecurity', 'beginner', 12, 'published'),
    ((SELECT id FROM users WHERE email = 'fatima@skillpath.com'),
        'Ethical Hacking Basics', 'Hands-on penetration testing fundamentals in a lab environment.',
        'Cybersecurity', 'intermediate', 20, 'published'),
    ((SELECT id FROM users WHERE email = 'fatima@skillpath.com'),
        'Cloud Computing with AWS', 'Core AWS services for deploying and scaling applications.',
        'Cloud Computing', 'intermediate', 22, 'published');

-- Kareem Fahad: Design / Mobile
INSERT INTO courses (manager_id, title, description, category, skill_level, duration_hours, status) VALUES
    ((SELECT id FROM users WHERE email = 'kareem@skillpath.com'),
        'UX Design Principles', 'User research, wireframing, and usability testing fundamentals.',
        'Design', 'beginner', 14, 'published'),
    ((SELECT id FROM users WHERE email = 'kareem@skillpath.com'),
        'Advanced React Patterns', 'Deep dive into hooks, context, and performance optimization.',
        'Web Development', 'advanced', 20, 'published'),
    ((SELECT id FROM users WHERE email = 'kareem@skillpath.com'),
        'iOS App Development with Swift', 'Build and ship a native iOS app from scratch.',
        'Mobile Development', 'intermediate', 28, 'published'),
    ((SELECT id FROM users WHERE email = 'kareem@skillpath.com'),
        'Figma for Product Designers', 'Component systems, auto layout, and prototyping in Figma.',
        'Design', 'beginner', 6, 'draft');

-- ===== Enrollments =====
-- Only in published courses, 2-4 per student, matched to plausible interests.
INSERT INTO enrollments (user_id, course_id) VALUES
    ((SELECT id FROM users WHERE email = 'sara@example.com'), (SELECT id FROM courses WHERE title = 'Intro to SQL')),
    ((SELECT id FROM users WHERE email = 'sara@example.com'), (SELECT id FROM courses WHERE title = 'Python for Data Analysis')),
    ((SELECT id FROM users WHERE email = 'sara@example.com'), (SELECT id FROM courses WHERE title = 'Machine Learning Foundations')),

    ((SELECT id FROM users WHERE email = 'yousef@example.com'), (SELECT id FROM courses WHERE title = 'Advanced React Patterns')),
    ((SELECT id FROM users WHERE email = 'yousef@example.com'), (SELECT id FROM courses WHERE title = 'Node.js & Express Fundamentals')),
    ((SELECT id FROM users WHERE email = 'yousef@example.com'), (SELECT id FROM courses WHERE title = 'UX Design Principles')),

    ((SELECT id FROM users WHERE email = 'maya@example.com'), (SELECT id FROM courses WHERE title = 'Introduction to Cybersecurity')),
    ((SELECT id FROM users WHERE email = 'maya@example.com'), (SELECT id FROM courses WHERE title = 'Ethical Hacking Basics')),
    ((SELECT id FROM users WHERE email = 'maya@example.com'), (SELECT id FROM courses WHERE title = 'Kubernetes in Practice')),

    ((SELECT id FROM users WHERE email = 'ali@example.com'), (SELECT id FROM courses WHERE title = 'Python for Data Analysis')),
    ((SELECT id FROM users WHERE email = 'ali@example.com'), (SELECT id FROM courses WHERE title = 'Data Visualization with Tableau')),

    ((SELECT id FROM users WHERE email = 'noor@example.com'), (SELECT id FROM courses WHERE title = 'UX Design Principles')),
    ((SELECT id FROM users WHERE email = 'noor@example.com'), (SELECT id FROM courses WHERE title = 'iOS App Development with Swift')),
    ((SELECT id FROM users WHERE email = 'noor@example.com'), (SELECT id FROM courses WHERE title = 'Advanced React Patterns')),

    ((SELECT id FROM users WHERE email = 'tariq@example.com'), (SELECT id FROM courses WHERE title = 'Intro to SQL')),
    ((SELECT id FROM users WHERE email = 'tariq@example.com'), (SELECT id FROM courses WHERE title = 'Advanced PostgreSQL')),
    ((SELECT id FROM users WHERE email = 'tariq@example.com'), (SELECT id FROM courses WHERE title = 'Cloud Computing with AWS')),

    ((SELECT id FROM users WHERE email = 'rana@example.com'), (SELECT id FROM courses WHERE title = 'Machine Learning Foundations')),
    ((SELECT id FROM users WHERE email = 'rana@example.com'), (SELECT id FROM courses WHERE title = 'Data Visualization with Tableau')),
    ((SELECT id FROM users WHERE email = 'rana@example.com'), (SELECT id FROM courses WHERE title = 'Python for Data Analysis')),

    ((SELECT id FROM users WHERE email = 'hassan@example.com'), (SELECT id FROM courses WHERE title = 'Kubernetes in Practice')),
    ((SELECT id FROM users WHERE email = 'hassan@example.com'), (SELECT id FROM courses WHERE title = 'Cloud Computing with AWS')),
    ((SELECT id FROM users WHERE email = 'hassan@example.com'), (SELECT id FROM courses WHERE title = 'Introduction to Cybersecurity')),

    ((SELECT id FROM users WHERE email = 'dina@example.com'), (SELECT id FROM courses WHERE title = 'Node.js & Express Fundamentals')),
    ((SELECT id FROM users WHERE email = 'dina@example.com'), (SELECT id FROM courses WHERE title = 'Advanced React Patterns')),

    ((SELECT id FROM users WHERE email = 'zaid@example.com'), (SELECT id FROM courses WHERE title = 'Ethical Hacking Basics')),
    ((SELECT id FROM users WHERE email = 'zaid@example.com'), (SELECT id FROM courses WHERE title = 'Introduction to Cybersecurity')),
    ((SELECT id FROM users WHERE email = 'zaid@example.com'), (SELECT id FROM courses WHERE title = 'Kubernetes in Practice')),

    ((SELECT id FROM users WHERE email = 'lina@example.com'), (SELECT id FROM courses WHERE title = 'iOS App Development with Swift')),
    ((SELECT id FROM users WHERE email = 'lina@example.com'), (SELECT id FROM courses WHERE title = 'UX Design Principles')),

    ((SELECT id FROM users WHERE email = 'karim@example.com'), (SELECT id FROM courses WHERE title = 'Intro to SQL')),
    ((SELECT id FROM users WHERE email = 'karim@example.com'), (SELECT id FROM courses WHERE title = 'Cloud Computing with AWS')),
    ((SELECT id FROM users WHERE email = 'karim@example.com'), (SELECT id FROM courses WHERE title = 'Advanced PostgreSQL')),
    ((SELECT id FROM users WHERE email = 'karim@example.com'), (SELECT id FROM courses WHERE title = 'Node.js & Express Fundamentals'));
