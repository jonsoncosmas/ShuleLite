CREATE TABLE IF NOT EXISTS ai_provider_settings (
    id TINYINT UNSIGNED NOT NULL PRIMARY KEY,
    provider VARCHAR(40) NOT NULL DEFAULT 'openrouter',
    model VARCHAR(160) NOT NULL DEFAULT 'openai/gpt-4o-mini',
    api_key_ciphertext TEXT NOT NULL,
    updated_by BIGINT UNSIGNED NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_ai_provider_settings_user FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;
