ALTER TABLE users
    MODIFY role ENUM('system_admin','sub_admin','admin','director','sub_director','headteacher','head_academic','assistant_academic','examination_officer','teacher','driver','hr','storekeeper','bursar','parent','pupil') NOT NULL;

CREATE TABLE IF NOT EXISTS pupil_accounts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    pupil_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    linked_by BIGINT UNSIGNED NOT NULL,
    revoked_by BIGINT UNSIGNED NULL,
    revoked_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_pupil_account_child (pupil_id),
    UNIQUE KEY uq_pupil_account_user (user_id),
    KEY idx_pupil_account_scope (school_id,active),
    CONSTRAINT fk_pupil_account_child FOREIGN KEY (pupil_id,school_id) REFERENCES pupils(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_pupil_account_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_pupil_account_linker FOREIGN KEY (linked_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_pupil_account_revoker FOREIGN KEY (revoked_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_pupil_account_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
) ENGINE=InnoDB;
