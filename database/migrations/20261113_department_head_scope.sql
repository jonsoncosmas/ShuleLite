ALTER TABLE users MODIFY role ENUM('system_admin','sub_admin','admin','director','sub_director','headteacher','head_academic','department_head','assistant_academic','examination_officer','teacher','driver','hr','storekeeper','bursar','parent','pupil') NOT NULL;

CREATE TABLE IF NOT EXISTS department_subjects (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    department_id BIGINT UNSIGNED NOT NULL,
    class_subject_id BIGINT UNSIGNED NOT NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_department_subject_school (school_id,class_subject_id),
    KEY idx_department_subject_scope (school_id,department_id),
    CONSTRAINT fk_department_subject_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_department_subject_department FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE,
    CONSTRAINT fk_department_subject_subject FOREIGN KEY (class_subject_id) REFERENCES school_class_subjects(id) ON DELETE CASCADE,
    CONSTRAINT fk_department_subject_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

