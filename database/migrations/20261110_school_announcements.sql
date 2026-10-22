CREATE TABLE IF NOT EXISTS school_announcements (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(180) NOT NULL,
    body MEDIUMTEXT NOT NULL,
    audience ENUM('all','parents','pupils','staff') NOT NULL DEFAULT 'all',
    status ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
    expires_at DATE NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    published_by BIGINT UNSIGNED NULL,
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_announcement_audience (school_id,status,audience,published_at,expires_at),
    CONSTRAINT fk_announcement_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_announcement_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_announcement_publisher FOREIGN KEY (published_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;
