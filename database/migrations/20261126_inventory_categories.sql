CREATE TABLE IF NOT EXISTS inventory_categories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    status ENUM('active','inactive') NOT NULL DEFAULT 'active',
    created_by BIGINT UNSIGNED NOT NULL,
    updated_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_inventory_category_name (school_id,name),
    UNIQUE KEY uq_inventory_category_scope (id,school_id),
    KEY idx_inventory_category_status (school_id,status,name),
    CONSTRAINT fk_inventory_category_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_category_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_category_updater FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

ALTER TABLE inventory_items
    ADD COLUMN category_id BIGINT UNSIGNED NULL AFTER school_id,
    ADD KEY idx_inventory_category (school_id,category_id),
    ADD CONSTRAINT fk_inventory_category FOREIGN KEY (category_id,school_id) REFERENCES inventory_categories(id,school_id) ON DELETE RESTRICT;