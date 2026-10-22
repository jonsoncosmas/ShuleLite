CREATE TABLE IF NOT EXISTS ai_question_import_batches (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    import_key CHAR(64) NOT NULL,
    question_ids JSON NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_ai_question_import_key (school_id,created_by,import_key),
    KEY idx_ai_question_import_actor (school_id,created_by,created_at),
    CONSTRAINT fk_ai_question_import_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_ai_question_import_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
