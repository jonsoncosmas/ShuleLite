-- Run once after 001_add_username.sql on an existing database.
ALTER TABLE users ADD COLUMN must_change_password BOOLEAN NOT NULL DEFAULT FALSE AFTER password_hash;
UPDATE users
SET must_change_password = TRUE
WHERE role IN ('system_admin','sub_admin','admin','director','sub_director','headteacher');
