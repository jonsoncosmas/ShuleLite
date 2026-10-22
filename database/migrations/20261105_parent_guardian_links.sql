ALTER TABLE users
    MODIFY role ENUM('system_admin','sub_admin','admin','director','sub_director','headteacher','head_academic','assistant_academic','examination_officer','teacher','driver','hr','storekeeper','bursar','parent') NOT NULL;

ALTER TABLE pupils
    ADD UNIQUE KEY uq_pupil_school_id (id,school_id);

CREATE TABLE IF NOT EXISTS pupil_guardians (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    pupil_id BIGINT UNSIGNED NOT NULL,
    guardian_user_id BIGINT UNSIGNED NOT NULL,
    relationship VARCHAR(50) NOT NULL DEFAULT 'Guardian',
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    receives_notifications BOOLEAN NOT NULL DEFAULT TRUE,
    linked_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_pupil_guardian (school_id,pupil_id,guardian_user_id),
    KEY idx_guardian_children (guardian_user_id,school_id),
    CONSTRAINT fk_pupil_guardian_child FOREIGN KEY (pupil_id,school_id) REFERENCES pupils(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_pupil_guardian_user FOREIGN KEY (guardian_user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_pupil_guardian_linker FOREIGN KEY (linked_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_pupil_guardian_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
) ENGINE=InnoDB;
