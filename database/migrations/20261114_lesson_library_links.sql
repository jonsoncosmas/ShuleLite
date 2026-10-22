ALTER TABLE lesson_plans ADD UNIQUE KEY uq_lesson_id_school (id,school_id);

CREATE TABLE IF NOT EXISTS lesson_plan_resources (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    lesson_plan_id BIGINT UNSIGNED NOT NULL,
    learning_note_id BIGINT UNSIGNED NOT NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_lesson_library_resource (lesson_plan_id,learning_note_id),
    KEY idx_lesson_resource_school (school_id,lesson_plan_id),
    CONSTRAINT fk_lesson_resource_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_lesson_resource_lesson FOREIGN KEY (lesson_plan_id,school_id) REFERENCES lesson_plans(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_lesson_resource_note FOREIGN KEY (learning_note_id) REFERENCES learning_notes(id) ON DELETE RESTRICT,
    CONSTRAINT fk_lesson_resource_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

