CREATE TABLE IF NOT EXISTS school_exams (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(120) NOT NULL,
    academic_year SMALLINT UNSIGNED NOT NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_school_exam (school_id,name,academic_year),
    CONSTRAINT fk_exam_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_exam_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

INSERT IGNORE INTO school_exams(school_id,name,academic_year,created_by)
SELECT r.school_id,r.exam_name,r.academic_year,MIN(r.entered_by)
FROM pupil_results r
GROUP BY r.school_id,r.exam_name,r.academic_year;
