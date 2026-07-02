-- Migration: 0105_rename_table_primary_keys
-- Description: Rename primary keys on users, properties, property_purchases, invoices

SET FOREIGN_KEY_CHECKS = 0;

-- 1. Drop existing foreign key constraints
ALTER TABLE password_reset_requests DROP FOREIGN KEY password_reset_requests_user_id_foreign;
ALTER TABLE property_gallery_images DROP FOREIGN KEY property_gallery_images_property_id_foreign;

ALTER TABLE survey_requests DROP FOREIGN KEY survey_requests_buyer_user_id_foreign;
ALTER TABLE survey_requests DROP FOREIGN KEY survey_requests_property_id_foreign;
ALTER TABLE survey_requests DROP FOREIGN KEY survey_requests_processed_by_user_id_foreign;

ALTER TABLE property_consultation_requests DROP FOREIGN KEY property_consultation_requests_buyer_user_id_foreign;
ALTER TABLE property_consultation_requests DROP FOREIGN KEY property_consultation_requests_property_id_foreign;
ALTER TABLE property_consultation_requests DROP FOREIGN KEY property_consultation_requests_processed_by_user_id_foreign;

ALTER TABLE consultation_messages DROP FOREIGN KEY consultation_messages_sender_user_id_foreign;
ALTER TABLE notifications DROP FOREIGN KEY notifications_user_id_foreign;
ALTER TABLE user_property_preferences DROP FOREIGN KEY user_property_preferences_user_id_foreign;
ALTER TABLE user_buyer_profiles DROP FOREIGN KEY user_buyer_profiles_user_id_foreign;

ALTER TABLE property_purchases DROP FOREIGN KEY pp_buyer_user_id_foreign;
ALTER TABLE property_purchases DROP FOREIGN KEY pp_property_id_foreign;
ALTER TABLE property_purchases DROP FOREIGN KEY pp_processed_by_user_id_foreign;

ALTER TABLE invoices DROP FOREIGN KEY fk_invoice_purchase_id;
ALTER TABLE invoices DROP FOREIGN KEY fk_invoice_buyer_id;
ALTER TABLE invoices DROP FOREIGN KEY fk_invoice_property_id;

ALTER TABLE todo_lists DROP FOREIGN KEY fk_todo_lists_user_id;

-- 2. Rename primary keys on tables
ALTER TABLE users CHANGE COLUMN id id_user BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
ALTER TABLE properties CHANGE COLUMN id id_property BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
ALTER TABLE property_purchases CHANGE COLUMN id id_purchase BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
ALTER TABLE invoices CHANGE COLUMN id id_invoice BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;

-- 3. Re-create foreign key constraints referencing the new primary key names
ALTER TABLE password_reset_requests ADD CONSTRAINT password_reset_requests_user_id_foreign
  FOREIGN KEY (user_id) REFERENCES users (id_user) ON DELETE CASCADE;

ALTER TABLE property_gallery_images ADD CONSTRAINT property_gallery_images_property_id_foreign
  FOREIGN KEY (property_id) REFERENCES properties (id_property) ON DELETE CASCADE;

ALTER TABLE survey_requests ADD CONSTRAINT survey_requests_buyer_user_id_foreign
  FOREIGN KEY (buyer_user_id) REFERENCES users (id_user) ON DELETE CASCADE;
ALTER TABLE survey_requests ADD CONSTRAINT survey_requests_property_id_foreign
  FOREIGN KEY (property_id) REFERENCES properties (id_property) ON DELETE CASCADE;
ALTER TABLE survey_requests ADD CONSTRAINT survey_requests_processed_by_user_id_foreign
  FOREIGN KEY (processed_by_user_id) REFERENCES users (id_user) ON DELETE SET NULL;

ALTER TABLE property_consultation_requests ADD CONSTRAINT property_consultation_requests_buyer_user_id_foreign
  FOREIGN KEY (buyer_user_id) REFERENCES users (id_user) ON DELETE CASCADE;
ALTER TABLE property_consultation_requests ADD CONSTRAINT property_consultation_requests_property_id_foreign
  FOREIGN KEY (property_id) REFERENCES properties (id_property) ON DELETE SET NULL;
ALTER TABLE property_consultation_requests ADD CONSTRAINT property_consultation_requests_processed_by_user_id_foreign
  FOREIGN KEY (processed_by_user_id) REFERENCES users (id_user) ON DELETE SET NULL;

ALTER TABLE consultation_messages ADD CONSTRAINT consultation_messages_sender_user_id_foreign
  FOREIGN KEY (sender_user_id) REFERENCES users (id_user) ON DELETE CASCADE;

ALTER TABLE notifications ADD CONSTRAINT notifications_user_id_foreign
  FOREIGN KEY (user_id) REFERENCES users (id_user) ON DELETE CASCADE;

ALTER TABLE user_property_preferences ADD CONSTRAINT user_property_preferences_user_id_foreign
  FOREIGN KEY (user_id) REFERENCES users (id_user) ON DELETE CASCADE;

ALTER TABLE user_buyer_profiles ADD CONSTRAINT user_buyer_profiles_user_id_foreign
  FOREIGN KEY (user_id) REFERENCES users (id_user) ON DELETE CASCADE;

ALTER TABLE property_purchases ADD CONSTRAINT pp_buyer_user_id_foreign
  FOREIGN KEY (buyer_user_id) REFERENCES users (id_user) ON DELETE CASCADE;
ALTER TABLE property_purchases ADD CONSTRAINT pp_property_id_foreign
  FOREIGN KEY (property_id) REFERENCES properties (id_property) ON DELETE CASCADE;
ALTER TABLE property_purchases ADD CONSTRAINT pp_processed_by_user_id_foreign
  FOREIGN KEY (processed_by_user_id) REFERENCES users (id_user) ON DELETE SET NULL;

ALTER TABLE invoices ADD CONSTRAINT fk_invoice_purchase_id
  FOREIGN KEY (purchase_id) REFERENCES property_purchases (id_purchase) ON DELETE CASCADE;
ALTER TABLE invoices ADD CONSTRAINT fk_invoice_buyer_id
  FOREIGN KEY (buyer_id) REFERENCES users (id_user) ON DELETE CASCADE;
ALTER TABLE invoices ADD CONSTRAINT fk_invoice_property_id
  FOREIGN KEY (property_id) REFERENCES properties (id_property) ON DELETE CASCADE;

ALTER TABLE todo_lists ADD CONSTRAINT fk_todo_lists_user_id
  FOREIGN KEY (user_id) REFERENCES users (id_user) ON DELETE CASCADE;

SET FOREIGN_KEY_CHECKS = 1;
