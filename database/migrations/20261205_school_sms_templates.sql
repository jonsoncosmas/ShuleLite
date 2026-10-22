CREATE TABLE IF NOT EXISTS school_sms_templates (
    school_id BIGINT UNSIGNED NOT NULL,
    event_type ENUM('fee_payment','attendance_alert','exam_publication','school_announcement','fee_reminder','contract_expiry') NOT NULL,
    message_body VARCHAR(500) NOT NULL,
    updated_by BIGINT UNSIGNED NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (school_id,event_type),
    CONSTRAINT fk_school_sms_template_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_school_sms_template_updater FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
