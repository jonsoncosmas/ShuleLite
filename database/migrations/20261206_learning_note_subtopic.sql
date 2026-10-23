-- Preserve existing learning material labels while renaming the field.
-- Existing title values are retained as subtopic values.
ALTER TABLE learning_notes
    CHANGE COLUMN title subtopic VARCHAR(180) NOT NULL AFTER topic;
