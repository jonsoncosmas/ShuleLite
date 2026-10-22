ALTER TABLE school_exams
    DROP INDEX uq_school_exam,
    ADD COLUMN subject_id BIGINT UNSIGNED NULL AFTER class_id,
    ADD COLUMN term VARCHAR(40) NULL AFTER academic_year,
    ADD COLUMN exam_date DATE NULL AFTER term,
    ADD COLUMN duration_minutes SMALLINT UNSIGNED NULL AFTER exam_date,
    ADD COLUMN instructions TEXT NULL AFTER duration_minutes,
    ADD COLUMN total_marks DECIMAL(7,2) NOT NULL DEFAULT 0 AFTER instructions,
    ADD COLUMN status ENUM('draft','submitted','approved','returned','scheduled','results_open','results_published','archived') NOT NULL DEFAULT 'results_open' AFTER total_marks,
    ADD COLUMN reviewed_by BIGINT UNSIGNED NULL AFTER created_by,
    ADD COLUMN reviewed_at TIMESTAMP NULL AFTER reviewed_by,
    ADD COLUMN review_feedback TEXT NULL AFTER reviewed_at,
    ADD UNIQUE KEY uq_school_exam_context (school_id,name,academic_year,class_id,subject_id),
    ADD KEY idx_school_exam_status (school_id,status,exam_date),
    ADD CONSTRAINT fk_exam_subject FOREIGN KEY (subject_id) REFERENCES school_class_subjects(id) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_exam_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS exam_paper_questions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    exam_id BIGINT UNSIGNED NOT NULL,
    question_id BIGINT UNSIGNED NOT NULL,
    section_name VARCHAR(120) NOT NULL DEFAULT 'Section A',
    sequence_no SMALLINT UNSIGNED NOT NULL,
    marks DECIMAL(6,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_exam_question (exam_id,question_id),
    UNIQUE KEY uq_exam_question_order (exam_id,section_name,sequence_no),
    CONSTRAINT fk_exam_question_exam FOREIGN KEY (exam_id) REFERENCES school_exams(id) ON DELETE CASCADE,
    CONSTRAINT fk_exam_question_bank FOREIGN KEY (question_id) REFERENCES question_bank(id) ON DELETE RESTRICT,
    CONSTRAINT chk_exam_question_marks CHECK (marks > 0)
) ENGINE=InnoDB;
