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
