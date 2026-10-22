CREATE TABLE IF NOT EXISTS inventory_requests (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    request_note VARCHAR(255) NULL,
    status ENUM('pending','approved','rejected','issued','cancelled') NOT NULL DEFAULT 'pending',
    review_note VARCHAR(255) NULL,
    requested_by BIGINT UNSIGNED NOT NULL,
    reviewed_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    KEY idx_inventory_request_queue (school_id,status,created_at),
    CONSTRAINT fk_inventory_request_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_request_item FOREIGN KEY (item_id) REFERENCES inventory_items(id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_requester FOREIGN KEY (requested_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

ALTER TABLE inventory_movements
    ADD COLUMN request_id BIGINT UNSIGNED NULL AFTER item_id,
    ADD UNIQUE KEY uq_inventory_request_issue (request_id),
    ADD CONSTRAINT fk_inventory_movement_request FOREIGN KEY (request_id) REFERENCES inventory_requests(id) ON DELETE RESTRICT;
