CREATE DATABASE IF NOT EXISTS somaspac_shulelite2 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE somaspac_shulelite2;

CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(140) NOT NULL,
    phone VARCHAR(30) NULL,
    email VARCHAR(190) NULL UNIQUE,
    username VARCHAR(60) NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    must_change_password BOOLEAN NOT NULL DEFAULT FALSE,
    role ENUM('system_admin','sub_admin','admin','director','sub_director','headteacher','head_academic','department_head','assistant_academic','examination_officer','teacher','driver','hr','storekeeper','bursar','parent','pupil') NOT NULL,
    status ENUM('active','disabled') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS schools (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(180) NOT NULL,
    location VARCHAR(180) NULL,
    phone VARCHAR(30) NULL,
    status ENUM('active','pending','inactive') NOT NULL DEFAULT 'active',
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_school_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS school_edit_permissions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    granted_by BIGINT UNSIGNED NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    granted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP NULL DEFAULT NULL,
    UNIQUE KEY uq_school_edit_permission (school_id,user_id),
    CONSTRAINT fk_school_edit_permission_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_school_edit_permission_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_school_edit_permission_grantor FOREIGN KEY (granted_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS school_setup_permissions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    granted_by BIGINT UNSIGNED NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    granted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP NULL DEFAULT NULL,
    UNIQUE KEY uq_school_setup_permission (school_id,user_id),
    CONSTRAINT fk_school_setup_permission_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_school_setup_permission_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_school_setup_permission_grantor FOREIGN KEY (granted_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS school_edit_requests (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    requested_by BIGINT UNSIGNED NOT NULL,
    original_name VARCHAR(180) NOT NULL,
    original_location VARCHAR(180) NULL,
    original_phone VARCHAR(30) NULL,
    proposed_name VARCHAR(180) NOT NULL,
    proposed_location VARCHAR(180) NULL,
    proposed_phone VARCHAR(30) NULL,
    status ENUM('pending','approved','denied','reverted') NOT NULL DEFAULT 'pending',
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_school_edit_request_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_school_edit_request_user FOREIGN KEY (requested_by) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_school_edit_request_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
    KEY idx_school_edit_request_review (school_id,status,created_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS subscription_prices (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'KES',
    billing_period ENUM('monthly','termly','yearly') NOT NULL DEFAULT 'yearly',
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_price_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS subscription_price_permissions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    granted_by BIGINT UNSIGNED NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    granted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP NULL DEFAULT NULL,
    UNIQUE KEY uq_subscription_price_permission_user (user_id),
    CONSTRAINT fk_subscription_price_permission_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_subscription_price_permission_grantor FOREIGN KEY (granted_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS school_subscription_discounts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    discount_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
    reason VARCHAR(255) NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    updated_by BIGINT UNSIGNED NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_school_subscription_discount (school_id),
    CONSTRAINT fk_school_subscription_discount_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_school_subscription_discount_user FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

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

CREATE TABLE IF NOT EXISTS school_classes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(80) NOT NULL,
    core_class_id BIGINT UNSIGNED NULL,
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_school_class (school_id,name),
    UNIQUE KEY uq_school_class_id_scope (id,school_id),
    UNIQUE KEY uq_school_core_class (school_id,core_class_id),
    CONSTRAINT fk_class_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_class_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_school_class_core FOREIGN KEY (core_class_id) REFERENCES academic_classes(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS school_class_subjects (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    core_subject_id BIGINT UNSIGNED NULL,
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_class_subject (class_id,name),
    UNIQUE KEY uq_school_core_subject (class_id,core_subject_id),
    CONSTRAINT fk_class_subject_class FOREIGN KEY (class_id) REFERENCES school_classes(id) ON DELETE CASCADE,
    CONSTRAINT fk_class_subject_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_school_class_core_subject FOREIGN KEY (core_subject_id) REFERENCES academic_class_subjects(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS school_streams (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(80) NOT NULL,
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_class_stream (class_id,name),
    CONSTRAINT fk_stream_class FOREIGN KEY (class_id) REFERENCES school_classes(id) ON DELETE CASCADE,
    CONSTRAINT fk_stream_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS school_subjects (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_school_subject (school_id,name),
    CONSTRAINT fk_subject_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_subject_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS teacher_assignments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    class_level VARCHAR(80) NOT NULL,
    subject VARCHAR(100) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_teacher_assignment (user_id, school_id, class_level, subject),
    CONSTRAINT fk_assignment_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_assignment_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS learning_notes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    note_type ENUM('central','teacher') NOT NULL,
    class_level VARCHAR(80) NOT NULL,
    subject VARCHAR(100) NULL,
    topic VARCHAR(180) NULL,
    subtopic VARCHAR(180) NOT NULL,
    content MEDIUMTEXT NOT NULL,
    source VARCHAR(180) NULL,
    author_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NULL,
    status ENUM('published','draft') NOT NULL DEFAULT 'published',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_notes_class_subject (class_level, subject, status),
    CONSTRAINT fk_note_author FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_note_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS learning_note_terms (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    term_type ENUM('class','subject') NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_learning_note_term (term_type,name),
    CONSTRAINT fk_learning_note_term_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ai_provider_settings (
    id TINYINT UNSIGNED NOT NULL PRIMARY KEY,
    provider VARCHAR(40) NOT NULL DEFAULT 'openrouter',
    model VARCHAR(160) NOT NULL DEFAULT 'openai/gpt-4o-mini',
    api_key_ciphertext TEXT NOT NULL,
    updated_by BIGINT UNSIGNED NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_ai_provider_settings_user FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sms_delivery_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NULL,
    director_user_id BIGINT UNSIGNED NULL,
    actor_id BIGINT UNSIGNED NULL,
    recipient VARCHAR(20) NOT NULL,
    endpoint VARCHAR(500) NOT NULL,
    http_status SMALLINT UNSIGNED NULL,
    status ENUM('accepted','failed') NOT NULL,
    provider_message_id VARCHAR(190) NULL,
    delivery_status VARCHAR(40) NULL,
    status_checked_at TIMESTAMP NULL,
    status_check_diagnostic TEXT NULL,
    diagnostic TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_sms_delivery_status_created (status,created_at),
    KEY idx_sms_delivery_actor_created (actor_id,created_at),
    CONSTRAINT fk_sms_delivery_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE SET NULL,
    CONSTRAINT fk_sms_delivery_director FOREIGN KEY (director_user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_sms_delivery_actor FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    actor_id BIGINT UNSIGNED NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(80) NOT NULL,
    entity_id BIGINT UNSIGNED NULL,
    details JSON NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_audit_entity (entity_type, entity_id),
    CONSTRAINT fk_audit_actor FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

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

CREATE TABLE IF NOT EXISTS school_memberships (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    scope ENUM('member','manager') NOT NULL DEFAULT 'member',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_school_member (school_id,user_id),
    CONSTRAINT fk_member_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_member_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS departments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(120) NOT NULL,
    department_type ENUM('general','academic') NOT NULL DEFAULT 'general',
    head_user_id BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_department_name (school_id,name,department_type),
    CONSTRAINT fk_department_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_department_head FOREIGN KEY (head_user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

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

CREATE TABLE IF NOT EXISTS department_reports (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    department_id BIGINT UNSIGNED NOT NULL,
    author_id BIGINT UNSIGNED NOT NULL,
    report_type ENUM('weekly','monthly','termly') NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    narrative TEXT NULL,
    recommendations TEXT NULL,
    activity_snapshot JSON NOT NULL,
    status ENUM('draft','submitted','approved','returned') NOT NULL DEFAULT 'draft',
    review_feedback TEXT NULL,
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at DATETIME NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_department_reports_scope (school_id,department_id,status,period_start),
    KEY idx_department_reports_author (school_id,author_id,status),
    CONSTRAINT fk_department_report_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_department_report_department FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE,
    CONSTRAINT fk_department_report_author FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_department_report_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_department_report_period CHECK (period_start <= period_end)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pupils (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    admission_number VARCHAR(60) NOT NULL,
    first_name VARCHAR(80) NOT NULL,
    middle_name VARCHAR(80) NULL,
    last_name VARCHAR(80) NOT NULL,
    date_of_birth DATE NULL,
    class_level VARCHAR(80) NOT NULL,
    stream VARCHAR(80) NULL,
    scholar_type ENUM('day','boarding') NOT NULL DEFAULT 'day',
    guardian_name VARCHAR(140) NULL,
    guardian_phone VARCHAR(30) NULL,
    status ENUM('active','transferred','graduated') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_pupil_admission (school_id,admission_number),
    UNIQUE KEY uq_pupil_school_id (id,school_id),
    KEY idx_pupil_search (school_id,last_name,first_name),
    CONSTRAINT fk_pupil_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pupil_guardians (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    pupil_id BIGINT UNSIGNED NOT NULL,
    guardian_user_id BIGINT UNSIGNED NOT NULL,
    relationship VARCHAR(50) NOT NULL DEFAULT 'Guardian',
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    receives_notifications BOOLEAN NOT NULL DEFAULT TRUE,
    linked_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_pupil_guardian (school_id,pupil_id,guardian_user_id),
    KEY idx_guardian_children (guardian_user_id,school_id),
    CONSTRAINT fk_pupil_guardian_child FOREIGN KEY (pupil_id,school_id) REFERENCES pupils(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_pupil_guardian_user FOREIGN KEY (guardian_user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_pupil_guardian_linker FOREIGN KEY (linked_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_pupil_guardian_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS parent_conversations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    pupil_id BIGINT UNSIGNED NOT NULL,
    guardian_user_id BIGINT UNSIGNED NOT NULL,
    staff_user_id BIGINT UNSIGNED NOT NULL,
    status ENUM('open','closed') NOT NULL DEFAULT 'open',
    last_message_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_parent_conversation_parties (school_id,pupil_id,guardian_user_id,staff_user_id),
    UNIQUE KEY uq_parent_conversation_scope (id,school_id),
    KEY idx_parent_conversation_guardian (guardian_user_id,school_id,updated_at),
    KEY idx_parent_conversation_staff (staff_user_id,school_id,updated_at),
    CONSTRAINT fk_parent_conversation_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_parent_conversation_pupil FOREIGN KEY (pupil_id,school_id) REFERENCES pupils(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_parent_conversation_guardian FOREIGN KEY (guardian_user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_parent_conversation_staff FOREIGN KEY (staff_user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS parent_messages (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    conversation_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    sender_user_id BIGINT UNSIGNED NOT NULL,
    client_request_id CHAR(36) NOT NULL,
    message_body TEXT NOT NULL,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_parent_message_request (school_id,sender_user_id,client_request_id),
    KEY idx_parent_message_thread (conversation_id,created_at,id),
    KEY idx_parent_message_unread (school_id,sender_user_id,read_at,created_at),
    CONSTRAINT fk_parent_message_conversation FOREIGN KEY (conversation_id,school_id) REFERENCES parent_conversations(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_parent_message_sender FOREIGN KEY (sender_user_id) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pupil_accounts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    pupil_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    linked_by BIGINT UNSIGNED NOT NULL,
    revoked_by BIGINT UNSIGNED NULL,
    revoked_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_pupil_account_child (pupil_id),
    UNIQUE KEY uq_pupil_account_user (user_id),
    KEY idx_pupil_account_scope (school_id,active),
    CONSTRAINT fk_pupil_account_child FOREIGN KEY (pupil_id,school_id) REFERENCES pupils(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_pupil_account_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_pupil_account_linker FOREIGN KEY (linked_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_pupil_account_revoker FOREIGN KEY (revoked_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_pupil_account_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS homework_assignments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    teacher_id BIGINT UNSIGNED NOT NULL,
    class_level VARCHAR(80) NOT NULL,
    subject VARCHAR(100) NOT NULL,
    title VARCHAR(180) NOT NULL,
    instructions TEXT NOT NULL,
    due_date DATE NULL,
    learning_note_id BIGINT UNSIGNED NULL,
    status ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_homework_assignment_scope (id,school_id),
    KEY idx_homework_class_status_due (school_id,class_level,status,due_date),
    CONSTRAINT fk_homework_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_homework_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_homework_note FOREIGN KEY (learning_note_id) REFERENCES learning_notes(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS class_timetable_entries (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED NOT NULL,
    stream_id BIGINT UNSIGNED NULL,
    subject_id BIGINT UNSIGNED NOT NULL,
    teacher_id BIGINT UNSIGNED NOT NULL,
    day_of_week TINYINT UNSIGNED NOT NULL,
    starts_at TIME NOT NULL,
    ends_at TIME NOT NULL,
    room VARCHAR(80) NULL,
    status ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_timetable_class_day (school_id,class_id,day_of_week,status,starts_at),
    KEY idx_timetable_teacher_day (school_id,teacher_id,day_of_week,status,starts_at),
    CONSTRAINT fk_timetable_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_timetable_class FOREIGN KEY (class_id,school_id) REFERENCES school_classes(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_timetable_stream FOREIGN KEY (stream_id) REFERENCES school_streams(id) ON DELETE RESTRICT,
    CONSTRAINT fk_timetable_subject FOREIGN KEY (subject_id) REFERENCES school_class_subjects(id) ON DELETE RESTRICT,
    CONSTRAINT fk_timetable_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_timetable_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT chk_timetable_day CHECK (day_of_week BETWEEN 1 AND 7),
    CONSTRAINT chk_timetable_time CHECK (starts_at < ends_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pupil_homework_submissions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    assignment_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    pupil_id BIGINT UNSIGNED NOT NULL,
    response TEXT NOT NULL,
    status ENUM('submitted','reviewed') NOT NULL DEFAULT 'submitted',
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    feedback TEXT NULL,
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL,
    UNIQUE KEY uq_homework_pupil_submission (assignment_id,pupil_id),
    KEY idx_homework_submission_scope (school_id,assignment_id,status),
    CONSTRAINT fk_homework_submission_assignment FOREIGN KEY (assignment_id,school_id) REFERENCES homework_assignments(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_homework_submission_pupil FOREIGN KEY (pupil_id,school_id) REFERENCES pupils(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_homework_submission_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_homework_submission_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pupil_class_history (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pupil_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    class_level VARCHAR(80) NOT NULL,
    academic_year SMALLINT UNSIGNED NOT NULL,
    changed_by BIGINT UNSIGNED NOT NULL,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_class_history_pupil FOREIGN KEY (pupil_id) REFERENCES pupils(id) ON DELETE CASCADE,
    CONSTRAINT fk_class_history_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_class_history_user FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pupil_status_history (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pupil_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    previous_status ENUM('active','transferred','graduated') NOT NULL,
    new_status ENUM('active','transferred','graduated') NOT NULL,
    effective_date DATE NOT NULL,
    note VARCHAR(500) NULL,
    changed_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_pupil_status_history (school_id,pupil_id,effective_date),
    CONSTRAINT fk_pupil_status_history_pupil FOREIGN KEY (pupil_id,school_id) REFERENCES pupils(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_pupil_status_history_actor FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pupil_results (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pupil_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    class_level VARCHAR(80) NOT NULL,
    stream VARCHAR(80) NULL,
    subject VARCHAR(100) NOT NULL,
    exam_name VARCHAR(120) NOT NULL,
    assessment VARCHAR(120) NOT NULL,
    academic_year SMALLINT UNSIGNED NOT NULL,
    score DECIMAL(6,2) NOT NULL,
    max_score DECIMAL(6,2) NOT NULL,
    entered_by BIGINT UNSIGNED NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_result_class (school_id,class_level,stream,subject,academic_year),
    CONSTRAINT fk_result_pupil FOREIGN KEY (pupil_id) REFERENCES pupils(id) ON DELETE CASCADE,
    CONSTRAINT fk_result_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_result_user FOREIGN KEY (entered_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS school_exams (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED NULL,
    subject_id BIGINT UNSIGNED NULL,
    name VARCHAR(120) NOT NULL,
    academic_year SMALLINT UNSIGNED NOT NULL,
    term VARCHAR(40) NULL,
    exam_date DATE NULL,
    duration_minutes SMALLINT UNSIGNED NULL,
    instructions TEXT NULL,
    total_marks DECIMAL(7,2) NOT NULL DEFAULT 0,
    status ENUM('draft','submitted','approved','returned','scheduled','results_open','results_published','archived') NOT NULL DEFAULT 'results_open',
    created_by BIGINT UNSIGNED NOT NULL,
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL,
    review_feedback TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_school_exam_context (school_id,name,academic_year,class_id,subject_id),
    KEY idx_school_exam_status (school_id,status,exam_date),
    CONSTRAINT fk_exam_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_exam_class FOREIGN KEY (class_id) REFERENCES school_classes(id) ON DELETE RESTRICT,
    CONSTRAINT fk_exam_subject FOREIGN KEY (subject_id) REFERENCES school_class_subjects(id) ON DELETE RESTRICT,
    CONSTRAINT fk_exam_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_exam_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS result_correction_requests (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    exam_id BIGINT UNSIGNED NOT NULL,
    pupil_result_id BIGINT UNSIGNED NOT NULL,
    original_score DECIMAL(6,2) NOT NULL,
    requested_score DECIMAL(6,2) NOT NULL,
    reason VARCHAR(2000) NOT NULL,
    status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    requested_by BIGINT UNSIGNED NOT NULL,
    reviewed_by BIGINT UNSIGNED NULL,
    review_note VARCHAR(2000) NULL,
    reviewed_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_result_correction_exam (school_id,exam_id,status,created_at),
    KEY idx_result_correction_result (school_id,pupil_result_id,status),
    CONSTRAINT fk_result_correction_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_result_correction_exam FOREIGN KEY (exam_id) REFERENCES school_exams(id) ON DELETE CASCADE,
    CONSTRAINT fk_result_correction_result FOREIGN KEY (pupil_result_id) REFERENCES pupil_results(id) ON DELETE CASCADE,
    CONSTRAINT fk_result_correction_requester FOREIGN KEY (requested_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_result_correction_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT chk_result_correction_score CHECK (requested_score >= 0 AND original_score >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pupil_attendance (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    pupil_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    attendance_date DATE NOT NULL,
    attendance_status ENUM('present','absent','late','excused') NOT NULL,
    recorded_by BIGINT UNSIGNED NOT NULL,
    UNIQUE KEY uq_pupil_attendance (pupil_id,attendance_date),
    CONSTRAINT fk_attendance_pupil FOREIGN KEY (pupil_id) REFERENCES pupils(id) ON DELETE CASCADE,
    CONSTRAINT fk_attendance_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_attendance_user FOREIGN KEY (recorded_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS employee_contracts (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    terms TEXT NULL,
    status ENUM('active','ended','renewed') NOT NULL DEFAULT 'active',
    renewed_from_id BIGINT UNSIGNED NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_contract_end (school_id,end_date,status),
    UNIQUE KEY uq_contract_renewal_source (renewed_from_id),
    CONSTRAINT fk_contract_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_contract_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_contract_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_contract_renewed_from FOREIGN KEY (renewed_from_id) REFERENCES employee_contracts(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

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

CREATE TABLE IF NOT EXISTS employee_profiles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    employee_number VARCHAR(60) NULL,
    job_title VARCHAR(140) NULL,
    department VARCHAR(120) NULL,
    employment_type ENUM('full_time','part_time','casual','volunteer','contract') NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    updated_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_employee_profile_user (school_id,user_id),
    UNIQUE KEY uq_employee_number_school (school_id,employee_number),
    KEY idx_employee_profile_department (school_id,department),
    CONSTRAINT fk_employee_profile_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_employee_profile_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_employee_profile_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_employee_profile_updater FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS employee_documents (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    category ENUM('contract','qualification','identity','other') NOT NULL DEFAULT 'other',
    original_name VARCHAR(255) NOT NULL,
    stored_name CHAR(64) NOT NULL,
    mime_type VARCHAR(80) NOT NULL,
    byte_size INT UNSIGNED NOT NULL,
    uploaded_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_employee_document_file (stored_name),
    KEY idx_employee_document_user (school_id,user_id,created_at),
    CONSTRAINT fk_employee_document_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_employee_document_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_employee_document_uploader FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS staff_leave_requests (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    leave_type ENUM('annual','sick','maternity','paternity','compassionate','other') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason VARCHAR(2000) NULL,
    status ENUM('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending',
    review_note VARCHAR(1000) NULL,
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_leave_school_status (school_id,status,start_date),
    KEY idx_leave_user_dates (user_id,start_date,end_date),
    CONSTRAINT fk_leave_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_leave_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_leave_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS inventory_categories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    status ENUM('active','inactive') NOT NULL DEFAULT 'active',
    created_by BIGINT UNSIGNED NOT NULL,
    updated_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_inventory_category_name (school_id,name),
    UNIQUE KEY uq_inventory_category_scope (id,school_id),
    KEY idx_inventory_category_status (school_id,status,name),
    CONSTRAINT fk_inventory_category_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_category_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_category_updater FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS inventory_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    category_id BIGINT UNSIGNED NULL,
    item_name VARCHAR(160) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL DEFAULT 0,
    last_unit_cost DECIMAL(12,2) NULL,
    reorder_threshold DECIMAL(10,2) NULL DEFAULT NULL,
    unit VARCHAR(30) NOT NULL DEFAULT 'item',
    updated_by BIGINT UNSIGNED NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_inventory (school_id,item_name),
    UNIQUE KEY uq_inventory_item_scope (id,school_id),
    KEY idx_inventory_category (school_id,category_id),
    CONSTRAINT fk_inventory_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_category FOREIGN KEY (category_id,school_id) REFERENCES inventory_categories(id,school_id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_user FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS inventory_suppliers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(160) NOT NULL,
    contact_name VARCHAR(140) NULL,
    phone VARCHAR(40) NULL,
    email VARCHAR(190) NULL,
    status ENUM('active','inactive') NOT NULL DEFAULT 'active',
    created_by BIGINT UNSIGNED NOT NULL,
    updated_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_inventory_supplier_name (school_id,name),
    KEY idx_inventory_supplier_status (school_id,status,name),
    CONSTRAINT fk_inventory_supplier_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_supplier_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_supplier_updater FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS inventory_requests (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    request_note VARCHAR(255) NULL,
    status ENUM('pending','approved','rejected','issued','cancelled') NOT NULL DEFAULT 'pending',
    review_note VARCHAR(255) NULL,
    requested_by BIGINT UNSIGNED NOT NULL,
    reviewed_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL,
    KEY idx_inventory_request_queue (school_id,status,created_at),
    CONSTRAINT fk_inventory_request_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_request_item FOREIGN KEY (item_id) REFERENCES inventory_items(id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_requester FOREIGN KEY (requested_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS inventory_movements (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    supplier_id BIGINT UNSIGNED NULL,
    request_id BIGINT UNSIGNED NULL,
    movement_type ENUM('received','issued','adjusted') NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit_cost DECIMAL(12,2) NULL,
    balance_before DECIMAL(10,2) NULL,
    balance_after DECIMAL(10,2) NULL,
    note VARCHAR(255) NULL,
    recorded_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_inventory_movement_item (item_id, created_at),
    KEY idx_inventory_movement_supplier (school_id,supplier_id,created_at),
    UNIQUE KEY uq_inventory_request_issue (request_id),
    CONSTRAINT fk_inventory_movement_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_movement_item FOREIGN KEY (item_id) REFERENCES inventory_items(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_movement_supplier FOREIGN KEY (supplier_id) REFERENCES inventory_suppliers(id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_movement_request FOREIGN KEY (request_id) REFERENCES inventory_requests(id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_movement_user FOREIGN KEY (recorded_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS inventory_stocktakes (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    reference VARCHAR(80) NOT NULL,
    status ENUM('draft','submitted','applied','rejected') NOT NULL DEFAULT 'draft',
    note VARCHAR(1000) NULL,
    review_note VARCHAR(1000) NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL,
    applied_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_inventory_stocktake_reference (school_id,reference),
    UNIQUE KEY uq_inventory_stocktake_scope (id,school_id),
    KEY idx_inventory_stocktake_queue (school_id,status,created_at),
    CONSTRAINT fk_inventory_stocktake_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_stocktake_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_inventory_stocktake_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS inventory_stocktake_lines (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    stocktake_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    snapshot_quantity DECIMAL(10,2) NOT NULL,
    counted_quantity DECIMAL(10,2) NULL,
    line_note VARCHAR(255) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_inventory_stocktake_item (stocktake_id,item_id),
    KEY idx_inventory_stocktake_line_scope (school_id,stocktake_id),
    CONSTRAINT fk_inventory_stocktake_line_session FOREIGN KEY (stocktake_id,school_id) REFERENCES inventory_stocktakes(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_inventory_stocktake_line_item FOREIGN KEY (item_id,school_id) REFERENCES inventory_items(id,school_id) ON DELETE RESTRICT,
    CONSTRAINT chk_inventory_stocktake_count CHECK (counted_quantity IS NULL OR counted_quantity >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS school_sms_outbox (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    pupil_id BIGINT UNSIGNED NULL,
    recipient_user_id BIGINT UNSIGNED NULL,
    recipient_phone VARCHAR(30) NOT NULL,
    event_type ENUM('fee_payment','attendance_alert','exam_publication','school_announcement','fee_reminder','contract_expiry') NOT NULL,
    source_type VARCHAR(60) NOT NULL,
    source_id BIGINT UNSIGNED NOT NULL,
    message_body VARCHAR(500) NOT NULL,
    status ENUM('queued','sending','accepted','delivered','failed','undelivered','cancelled') NOT NULL DEFAULT 'queued',
    attempts TINYINT UNSIGNED NOT NULL DEFAULT 0,
    next_attempt_at TIMESTAMP NULL,
    provider_message_id VARCHAR(190) NULL,
    http_status SMALLINT UNSIGNED NULL,
    delivery_status VARCHAR(40) NULL,
    delivery_checked_at TIMESTAMP NULL,
    last_error VARCHAR(1000) NULL,
    created_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_school_sms_event_recipient (school_id,event_type,source_type,source_id,recipient_user_id),
    KEY idx_school_sms_outbox_work (status,next_attempt_at,id),
    KEY idx_school_sms_delivery_check (status,delivery_checked_at,id),
    KEY idx_school_sms_school_created (school_id,created_at),
    CONSTRAINT fk_school_sms_outbox_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_school_sms_outbox_pupil FOREIGN KEY (pupil_id) REFERENCES pupils(id) ON DELETE SET NULL,
    CONSTRAINT fk_school_sms_outbox_recipient FOREIGN KEY (recipient_user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_school_sms_outbox_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

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

CREATE TABLE IF NOT EXISTS school_fee_ledger (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    pupil_id BIGINT UNSIGNED NOT NULL,
    entry_type ENUM('charge','payment','charge_reversal','payment_reversal','discount','discount_reversal') NOT NULL,
    academic_year SMALLINT UNSIGNED NOT NULL,
    term VARCHAR(40) NOT NULL,
    description VARCHAR(180) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_method VARCHAR(40) NULL,
    reference VARCHAR(100) NULL,
    reversal_of BIGINT UNSIGNED NULL,
    reversal_reason VARCHAR(255) NULL,
    recorded_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_fee_ledger_pupil (school_id,pupil_id,academic_year,term,created_at),
    UNIQUE KEY uq_fee_reversal (reversal_of),
    UNIQUE KEY uq_fee_ledger_id_scope (id,school_id,pupil_id),
    CONSTRAINT fk_fee_ledger_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_fee_ledger_pupil FOREIGN KEY (pupil_id) REFERENCES pupils(id) ON DELETE CASCADE,
    CONSTRAINT fk_fee_ledger_user FOREIGN KEY (recorded_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_fee_ledger_reversal FOREIGN KEY (reversal_of) REFERENCES school_fee_ledger(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS fee_reconciliation_batches (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    statement_name VARCHAR(180) NOT NULL,
    statement_date DATE NOT NULL,
    status ENUM('reviewing','completed') NOT NULL DEFAULT 'reviewing',
    row_count INT UNSIGNED NOT NULL DEFAULT 0,
    matched_count INT UNSIGNED NOT NULL DEFAULT 0,
    created_by BIGINT UNSIGNED NOT NULL,
    completed_by BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    UNIQUE KEY uq_fee_reconciliation_scope (id,school_id),
    KEY idx_fee_reconciliation_school (school_id,status,statement_date),
    CONSTRAINT fk_fee_reconciliation_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_fee_reconciliation_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_fee_reconciliation_completer FOREIGN KEY (completed_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS fee_reconciliation_lines (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    batch_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    line_number INT UNSIGNED NOT NULL,
    transaction_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    reference VARCHAR(100) NOT NULL,
    description VARCHAR(255) NULL,
    matched_ledger_id BIGINT UNSIGNED NULL,
    match_status ENUM('matched','unmatched','amount_mismatch','duplicate_reference','ignored') NOT NULL DEFAULT 'unmatched',
    review_note VARCHAR(255) NULL,
    UNIQUE KEY uq_fee_reconciliation_line (batch_id,line_number),
    UNIQUE KEY uq_fee_reconciliation_ledger (school_id,matched_ledger_id),
    KEY idx_fee_reconciliation_match (school_id,reference,amount),
    CONSTRAINT fk_fee_reconciliation_batch FOREIGN KEY (batch_id,school_id) REFERENCES fee_reconciliation_batches(id,school_id) ON DELETE CASCADE,
    CONSTRAINT chk_fee_reconciliation_amount CHECK (amount > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS fee_structures (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED NOT NULL,
    academic_year SMALLINT UNSIGNED NOT NULL,
    term VARCHAR(40) NOT NULL,
    title VARCHAR(180) NOT NULL,
    status ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_fee_structure_title (school_id,class_id,academic_year,term,title),
    UNIQUE KEY uq_fee_structure_school (id,school_id),
    KEY idx_fee_structure_class (school_id,class_id,academic_year,term,status),
    CONSTRAINT fk_fee_structure_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_fee_structure_class FOREIGN KEY (class_id,school_id) REFERENCES school_classes(id,school_id) ON DELETE RESTRICT,
    CONSTRAINT fk_fee_structure_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS fee_structure_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    structure_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    sequence_no SMALLINT UNSIGNED NOT NULL,
    description VARCHAR(180) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_fee_item_sequence (structure_id,sequence_no),
    UNIQUE KEY uq_fee_item_scope (id,structure_id,school_id),
    CONSTRAINT fk_fee_item_structure FOREIGN KEY (structure_id,school_id) REFERENCES fee_structures(id,school_id) ON DELETE CASCADE,
    CONSTRAINT chk_fee_item_amount CHECK (amount > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS fee_assessments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    structure_id BIGINT UNSIGNED NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    pupil_id BIGINT UNSIGNED NOT NULL,
    ledger_entry_id BIGINT UNSIGNED NOT NULL,
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_fee_assessment_pupil_item (item_id,pupil_id),
    UNIQUE KEY uq_fee_assessment_ledger (ledger_entry_id),
    KEY idx_fee_assessment_scope (school_id,structure_id,pupil_id),
    CONSTRAINT fk_fee_assessment_structure FOREIGN KEY (structure_id,school_id) REFERENCES fee_structures(id,school_id) ON DELETE RESTRICT,
    CONSTRAINT fk_fee_assessment_item FOREIGN KEY (item_id,structure_id,school_id) REFERENCES fee_structure_items(id,structure_id,school_id) ON DELETE RESTRICT,
    CONSTRAINT fk_fee_assessment_pupil FOREIGN KEY (pupil_id,school_id) REFERENCES pupils(id,school_id) ON DELETE RESTRICT,
    CONSTRAINT fk_fee_assessment_ledger FOREIGN KEY (ledger_entry_id,school_id,pupil_id) REFERENCES school_fee_ledger(id,school_id,pupil_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS school_announcements (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(180) NOT NULL,
    body MEDIUMTEXT NOT NULL,
    audience ENUM('all','parents','pupils','staff') NOT NULL DEFAULT 'all',
    status ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
    expires_at DATE NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    published_by BIGINT UNSIGNED NULL,
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_announcement_audience (school_id,status,audience,published_at,expires_at),
    CONSTRAINT fk_announcement_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_announcement_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_announcement_publisher FOREIGN KEY (published_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pupil_report_cards (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    pupil_id BIGINT UNSIGNED NOT NULL,
    academic_year SMALLINT UNSIGNED NOT NULL,
    term VARCHAR(40) NOT NULL,
    teacher_comment TEXT NULL,
    teacher_comment_by BIGINT UNSIGNED NULL,
    teacher_comment_at TIMESTAMP NULL,
    headteacher_comment TEXT NULL,
    headteacher_comment_by BIGINT UNSIGNED NULL,
    headteacher_comment_at TIMESTAMP NULL,
    status ENUM('draft','published') NOT NULL DEFAULT 'draft',
    published_by BIGINT UNSIGNED NULL,
    published_at TIMESTAMP NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    updated_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_report_card_period (school_id,pupil_id,academic_year,term),
    KEY idx_report_card_school_status (school_id,status,academic_year,term),
    CONSTRAINT fk_report_card_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_report_card_pupil FOREIGN KEY (pupil_id,school_id) REFERENCES pupils(id,school_id) ON DELETE RESTRICT,
    CONSTRAINT fk_report_card_teacher FOREIGN KEY (teacher_comment_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_report_card_headteacher FOREIGN KEY (headteacher_comment_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_report_card_publisher FOREIGN KEY (published_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_report_card_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_report_card_updater FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS vehicles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    registration VARCHAR(30) NOT NULL,
    route_name VARCHAR(140) NOT NULL,
    driver_user_id BIGINT UNSIGNED NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE KEY uq_vehicle (school_id,registration),
    CONSTRAINT fk_vehicle_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_vehicle_driver FOREIGN KEY (driver_user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS subscriptions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    price_id BIGINT UNSIGNED NOT NULL,
    starts_on DATE NOT NULL,
    ends_on DATE NOT NULL,
    academic_year SMALLINT UNSIGNED NOT NULL,
    pupil_count INT UNSIGNED NOT NULL DEFAULT 0,
    unit_price DECIMAL(12,2) NOT NULL DEFAULT 0,
    discount_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
    status ENUM('active','pending','expired','cancelled') NOT NULL DEFAULT 'pending',
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_subscription_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_subscription_price FOREIGN KEY (price_id) REFERENCES subscription_prices(id) ON DELETE RESTRICT,
    CONSTRAINT fk_subscription_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS result_delegations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    class_level VARCHAR(80) NULL,
    academic_year SMALLINT UNSIGNED NOT NULL,
    granted_by BIGINT UNSIGNED NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_delegation_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_delegation_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_delegation_grantor FOREIGN KEY (granted_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS schemes_of_work (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED NOT NULL,
    subject_id BIGINT UNSIGNED NOT NULL,
    academic_year SMALLINT UNSIGNED NOT NULL,
    term VARCHAR(40) NOT NULL,
    curriculum VARCHAR(120) NULL,
    title VARCHAR(180) NOT NULL,
    status ENUM('draft','submitted','approved','returned','archived') NOT NULL DEFAULT 'draft',
    version SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    parent_scheme_id BIGINT UNSIGNED NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL,
    review_feedback TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_scheme_scope (school_id,class_id,subject_id,academic_year,term,status),
    CONSTRAINT fk_scheme_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_scheme_class FOREIGN KEY (class_id) REFERENCES school_classes(id) ON DELETE RESTRICT,
    CONSTRAINT fk_scheme_subject FOREIGN KEY (subject_id) REFERENCES school_class_subjects(id) ON DELETE RESTRICT,
    CONSTRAINT fk_scheme_parent FOREIGN KEY (parent_scheme_id) REFERENCES schemes_of_work(id) ON DELETE SET NULL,
    CONSTRAINT fk_scheme_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_scheme_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS scheme_topics (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    scheme_id BIGINT UNSIGNED NOT NULL,
    sequence_no SMALLINT UNSIGNED NOT NULL,
    week_number TINYINT UNSIGNED NULL,
    topic VARCHAR(180) NOT NULL,
    subtopic VARCHAR(180) NULL,
    learning_objectives TEXT NOT NULL,
    teaching_activities TEXT NULL,
    resources TEXT NULL,
    assessment_methods TEXT NULL,
    periods_planned TINYINT UNSIGNED NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_scheme_topic_order (scheme_id,sequence_no),
    CONSTRAINT fk_scheme_topic_scheme FOREIGN KEY (scheme_id) REFERENCES schemes_of_work(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS lesson_plans (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    scheme_id BIGINT UNSIGNED NOT NULL,
    stream_id BIGINT UNSIGNED NULL,
    topic_id BIGINT UNSIGNED NOT NULL,
    teacher_id BIGINT UNSIGNED NOT NULL,
    scheduled_for DATE NULL,
    title VARCHAR(180) NOT NULL,
    objectives TEXT NOT NULL,
    introduction TEXT NULL,
    activities TEXT NOT NULL,
    materials TEXT NULL,
    differentiation TEXT NULL,
    assessment TEXT NULL,
    reflection TEXT NULL,
    status ENUM('draft','submitted','approved','returned','completed') NOT NULL DEFAULT 'draft',
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL,
    review_feedback TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_lesson_id_school (id,school_id),
    KEY idx_lesson_teacher_status (school_id,teacher_id,status,scheduled_for),
    KEY idx_lesson_stream_date (school_id,stream_id,scheduled_for),
    CONSTRAINT fk_lesson_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_lesson_scheme FOREIGN KEY (scheme_id) REFERENCES schemes_of_work(id) ON DELETE RESTRICT,
    CONSTRAINT fk_lesson_stream FOREIGN KEY (stream_id) REFERENCES school_streams(id) ON DELETE RESTRICT,
    CONSTRAINT fk_lesson_topic FOREIGN KEY (topic_id) REFERENCES scheme_topics(id) ON DELETE RESTRICT,
    CONSTRAINT fk_lesson_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_lesson_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS lesson_plan_resources (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    lesson_plan_id BIGINT UNSIGNED NOT NULL,
    learning_note_id BIGINT UNSIGNED NOT NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_lesson_library_resource (lesson_plan_id,learning_note_id),
    KEY idx_lesson_resource_school (school_id,lesson_plan_id),
    CONSTRAINT fk_lesson_resource_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_lesson_resource_lesson FOREIGN KEY (lesson_plan_id,school_id) REFERENCES lesson_plans(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_lesson_resource_note FOREIGN KEY (learning_note_id) REFERENCES learning_notes(id) ON DELETE RESTRICT,
    CONSTRAINT fk_lesson_resource_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS teaching_records (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    lesson_plan_id BIGINT UNSIGNED NOT NULL,
    teacher_id BIGINT UNSIGNED NOT NULL,
    taught_on DATE NOT NULL,
    periods_delivered TINYINT UNSIGNED NOT NULL DEFAULT 1,
    coverage_note TEXT NULL,
    challenges TEXT NULL,
    intervention TEXT NULL,
    confirmed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_teaching_record_lesson (lesson_plan_id),
    KEY idx_teaching_record_coverage (school_id,teacher_id,taught_on),
    CONSTRAINT fk_teaching_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_teaching_lesson FOREIGN KEY (lesson_plan_id) REFERENCES lesson_plans(id) ON DELETE RESTRICT,
    CONSTRAINT fk_teaching_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS teacher_reports (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    teacher_id BIGINT UNSIGNED NOT NULL,
    report_type ENUM('daily','weekly','monthly','termly') NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    narrative TEXT NULL,
    challenges TEXT NULL,
    interventions TEXT NULL,
    recommendations TEXT NULL,
    activity_snapshot MEDIUMTEXT NULL,
    status ENUM('draft','submitted','approved','returned') NOT NULL DEFAULT 'draft',
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL,
    review_feedback TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_teacher_report_period (school_id,teacher_id,report_type,period_start,period_end),
    KEY idx_teacher_report_period (school_id,teacher_id,period_start,period_end,status),
    CONSTRAINT fk_teacher_report_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_teacher_report_teacher FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_teacher_report_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS question_bank (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED NOT NULL,
    subject_id BIGINT UNSIGNED NOT NULL,
    scheme_topic_id BIGINT UNSIGNED NULL,
    topic VARCHAR(180) NOT NULL,
    subtopic VARCHAR(180) NULL,
    question_type ENUM('multiple_choice','short_answer','structured','essay') NOT NULL,
    difficulty ENUM('easy','moderate','challenging') NOT NULL DEFAULT 'moderate',
    prompt LONGTEXT NOT NULL,
    options_json JSON NULL,
    model_answer LONGTEXT NULL,
    marking_guidance TEXT NULL,
    learning_objectives TEXT NULL,
    marks DECIMAL(6,2) NOT NULL DEFAULT 1.00,
    source ENUM('manual','ai') NOT NULL DEFAULT 'manual',
    status ENUM('draft','submitted','approved','returned','published','archived') NOT NULL DEFAULT 'draft',
    created_by BIGINT UNSIGNED NOT NULL,
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL,
    review_feedback TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_question_bank_scope (school_id,class_id,subject_id,status,topic),
    KEY idx_question_bank_creator (school_id,created_by,status,updated_at),
    CONSTRAINT fk_question_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_question_class FOREIGN KEY (class_id) REFERENCES school_classes(id) ON DELETE RESTRICT,
    CONSTRAINT fk_question_subject FOREIGN KEY (subject_id) REFERENCES school_class_subjects(id) ON DELETE RESTRICT,
    CONSTRAINT fk_question_scheme_topic FOREIGN KEY (scheme_topic_id) REFERENCES scheme_topics(id) ON DELETE SET NULL,
    CONSTRAINT fk_question_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_question_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT chk_question_marks CHECK (marks > 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ai_question_import_batches (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    import_key CHAR(64) NOT NULL,
    question_ids JSON NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_ai_question_import_key (school_id,created_by,import_key),
    KEY idx_ai_question_import_actor (school_id,created_by,created_at),
    CONSTRAINT fk_ai_question_import_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_ai_question_import_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS holiday_packages (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    school_id BIGINT UNSIGNED NOT NULL,
    class_id BIGINT UNSIGNED NOT NULL,
    subject_id BIGINT UNSIGNED NOT NULL,
    title VARCHAR(180) NOT NULL,
    holiday_period VARCHAR(100) NOT NULL,
    introduction TEXT NULL,
    available_from DATE NULL,
    available_until DATE NULL,
    status ENUM('draft','submitted','approved','returned','published','archived') NOT NULL DEFAULT 'draft',
    created_by BIGINT UNSIGNED NOT NULL,
    reviewed_by BIGINT UNSIGNED NULL,
    reviewed_at TIMESTAMP NULL,
    review_feedback TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_holiday_package_scope (id,school_id),
    KEY idx_holiday_package_class (school_id,class_id,status,available_from,available_until),
    CONSTRAINT fk_holiday_package_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_holiday_package_class FOREIGN KEY (class_id) REFERENCES school_classes(id) ON DELETE RESTRICT,
    CONSTRAINT fk_holiday_package_subject FOREIGN KEY (subject_id) REFERENCES school_class_subjects(id) ON DELETE RESTRICT,
    CONSTRAINT fk_holiday_package_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT fk_holiday_package_reviewer FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS holiday_package_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    package_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    sequence_no SMALLINT UNSIGNED NOT NULL,
    item_type ENUM('material','exercise','activity') NOT NULL,
    title VARCHAR(180) NOT NULL,
    instructions TEXT NULL,
    content MEDIUMTEXT NULL,
    learning_note_id BIGINT UNSIGNED NULL,
    question_id BIGINT UNSIGNED NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_holiday_item_order (package_id,sequence_no),
    KEY idx_holiday_item_package (school_id,package_id),
    CONSTRAINT fk_holiday_item_package FOREIGN KEY (package_id,school_id) REFERENCES holiday_packages(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_holiday_item_note FOREIGN KEY (learning_note_id) REFERENCES learning_notes(id) ON DELETE RESTRICT,
    CONSTRAINT fk_holiday_item_question FOREIGN KEY (question_id) REFERENCES question_bank(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS holiday_package_progress (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    package_id BIGINT UNSIGNED NOT NULL,
    school_id BIGINT UNSIGNED NOT NULL,
    pupil_id BIGINT UNSIGNED NOT NULL,
    status ENUM('assigned','in_progress','completed') NOT NULL DEFAULT 'assigned',
    pupil_response MEDIUMTEXT NULL,
    teacher_feedback TEXT NULL,
    feedback_by BIGINT UNSIGNED NULL,
    feedback_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_holiday_package_progress (package_id,pupil_id),
    KEY idx_holiday_progress_pupil (school_id,pupil_id,status),
    CONSTRAINT fk_holiday_progress_package FOREIGN KEY (package_id,school_id) REFERENCES holiday_packages(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_holiday_progress_pupil FOREIGN KEY (pupil_id,school_id) REFERENCES pupils(id,school_id) ON DELETE CASCADE,
    CONSTRAINT fk_holiday_progress_feedback FOREIGN KEY (feedback_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS exam_paper_questions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    exam_id BIGINT UNSIGNED NOT NULL,
    question_id BIGINT UNSIGNED NOT NULL,
    section_name VARCHAR(120) NOT NULL DEFAULT 'Section A',
    sequence_no SMALLINT UNSIGNED NOT NULL,
    marks DECIMAL(6,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_exam_question (exam_id,question_id),
    UNIQUE KEY uq_exam_question_order (exam_id,section_name,sequence_no),
    CONSTRAINT fk_exam_question_exam FOREIGN KEY (exam_id) REFERENCES school_exams(id) ON DELETE CASCADE,
    CONSTRAINT fk_exam_question_bank FOREIGN KEY (question_id) REFERENCES question_bank(id) ON DELETE RESTRICT,
    CONSTRAINT chk_exam_question_marks CHECK (marks > 0)
) ENGINE=InnoDB;
