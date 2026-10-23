-- Preserve existing learning material labels while renaming the field.
-- Existing title values are retained as subtitle values.
ALTER TABLE learning_notes
    CHANGE COLUMN title subtitle VARCHAR(180) NOT NULL AFTER topic;
