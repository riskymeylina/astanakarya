CREATE TABLE IF NOT EXISTS password_reset_requests (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  code_hash VARCHAR(255) NOT NULL,
  expires_at DATETIME NOT NULL,
  verified_at DATETIME NULL,
  consumed_at DATETIME NULL,
  attempt_count INT NOT NULL DEFAULT 0,
  last_sent_at DATETIME NOT NULL,
  reset_session_token_hash VARCHAR(255) NULL,
  reset_session_expires_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY password_reset_requests_user_id_index (user_id),
  KEY password_reset_requests_expires_at_index (expires_at),
  CONSTRAINT password_reset_requests_user_id_foreign FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);
