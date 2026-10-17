-- Run once on an existing ShuleLite database.
ALTER TABLE users ADD COLUMN username VARCHAR(60) NULL UNIQUE AFTER email;
