ALTER TABLE sms_delivery_logs
    ADD COLUMN delivery_status VARCHAR(40) NULL AFTER provider_message_id,
    ADD COLUMN status_checked_at TIMESTAMP NULL AFTER delivery_status,
    ADD COLUMN status_check_diagnostic TEXT NULL AFTER status_checked_at;
