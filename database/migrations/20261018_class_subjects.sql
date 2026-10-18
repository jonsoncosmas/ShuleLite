-- Adds class-specific subjects and copies each existing school subject to its classes.
CREATE TABLE IF NOT EXISTS school_class_subjects (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_class_subject (class_id,name),
    CONSTRAINT fk_class_subject_class FOREIGN KEY (class_id) REFERENCES school_classes(id) ON DELETE CASCADE,
    CONSTRAINT fk_class_subject_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

INSERT IGNORE INTO school_class_subjects (class_id,name,created_by)
SELECT c.id,sj.name,sj.created_by
FROM school_subjects sj
JOIN school_classes c ON c.school_id=sj.school_id;
