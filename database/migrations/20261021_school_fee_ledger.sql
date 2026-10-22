CREATE TABLE IF NOT EXISTS school_fee_ledger (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    pupil_id BIGINT UNSIGNED NOT NULL,
    entry_type ENUM('charge','payment') NOT NULL,
    academic_year SMALLINT UNSIGNED NOT NULL,
    term VARCHAR(40) NOT NULL,
    description VARCHAR(180) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_method VARCHAR(40) NULL,
    reference VARCHAR(100) NULL,
    recorded_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_fee_ledger_pupil (school_id,pupil_id,academic_year,term,created_at),
    CONSTRAINT fk_fee_ledger_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_fee_ledger_pupil FOREIGN KEY (pupil_id) REFERENCES pupils(id) ON DELETE CASCADE,
    CONSTRAINT fk_fee_ledger_user FOREIGN KEY (recorded_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
