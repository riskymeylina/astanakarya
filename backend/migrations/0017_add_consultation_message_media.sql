ALTER TABLE consultation_messages
  ADD COLUMN message_type VARCHAR(20) NOT NULL DEFAULT 'text' AFTER sender_role,
  ADD COLUMN media_path VARCHAR(255) NULL AFTER message,
  ADD COLUMN media_name VARCHAR(160) NULL AFTER media_path,
  ADD COLUMN media_mime VARCHAR(80) NULL AFTER media_name;
