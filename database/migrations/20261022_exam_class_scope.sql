ALTER TABLE school_exams
    DROP INDEX uq_school_exam,
    ADD COLUMN class_id BIGINT UNSIGNED NULL AFTER school_id,
    ADD UNIQUE KEY uq_school_exam (school_id,name,academic_year,class_id),
    ADD KEY idx_school_exam_class (class_id),
    ADD CONSTRAINT fk_exam_class FOREIGN KEY (class_id) REFERENCES school_classes(id) ON DELETE RESTRICT;
