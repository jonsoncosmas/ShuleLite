ALTER TABLE lesson_plans
    ADD COLUMN stream_id BIGINT UNSIGNED NULL AFTER scheme_id,
    ADD KEY idx_lesson_stream_date (school_id,stream_id,scheduled_for),
    ADD CONSTRAINT fk_lesson_stream FOREIGN KEY (stream_id) REFERENCES school_streams(id) ON DELETE RESTRICT;
