CREATE TABLE IF NOT EXISTS employee_attendance (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    attendance_date DATE NOT NULL,
    check_in_at DATETIME NOT NULL,
    check_out_at DATETIME NULL,
    check_in_by BIGINT UNSIGNED NOT NULL,
    check_out_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_employee_attendance_day (school_id,user_id,attendance_date),
    KEY idx_employee_attendance_date (school_id,attendance_date),
    CONSTRAINT fk_employee_attendance_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_employee_attendance_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_employee_attendance_checkin FOREIGN KEY (check_in_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_employee_attendance_checkout FOREIGN KEY (check_out_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;