CREATE TABLE IF NOT EXISTS school_grading_scales (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(120) NOT NULL,
    academic_year SMALLINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED NULL,
    status ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
    created_by BIGINT UNSIGNED NOT NULL,
    published_by BIGINT UNSIGNED NULL,
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_grading_scale_scope (school_id,academic_year,class_id,name),
    KEY idx_grading_scale_lookup (school_id,academic_year,class_id,status),
    CONSTRAINT fk_grading_scale_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_grading_scale_class FOREIGN KEY (class_id,school_id) REFERENCES school_classes(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_grading_scale_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_grading_scale_publisher FOREIGN KEY (published_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS school_grading_bands (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    scale_id BIGINT UNSIGNED NOT NULL,
    label VARCHAR(40) NOT NULL,
    minimum_percent DECIMAL(5,2) NOT NULL,
    maximum_percent DECIMAL(5,2) NOT NULL,
    comment VARCHAR(180) NULL,
    sort_order SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    UNIQUE KEY uq_grading_band_label (scale_id,label),
    KEY idx_grading_band_order (scale_id,sort_order,minimum_percent),
    CONSTRAINT fk_grading_band_scale FOREIGN KEY (scale_id) REFERENCES school_grading_scales(id) ON DELETE CASCADE
) ENGINE=InnoDB;
