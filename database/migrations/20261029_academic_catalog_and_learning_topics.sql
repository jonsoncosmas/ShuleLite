CREATE TABLE IF NOT EXISTS academic_classes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_academic_class_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS academic_class_subjects (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_academic_class_subject (class_id,name),
    CONSTRAINT fk_academic_subject_class FOREIGN KEY (class_id) REFERENCES academic_classes(id) ON DELETE CASCADE,
    CONSTRAINT fk_academic_subject_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;
ALTER TABLE school_classes ADD COLUMN core_class_id BIGINT UNSIGNED NULL;
ALTER TABLE school_class_subjects ADD COLUMN core_subject_id BIGINT UNSIGNED NULL;
ALTER TABLE learning_notes ADD COLUMN topic VARCHAR(180) NULL AFTER subject;
INSERT IGNORE INTO academic_classes(name)
SELECT DISTINCT name FROM school_classes WHERE name<>'';
UPDATE school_classes sc JOIN academic_classes ac ON ac.name=sc.name SET sc.core_class_id=ac.id WHERE sc.core_class_id IS NULL;
INSERT IGNORE INTO academic_class_subjects(class_id,name)
SELECT DISTINCT sc.core_class_id,sj.name FROM school_class_subjects sj JOIN school_classes sc ON sc.id=sj.class_id WHERE sc.core_class_id IS NOT NULL AND sj.name<>'';
UPDATE school_class_subjects sj JOIN school_classes sc ON sc.id=sj.class_id JOIN academic_class_subjects ac ON ac.class_id=sc.core_class_id AND ac.name=sj.name SET sj.core_subject_id=ac.id WHERE sj.core_subject_id IS NULL;

ALTER TABLE school_classes ADD CONSTRAINT fk_school_class_core FOREIGN KEY (core_class_id) REFERENCES academic_classes(id) ON DELETE SET NULL;
ALTER TABLE school_class_subjects ADD CONSTRAINT fk_school_class_core_subject FOREIGN KEY (core_subject_id) REFERENCES academic_class_subjects(id) ON DELETE SET NULL;

ALTER TABLE school_classes ADD UNIQUE KEY uq_school_core_class (school_id,core_class_id);
ALTER TABLE school_class_subjects ADD UNIQUE KEY uq_school_core_subject (class_id,core_subject_id);
