ALTER TABLE employee_contracts
    ADD COLUMN renewed_from_id BIGINT UNSIGNED NULL AFTER status,
    ADD UNIQUE KEY uq_contract_renewal_source (renewed_from_id),
    ADD CONSTRAINT fk_contract_renewed_from FOREIGN KEY (renewed_from_id) REFERENCES employee_contracts(id) ON DELETE RESTRICT;