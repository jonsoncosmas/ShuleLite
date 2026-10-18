CREATE TABLE IF NOT EXISTS school_edit_permissions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    granted_by BIGINT UNSIGNED NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    granted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP NULL DEFAULT NULL,
    UNIQUE KEY uq_school_edit_permission (school_id,user_id),
    CONSTRAINT fk_school_edit_permission_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_school_edit_permission_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_school_edit_permission_grantor FOREIGN KEY (granted_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS school_edit_requests (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    requested_by BIGINT UNSIGNED NOT NULL,
    original_name VARCHAR(180) NOT NULL,
    original_location VARCHAR(180) NULL,
    proposed_name VARCHAR(180) NOT NULL,
    proposed_location VARCHAR(180) NULL,
    status ENUM('pending','approved','denied','reverted') NOT NULL DEFAULT 'pending',
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_school_edit_request_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_school_edit_request_user FOREIGN KEY (requested_by) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_school_edit_request_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
    KEY idx_school_edit_request_review (school_id,status,created_at)
) ENGINE=InnoDB;
