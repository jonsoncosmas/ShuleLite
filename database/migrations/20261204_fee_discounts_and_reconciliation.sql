ALTER TABLE school_fee_ledger
    MODIFY entry_type ENUM('charge','payment','charge_reversal','payment_reversal','discount','discount_reversal') NOT NULL;

CREATE TABLE IF NOT EXISTS fee_reconciliation_batches (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    statement_name VARCHAR(180) NOT NULL,
    statement_date DATE NOT NULL,
    status ENUM('reviewing','completed') NOT NULL DEFAULT 'reviewing',
    row_count INT UNSIGNED NOT NULL DEFAULT 0,
    matched_count INT UNSIGNED NOT NULL DEFAULT 0,
    created_by BIGINT UNSIGNED NOT NULL,
    completed_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    UNIQUE KEY uq_fee_reconciliation_scope (id,school_id),
    KEY idx_fee_reconciliation_school (school_id,status,statement_date),
    CONSTRAINT fk_fee_reconciliation_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_fee_reconciliation_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_fee_reconciliation_completer FOREIGN KEY (completed_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS fee_reconciliation_lines (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    batch_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    line_number INT UNSIGNED NOT NULL,
    transaction_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    reference VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    matched_ledger_id BIGINT UNSIGNED NULL,
    match_status ENUM('matched','unmatched','amount_mismatch','duplicate_reference','ignored') NOT NULL DEFAULT 'unmatched',
    review_note VARCHAR(255) NULL,
    UNIQUE KEY uq_fee_reconciliation_line (batch_id,line_number),
    UNIQUE KEY uq_fee_reconciliation_ledger (school_id,matched_ledger_id),
    KEY idx_fee_reconciliation_match (school_id,reference,amount),
    CONSTRAINT fk_fee_reconciliation_batch FOREIGN KEY (batch_id,school_id) REFERENCES fee_reconciliation_batches(id,school_id) ON DELETE CASCADE,
    CONSTRAINT chk_fee_reconciliation_amount CHECK (amount > 0)
) ENGINE=InnoDB;

ALTER TABLE inventory_items
    ADD COLUMN last_unit_cost DECIMAL(12,2) NULL AFTER quantity;

ALTER TABLE inventory_movements
    ADD COLUMN unit_cost DECIMAL(12,2) NULL AFTER quantity;
