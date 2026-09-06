-- SkillPath seed data: a larger, coherent dataset for demo purposes.
-- Wipes existing rows in these 5 tables and resets id sequences back to 1.
-- Run with: psql -d SkillPathDB -f db/seed.sql   (or paste into pgAdmin's Query tool)

TRUNCATE TABLE recommendations, quiz_responses, enrollments, courses, users
  RESTART IDENTITY CASCADE;

-- ===== Users =====
INSERT INTO users (name, email, password_hash, role) VALUES
    ('Admin User', 'admin@skillpath.com', 'password123', 'admin'),
    ('Omar Nasser', 'omar@skillpath.com', 'password123', 'manager'),
    ('Layla Hassan', 'layla@skillpath.com', 'password123', 'manager'),
    ('Fatima Zahra', 'fatima@skillpath.com', 'password123', 'manager'),
    ('Kareem Fahad', 'kareem@skillpath.com', 'password123', 'manager'),
    ('Sara Khaled', 'sara@example.com', 'password123', 'student'),
    ('Yousef Ali', 'yousef@example.com', 'password123', 'student'),
    ('Maya Odeh', 'maya@example.com', 'password123', 'student'),
    ('Ali Hamdan', 'ali@example.com', 'password123', 'student'),
    ('Noor Saleh', 'noor@example.com', 'password123', 'student'),
    ('Tariq Younis', 'tariq@example.com', 'password123', 'student'),
    ('Rana Aziz', 'rana@example.com', 'password123', 'student'),
    ('Hassan Khoury', 'hassan@example.com', 'password123', 'student'),
    ('Dina Mansour', 'dina@example.com', 'password123', 'student'),
    ('Zaid Barakat', 'zaid@example.com', 'password123', 'student'),
    ('Lina Farouk', 'lina@example.com', 'password123', 'student'),
    ('Karim Sabbagh', 'karim@example.com', 'password123', 'student');

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

-- ===== Course content (longer body text shown on the course detail page) =====
-- Safe to re-run; matches courses by title.

UPDATE courses SET content = 'This course starts from the assumption that you have never written a line of SQL before. You will learn how relational databases organize data into tables, how to write SELECT queries to pull exactly the information you need, and how to filter, sort, and combine results using WHERE, ORDER BY, and JOIN.

By the end, you will be comfortable designing simple table structures, writing multi-table queries, and understanding why relational databases remain the backbone of most real-world applications.

No prior database experience is assumed - just basic comfort using a computer.' WHERE title = 'Intro to SQL';

UPDATE courses SET content = 'Once you know the basics of SQL, this course goes under the hood of PostgreSQL itself. You will learn how the query planner decides how to execute a query, how indexes actually speed things up (and when they do not), and how to read an EXPLAIN ANALYZE output without guessing.

We cover B-tree and hash indexes, connection pooling, transaction isolation levels, and common patterns for avoiding lock contention in production systems.

This is a hands-on course: every concept is paired with a real dataset you will optimize yourself.' WHERE title = 'Advanced PostgreSQL';

UPDATE courses SET content = 'Learn how to build a real backend API from an empty folder. Starting with plain Node.js, you will build up to a full Express application with routing, middleware, and JSON request/response handling.

Topics include structuring routes and controllers, connecting to a database, validating incoming requests, and returning consistent error responses - the same patterns used by production REST APIs everywhere.

By the end you will have built and tested a small but complete API of your own.' WHERE title = 'Node.js & Express Fundamentals';

UPDATE courses SET content = 'Real data is messy. This course teaches you how to clean it, reshape it, and pull insight out of it using Python''s two most important data libraries: pandas and numpy.

You will practice loading real datasets, handling missing values, merging multiple data sources together, and producing summary statistics that actually answer a question - not just describe a spreadsheet.

Comfort with basic Python syntax (variables, loops, functions) is assumed.' WHERE title = 'Python for Data Analysis';

UPDATE courses SET content = 'This course builds a practical foundation in machine learning without skipping the math that actually matters. You will implement linear and logistic regression from first principles, then move on to decision trees and basic ensemble methods.

Just as importantly, you will learn how to evaluate a model honestly: train/test splits, cross-validation, and the difference between a model that looks good on paper and one that actually generalizes.

Some familiarity with Python and basic statistics will make this course much easier to follow.' WHERE title = 'Machine Learning Foundations';

UPDATE courses SET content = 'Data is only useful if someone can understand it. This course teaches you to build clear, honest dashboards in Tableau - starting with connecting a data source, through choosing the right chart type for the story you are telling.

You will learn the difference between a chart that looks impressive and one that actually communicates, including common pitfalls like misleading axes and overcrowded dashboards.

No coding required - this course is entirely hands-on inside Tableau itself.' WHERE title = 'Data Visualization with Tableau';

UPDATE courses SET content = 'Containers solve a real problem: "it works on my machine" stops being an excuse. This course walks through Docker from the ground up - images, containers, volumes, and networking - using small, practical examples rather than abstract theory.

By the end, you will be able to containerize a simple application yourself and understand what is actually happening when you run `docker build` and `docker run`.

This course is intentionally short and focused - a solid on-ramp before diving into orchestration tools like Kubernetes.' WHERE title = 'Docker Fundamentals';

UPDATE courses SET content = 'Once your application is containerized, Kubernetes is how you run it reliably at scale. This course covers pods, deployments, services, and config management on a real cluster - not just diagrams on a slide.

You will practice rolling out updates without downtime, debugging a pod that will not start, and understanding how Kubernetes decides where your workloads actually run.

Prior Docker experience is expected - this is not an introductory container course.' WHERE title = 'Kubernetes in Practice';

UPDATE courses SET content = 'Security is not a single tool, it is a way of thinking about systems. This course introduces the core principles: the CIA triad, common attack categories, and the layered-defense mindset that shows up in every serious security program.

You will look at real-world breach case studies to understand not just what went wrong technically, but what process failures allowed it to happen.

No prior security background needed - this is the recommended starting point before more specialized courses.' WHERE title = 'Introduction to Cybersecurity';

UPDATE courses SET content = 'This course teaches penetration testing fundamentals in a safe, legal lab environment built specifically for practice. You will learn the standard methodology - reconnaissance, scanning, exploitation, and reporting - used by real security assessments.

Hands-on labs cover common web application vulnerabilities and basic network exploitation techniques, always framed around understanding defenses, not causing harm.

Completion of Introduction to Cybersecurity (or equivalent experience) is recommended before starting this course.' WHERE title = 'Ethical Hacking Basics';

UPDATE courses SET content = 'Cloud platforms can feel overwhelming because of how much they offer. This course focuses on the AWS services you will actually use most often: EC2 for compute, S3 for storage, RDS for managed databases, and IAM for access control.

You will deploy a small real application to AWS yourself, understand what you are paying for and why, and learn the security basics that prevent the most common (and most expensive) cloud misconfigurations.

Basic familiarity with how web applications work is helpful but not required.' WHERE title = 'Cloud Computing with AWS';

UPDATE courses SET content = 'Good design starts long before anyone opens a design tool. This course covers the fundamentals of user research, how to turn research into wireframes, and how to run a usability test that actually surfaces real problems.

You will practice interviewing users, sketching low-fidelity wireframes, and iterating on a design based on feedback rather than personal preference.

This course is tool-agnostic - the thinking applies whether you eventually work in Figma, Sketch, or pen and paper.' WHERE title = 'UX Design Principles';

UPDATE courses SET content = 'This course assumes you are already comfortable with React and pushes further into the patterns that separate a working app from a maintainable one: compound components, render props versus hooks, context performance pitfalls, and code-splitting.

You will refactor a deliberately messy real component together, applying each pattern where it actually solves a problem - not just because it exists.

This is not a beginner React course - solid experience with hooks and component composition is required.' WHERE title = 'Advanced React Patterns';

UPDATE courses SET content = 'Build a real iOS application from scratch using Swift and SwiftUI. You will learn how views, state, and navigation work together in a native iOS app, and how to connect your app to a backend API for real data.

By the end of the course you will have built and run a complete small app on the iOS simulator, understanding the full path from a blank Xcode project to a working product.

Some prior programming experience is expected; prior Swift or mobile experience is not.' WHERE title = 'iOS App Development with Swift';

UPDATE courses SET content = 'Figma has become the industry standard for product design, and this course teaches it properly - not just where the buttons are, but how to build a design system that scales. You will learn components, variants, and auto layout well enough to build a reusable UI kit.

We also cover prototyping and handoff: how to make a design that developers can actually implement without guessing at your intent.

This course is being finalized - check back soon for the full outline.' WHERE title = 'Figma for Product Designers';
