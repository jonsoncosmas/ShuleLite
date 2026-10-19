CREATE TABLE IF NOT EXISTS learning_note_terms (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    term_type ENUM('class','subject') NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_learning_note_term (term_type,name),
    CONSTRAINT fk_learning_note_term_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
