CREATE TABLE IF NOT EXISTS homework_assignments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    teacher_id BIGINT UNSIGNED NOT NULL,
    class_level VARCHAR(80) NOT NULL,
    subject VARCHAR(100) NOT NULL,
    title VARCHAR(180) NOT NULL,
    instructions TEXT NOT NULL,
    due_date DATE NULL,
    learning_note_id BIGINT UNSIGNED NULL,
    status ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_homework_assignment_scope (id,school_id),
    KEY idx_homework_class_status_due (school_id,class_level,status,due_date),
    CONSTRAINT fk_homework_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_homework_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_homework_note FOREIGN KEY (learning_note_id) REFERENCES learning_notes(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pupil_homework_submissions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    assignment_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    pupil_id BIGINT UNSIGNED NOT NULL,
    response TEXT NOT NULL,
    status ENUM('submitted','reviewed') NOT NULL DEFAULT 'submitted',
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    feedback TEXT NULL,
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL,
    UNIQUE KEY uq_homework_pupil_submission (assignment_id,pupil_id),
    KEY idx_homework_submission_scope (school_id,assignment_id,status),
    CONSTRAINT fk_homework_submission_assignment FOREIGN KEY (assignment_id,school_id) REFERENCES homework_assignments(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_homework_submission_pupil FOREIGN KEY (pupil_id,school_id) REFERENCES pupils(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_homework_submission_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_homework_submission_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
) ENGINE=InnoDB;
