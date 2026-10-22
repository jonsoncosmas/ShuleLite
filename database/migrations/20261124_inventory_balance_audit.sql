ALTER TABLE inventory_movements
    ADD COLUMN balance_before DECIMAL(10,2) NULL AFTER quantity,
    ADD COLUMN balance_after DECIMAL(10,2) NULL AFTER balance_before;