ALTER TABLE inventory_items ADD UNIQUE KEY uq_inventory_item_scope (id,school_id);

CREATE TABLE IF NOT EXISTS inventory_stocktakes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    reference VARCHAR(80) NOT NULL,
    status ENUM('draft','submitted','applied','rejected') NOT NULL DEFAULT 'draft',
    note VARCHAR(1000) NULL,
    review_note VARCHAR(1000) NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL,
    applied_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_inventory_stocktake_reference (school_id,reference),
    UNIQUE KEY uq_inventory_stocktake_scope (id,school_id),
    KEY idx_inventory_stocktake_queue (school_id,status,created_at),
    CONSTRAINT fk_inventory_stocktake_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_stocktake_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_stocktake_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS inventory_stocktake_lines (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    stocktake_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    snapshot_quantity DECIMAL(10,2) NOT NULL,
    counted_quantity DECIMAL(10,2) NULL,
    line_note VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_inventory_stocktake_item (stocktake_id,item_id),
    KEY idx_inventory_stocktake_line_scope (school_id,stocktake_id),
    CONSTRAINT fk_inventory_stocktake_line_session FOREIGN KEY (stocktake_id,school_id) REFERENCES inventory_stocktakes(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_stocktake_line_item FOREIGN KEY (item_id,school_id) REFERENCES inventory_items(id,school_id) ON DELETE RESTRICT,
    CONSTRAINT chk_inventory_stocktake_count CHECK (counted_quantity IS NULL OR counted_quantity >= 0)
) ENGINE=InnoDB;
