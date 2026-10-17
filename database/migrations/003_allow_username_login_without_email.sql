-- Existing accounts may continue using email; new accounts may use a username only.
ALTER TABLE users MODIFY email VARCHAR(190) NULL;
