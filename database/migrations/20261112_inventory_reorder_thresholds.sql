ALTER TABLE inventory_items ADD COLUMN reorder_threshold DECIMAL(10,2) NULL DEFAULT NULL AFTER quantity;
