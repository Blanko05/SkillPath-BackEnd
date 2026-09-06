BEGIN;


CREATE TABLE IF NOT EXISTS public.enrollments
(
    id serial NOT NULL,
    user_id integer NOT NULL,
    course_id integer NOT NULL,
    enrolled_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT enrollments_pkey PRIMARY KEY (id),
    CONSTRAINT enrollments_user_id_course_id_key UNIQUE (user_id, course_id)
);

CREATE TABLE IF NOT EXISTS public.courses
(
    id serial NOT NULL,
    manager_id integer NOT NULL,
    title character varying(255) COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
    category character varying(100) COLLATE pg_catalog."default" NOT NULL,
    skill_level character varying(20) COLLATE pg_catalog."default" NOT NULL,
    duration_hours integer NOT NULL,
    status character varying(20) COLLATE pg_catalog."default" NOT NULL DEFAULT 'draft'::character varying,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    content text COLLATE pg_catalog."default",
    CONSTRAINT courses_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.users
(
    id serial NOT NULL,
    name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    email character varying(255) COLLATE pg_catalog."default" NOT NULL,
    password_hash character varying(255) COLLATE pg_catalog."default" NOT NULL,
    role character varying(20) COLLATE pg_catalog."default" NOT NULL DEFAULT 'student'::character varying,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT users_pkey PRIMARY KEY (id),
    CONSTRAINT users_email_key UNIQUE (email)
);

CREATE TABLE IF NOT EXISTS public.quiz_responses
(
    id serial NOT NULL,
    user_id integer NOT NULL,
    skill_level character varying(50) COLLATE pg_catalog."default" NOT NULL,
    time_availability character varying(50) COLLATE pg_catalog."default" NOT NULL,
    goals text[] COLLATE pg_catalog."default" NOT NULL DEFAULT '{}'::text[],
    free_text_prompt text COLLATE pg_catalog."default",
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT quiz_responses_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.recommendations
(
    id serial NOT NULL,
    quiz_response_id integer NOT NULL,
    course_id integer NOT NULL,
    rank integer NOT NULL,
    ai_rationale text COLLATE pg_catalog."default",
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT recommendations_pkey PRIMARY KEY (id),
    CONSTRAINT recommendations_quiz_response_id_rank_key UNIQUE (quiz_response_id, rank)
);

ALTER TABLE IF EXISTS public.enrollments
    ADD CONSTRAINT enrollments_course_id_fkey FOREIGN KEY (course_id)
    REFERENCES public.courses (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_enrollments_course_id
    ON public.enrollments(course_id);


ALTER TABLE IF EXISTS public.enrollments
    ADD CONSTRAINT enrollments_user_id_fkey FOREIGN KEY (user_id)
    REFERENCES public.users (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_enrollments_user_id
    ON public.enrollments(user_id);


ALTER TABLE IF EXISTS public.courses
    ADD CONSTRAINT courses_manager_id_fkey FOREIGN KEY (manager_id)
    REFERENCES public.users (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE RESTRICT;
CREATE INDEX IF NOT EXISTS idx_courses_manager_id
    ON public.courses(manager_id);


ALTER TABLE IF EXISTS public.quiz_responses
    ADD CONSTRAINT quiz_responses_user_id_fkey FOREIGN KEY (user_id)
    REFERENCES public.users (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_quiz_responses_user_id
    ON public.quiz_responses(user_id);


ALTER TABLE IF EXISTS public.recommendations
    ADD CONSTRAINT recommendations_course_id_fkey FOREIGN KEY (course_id)
    REFERENCES public.courses (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;


ALTER TABLE IF EXISTS public.recommendations
    ADD CONSTRAINT recommendations_quiz_response_id_fkey FOREIGN KEY (quiz_response_id)
    REFERENCES public.quiz_responses (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_recommendations_quiz_response_id
    ON public.recommendations(quiz_response_id);

END;
