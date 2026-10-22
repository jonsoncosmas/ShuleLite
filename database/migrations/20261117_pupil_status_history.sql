CREATE TABLE IF NOT EXISTS pupil_status_history (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pupil_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    previous_status ENUM('active','transferred','graduated') NOT NULL,
    new_status ENUM('active','transferred','graduated') NOT NULL,
    effective_date DATE NOT NULL,
    note VARCHAR(500) NULL,
    changed_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_pupil_status_history (school_id,pupil_id,effective_date),
    CONSTRAINT fk_pupil_status_history_pupil FOREIGN KEY (pupil_id,school_id) REFERENCES pupils(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_pupil_status_history_actor FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
