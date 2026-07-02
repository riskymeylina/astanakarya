ALTER TABLE consultation_messages
  ADD COLUMN read_at TIMESTAMP NULL AFTER created_at;
