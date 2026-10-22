ALTER TABLE school_classes ADD UNIQUE KEY uq_school_class_id_scope (id,school_id);
ALTER TABLE school_fee_ledger ADD UNIQUE KEY uq_fee_ledger_id_scope (id,school_id,pupil_id);

CREATE TABLE IF NOT EXISTS fee_structures (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED NOT NULL,
    academic_year SMALLINT UNSIGNED NOT NULL,
    term VARCHAR(40) NOT NULL,
    title VARCHAR(180) NOT NULL,
    status ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_fee_structure_title (school_id,class_id,academic_year,term,title),
    UNIQUE KEY uq_fee_structure_school (id,school_id),
    KEY idx_fee_structure_class (school_id,class_id,academic_year,term,status),
    CONSTRAINT fk_fee_structure_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_fee_structure_class FOREIGN KEY (class_id,school_id) REFERENCES school_classes(id,school_id) ON DELETE RESTRICT,
    CONSTRAINT fk_fee_structure_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS fee_structure_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    structure_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    sequence_no SMALLINT UNSIGNED NOT NULL,
    description VARCHAR(180) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_fee_item_sequence (structure_id,sequence_no),
    UNIQUE KEY uq_fee_item_scope (id,structure_id,school_id),
    CONSTRAINT fk_fee_item_structure FOREIGN KEY (structure_id,school_id) REFERENCES fee_structures(id,school_id) ON DELETE CASCADE,
    CONSTRAINT chk_fee_item_amount CHECK (amount > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS fee_assessments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    structure_id BIGINT UNSIGNED NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    pupil_id BIGINT UNSIGNED NOT NULL,
    ledger_entry_id BIGINT UNSIGNED NOT NULL,
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_fee_assessment_pupil_item (item_id,pupil_id),
    UNIQUE KEY uq_fee_assessment_ledger (ledger_entry_id),
    KEY idx_fee_assessment_scope (school_id,structure_id,pupil_id),
    CONSTRAINT fk_fee_assessment_structure FOREIGN KEY (structure_id,school_id) REFERENCES fee_structures(id,school_id) ON DELETE RESTRICT,
    CONSTRAINT fk_fee_assessment_item FOREIGN KEY (item_id,structure_id,school_id) REFERENCES fee_structure_items(id,structure_id,school_id) ON DELETE RESTRICT,
    CONSTRAINT fk_fee_assessment_pupil FOREIGN KEY (pupil_id,school_id) REFERENCES pupils(id,school_id) ON DELETE RESTRICT,
    CONSTRAINT fk_fee_assessment_ledger FOREIGN KEY (ledger_entry_id,school_id,pupil_id) REFERENCES school_fee_ledger(id,school_id,pupil_id) ON DELETE RESTRICT
) ENGINE=InnoDB;
