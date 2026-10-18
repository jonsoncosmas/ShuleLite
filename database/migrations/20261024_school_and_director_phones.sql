ALTER TABLE schools ADD COLUMN phone VARCHAR(30) NULL AFTER location;
ALTER TABLE users ADD COLUMN phone VARCHAR(30) NULL AFTER name;
ALTER TABLE school_edit_requests ADD COLUMN original_phone VARCHAR(30) NULL AFTER original_location;
ALTER TABLE school_edit_requests ADD COLUMN proposed_phone VARCHAR(30) NULL AFTER proposed_location;
