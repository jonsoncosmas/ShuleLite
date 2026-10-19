ALTER TABLE subscriptions
    ADD COLUMN academic_year SMALLINT UNSIGNED NOT NULL DEFAULT 2026 AFTER ends_on,
    ADD COLUMN pupil_count INT UNSIGNED NOT NULL DEFAULT 0 AFTER academic_year,
    ADD COLUMN unit_price DECIMAL(12,2) NOT NULL DEFAULT 0 AFTER pupil_count,
    ADD COLUMN discount_percent DECIMAL(5,2) NOT NULL DEFAULT 0 AFTER unit_price,
    ADD COLUMN total_amount DECIMAL(14,2) NOT NULL DEFAULT 0 AFTER discount_percent;

CREATE TABLE IF NOT EXISTS school_subscription_discounts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    discount_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
    reason VARCHAR(255) NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    updated_by BIGINT UNSIGNED NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_school_subscription_discount (school_id),
    CONSTRAINT fk_school_subscription_discount_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_school_subscription_discount_user FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
