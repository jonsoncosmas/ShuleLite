CREATE TABLE IF NOT EXISTS inventory_suppliers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(160) NOT NULL,
    contact_name VARCHAR(140) NULL,
    phone VARCHAR(40) NULL,
    email VARCHAR(190) NULL,
    status ENUM('active','inactive') NOT NULL DEFAULT 'active',
    created_by BIGINT UNSIGNED NOT NULL,
    updated_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_inventory_supplier_name (school_id,name),
    KEY idx_inventory_supplier_status (school_id,status,name),
    CONSTRAINT fk_inventory_supplier_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_supplier_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_supplier_updater FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

ALTER TABLE inventory_movements
    ADD COLUMN supplier_id BIGINT UNSIGNED NULL AFTER item_id,
    ADD KEY idx_inventory_movement_supplier (school_id,supplier_id,created_at),
    ADD CONSTRAINT fk_inventory_movement_supplier FOREIGN KEY (supplier_id) REFERENCES inventory_suppliers(id) ON DELETE RESTRICT;