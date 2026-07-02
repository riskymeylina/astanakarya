-- Migration: 0030_create_todo_lists
-- Description: Create todo_lists table for Staff and Admin role

CREATE TABLE IF NOT EXISTS todo_lists (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NULL,
  status ENUM('pending', 'completed') NOT NULL DEFAULT 'pending',
  due_date DATE NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_todo_user_id (user_id),
  KEY idx_todo_status (status),
  KEY idx_todo_due_date (due_date),
  
  CONSTRAINT fk_todo_lists_user_id
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
