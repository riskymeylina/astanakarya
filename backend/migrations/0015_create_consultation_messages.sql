CREATE TABLE IF NOT EXISTS consultation_messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  consultation_id BIGINT UNSIGNED NOT NULL,
  sender_user_id BIGINT UNSIGNED NOT NULL,
  sender_name VARCHAR(100) NOT NULL,
  sender_role ENUM('staf', 'admin', 'pembeli') NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY consultation_messages_consultation_id_idx (consultation_id),
  KEY consultation_messages_sender_user_id_idx (sender_user_id),
  CONSTRAINT consultation_messages_consultation_id_foreign
    FOREIGN KEY (consultation_id) REFERENCES property_consultation_requests (id) ON DELETE CASCADE,
  CONSTRAINT consultation_messages_sender_user_id_foreign
    FOREIGN KEY (sender_user_id) REFERENCES users (id) ON DELETE CASCADE
);
