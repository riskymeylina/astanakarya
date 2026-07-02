-- Migration: 0026_create_admin_activity_logs
-- Description: Activity logging for admin dashboard and audit trails

CREATE TABLE IF NOT EXISTS admin_activity_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  action_type VARCHAR(100) NOT NULL,
  description VARCHAR(500) NULL,
  entity_type VARCHAR(50) NULL,
  entity_id BIGINT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_user_id (user_id),
  KEY idx_action_type (action_type),
  KEY idx_entity_type_id (entity_type, entity_id),
  KEY idx_created_at (created_at),

  CONSTRAINT fk_activity_logs_user_id
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
