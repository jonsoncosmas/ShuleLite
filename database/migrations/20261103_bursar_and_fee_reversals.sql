ALTER TABLE users
    MODIFY role ENUM('system_admin','sub_admin','admin','director','sub_director','headteacher','head_academic','assistant_academic','examination_officer','teacher','driver','hr','storekeeper','bursar') NOT NULL;

ALTER TABLE school_fee_ledger
    MODIFY entry_type ENUM('charge','payment','charge_reversal','payment_reversal') NOT NULL,
    ADD COLUMN reversal_of BIGINT UNSIGNED NULL AFTER reference,
    ADD COLUMN reversal_reason VARCHAR(255) NULL AFTER reversal_of,
    ADD UNIQUE KEY uq_fee_reversal (reversal_of),
    ADD CONSTRAINT fk_fee_ledger_reversal FOREIGN KEY (reversal_of) REFERENCES school_fee_ledger(id) ON DELETE RESTRICT;
