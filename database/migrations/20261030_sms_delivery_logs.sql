CREATE TABLE IF NOT EXISTS sms_delivery_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NULL,
    director_user_id BIGINT UNSIGNED NULL,
    actor_id BIGINT UNSIGNED NULL,
    recipient VARCHAR(20) NOT NULL,
    endpoint VARCHAR(500) NOT NULL,
    http_status SMALLINT UNSIGNED NULL,
    status ENUM('accepted','failed') NOT NULL,
    provider_message_id VARCHAR(190) NULL,
    diagnostic TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_sms_delivery_status_created (status,created_at),
    KEY idx_sms_delivery_actor_created (actor_id,created_at),
    CONSTRAINT fk_sms_delivery_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE SET NULL,
    CONSTRAINT fk_sms_delivery_director FOREIGN KEY (director_user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_sms_delivery_actor FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;
