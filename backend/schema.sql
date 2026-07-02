-- Baseline schema reference. Perubahan schema baru harus dibuat lewat folder migrations/.
-- Gunakan migration runner untuk apply schema ke database target.

CREATE TABLE IF NOT EXISTS users (
  id_user BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(191) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('staf', 'admin', 'pembeli') NOT NULL DEFAULT 'pembeli',
  profile_photo_path VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_user),
  UNIQUE KEY users_email_unique (email)
);

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
  CONSTRAINT password_reset_requests_user_id_foreign FOREIGN KEY (user_id) REFERENCES users (id_user) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS properties (
  id_property BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  title VARCHAR(150) NOT NULL,
  category VARCHAR(50) NOT NULL,
  location VARCHAR(150) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'Tersedia',
  price BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_property),
  KEY properties_status_index (status)
);

CREATE TABLE IF NOT EXISTS property_gallery_images (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  property_id BIGINT UNSIGNED NOT NULL,
  image_url VARCHAR(255) NOT NULL,
  title VARCHAR(120) NOT NULL,
  subtitle VARCHAR(255) NULL,
  detail_primary VARCHAR(180) NULL,
  detail_secondary VARCHAR(180) NULL,
  sort_order SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY property_gallery_images_property_order_unique (property_id, sort_order),
  KEY property_gallery_images_property_id_index (property_id),
  CONSTRAINT property_gallery_images_property_id_foreign
    FOREIGN KEY (property_id) REFERENCES properties (id_property) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS survey_requests (
  id_survey BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  buyer_user_id BIGINT UNSIGNED NOT NULL,
  property_id BIGINT UNSIGNED NOT NULL,
  requested_date DATE NOT NULL,
  requested_time TIME NULL,
  notes TEXT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  approved_schedule_date DATE NULL,
  approved_schedule_time TIME NULL,
  rejection_reason VARCHAR(255) NULL,
  processed_by_user_id BIGINT UNSIGNED NULL,
  processed_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_survey),
  KEY survey_requests_status_index (status),
  KEY survey_requests_buyer_user_id_index (buyer_user_id),
  KEY survey_requests_property_id_index (property_id),
  KEY survey_requests_processed_by_user_id_index (processed_by_user_id),
  CONSTRAINT survey_requests_buyer_user_id_foreign
    FOREIGN KEY (buyer_user_id) REFERENCES users (id_user) ON DELETE CASCADE,
  CONSTRAINT survey_requests_property_id_foreign
    FOREIGN KEY (property_id) REFERENCES properties (id_property) ON DELETE CASCADE,
  CONSTRAINT survey_requests_processed_by_user_id_foreign
    FOREIGN KEY (processed_by_user_id) REFERENCES users (id_user) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS property_consultation_requests (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  buyer_user_id BIGINT UNSIGNED NOT NULL,
  property_id BIGINT UNSIGNED NULL,
  topic VARCHAR(100) NOT NULL,
  preferred_contact_method VARCHAR(40) NOT NULL DEFAULT 'WhatsApp',
  message TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  staff_notes TEXT NULL,
  processed_by_user_id BIGINT UNSIGNED NULL,
  processed_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY property_consultation_requests_status_index (status),
  KEY property_consultation_requests_buyer_user_id_index (buyer_user_id),
  KEY property_consultation_requests_property_id_index (property_id),
  KEY property_consultation_requests_processed_by_user_id_index (processed_by_user_id),
  CONSTRAINT property_consultation_requests_buyer_user_id_foreign
    FOREIGN KEY (buyer_user_id) REFERENCES users (id_user) ON DELETE CASCADE,
  CONSTRAINT property_consultation_requests_property_id_foreign
    FOREIGN KEY (property_id) REFERENCES properties (id_property) ON DELETE SET NULL,
  CONSTRAINT property_consultation_requests_processed_by_user_id_foreign
    FOREIGN KEY (processed_by_user_id) REFERENCES users (id_user) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS consultation_messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  consultation_id BIGINT UNSIGNED NOT NULL,
  sender_user_id BIGINT UNSIGNED NOT NULL,
  sender_name VARCHAR(100) NOT NULL,
  sender_role ENUM('staf', 'admin', 'pembeli') NOT NULL,
  message_type VARCHAR(20) NOT NULL DEFAULT 'text',
  message TEXT NOT NULL,
  media_path VARCHAR(255) NULL,
  media_name VARCHAR(160) NULL,
  media_mime VARCHAR(80) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  read_at TIMESTAMP NULL,
  PRIMARY KEY (id),
  KEY consultation_messages_consultation_id_idx (consultation_id),
  KEY consultation_messages_sender_user_id_idx (sender_user_id),
  CONSTRAINT consultation_messages_consultation_id_foreign
    FOREIGN KEY (consultation_id) REFERENCES property_consultation_requests (id) ON DELETE CASCADE,
  CONSTRAINT consultation_messages_sender_user_id_foreign
    FOREIGN KEY (sender_user_id) REFERENCES users (id_user) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(160) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(40) NOT NULL DEFAULT 'info',
  action_url VARCHAR(255) NULL,
  image_url VARCHAR(255) NULL,
  read_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY notifications_user_id_created_at_index (user_id, created_at),
  KEY notifications_user_id_read_at_index (user_id, read_at),
  CONSTRAINT notifications_user_id_foreign
    FOREIGN KEY (user_id) REFERENCES users (id_user) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_property_preferences (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  preferred_categories TEXT NOT NULL,
  preferred_location VARCHAR(150) NULL,
  min_price BIGINT UNSIGNED NULL,
  max_price BIGINT UNSIGNED NULL,
  min_bedrooms TINYINT UNSIGNED NULL,
  min_bathrooms TINYINT UNSIGNED NULL,
  min_building_area INT UNSIGNED NULL,
  min_land_area INT UNSIGNED NULL,
  notes TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY user_property_preferences_user_id_unique (user_id),
  CONSTRAINT user_property_preferences_user_id_foreign
    FOREIGN KEY (user_id) REFERENCES users (id_user) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS user_buyer_profiles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  whatsapp VARCHAR(20) NULL,
  contact_note VARCHAR(255) NULL,
  recipient_name VARCHAR(100) NULL,
  address_line VARCHAR(255) NULL,
  province VARCHAR(100) NULL,
  city VARCHAR(100) NULL,
  district VARCHAR(100) NULL,
  subdistrict VARCHAR(100) NULL,
  postal_code VARCHAR(10) NULL,
  landmark VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY user_buyer_profiles_user_id_unique (user_id),
  CONSTRAINT user_buyer_profiles_user_id_foreign
    FOREIGN KEY (user_id) REFERENCES users (id_user) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS property_purchases (
  id_purchase BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  buyer_user_id BIGINT UNSIGNED NOT NULL,
  property_id BIGINT UNSIGNED NOT NULL,
  payment_method VARCHAR(30) NOT NULL,
  buyer_name_snapshot VARCHAR(150) NOT NULL,
  buyer_phone_snapshot VARCHAR(20) NULL,
  buyer_address_snapshot TEXT NULL,
  notes TEXT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'pending_payment',
  payment_proof_path VARCHAR(500) NULL,
  payment_proof_uploaded_at DATETIME NULL,
  processed_by_user_id BIGINT UNSIGNED NULL,
  processed_by_name VARCHAR(150) NULL,
  rejection_reason VARCHAR(500) NULL,
  processed_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_purchase),
  CONSTRAINT pp_buyer_user_id_foreign FOREIGN KEY (buyer_user_id) REFERENCES users (id_user) ON DELETE CASCADE,
  CONSTRAINT pp_property_id_foreign FOREIGN KEY (property_id) REFERENCES properties (id_property) ON DELETE CASCADE,
  CONSTRAINT pp_processed_by_user_id_foreign FOREIGN KEY (processed_by_user_id) REFERENCES users (id_user) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS invoices (
  id_invoice BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  invoice_number VARCHAR(50) NOT NULL UNIQUE,
  purchase_id BIGINT UNSIGNED NOT NULL UNIQUE,
  buyer_id BIGINT UNSIGNED NOT NULL,
  property_id BIGINT UNSIGNED NOT NULL,
  property_name VARCHAR(255) NOT NULL,
  property_price DECIMAL(15,2) NOT NULL,
  payment_method VARCHAR(100) NULL,
  payment_proof_url VARCHAR(500) NULL,
  payment_status VARCHAR(50) DEFAULT 'pending',
  issued_at TIMESTAMP NULL,
  due_date DATE NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_invoice),
  CONSTRAINT fk_invoice_purchase_id FOREIGN KEY (purchase_id) REFERENCES property_purchases (id_purchase) ON DELETE CASCADE,
  CONSTRAINT fk_invoice_buyer_id FOREIGN KEY (buyer_id) REFERENCES users (id_user) ON DELETE CASCADE,
  CONSTRAINT fk_invoice_property_id FOREIGN KEY (property_id) REFERENCES properties (id_property) ON DELETE CASCADE
);

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
  CONSTRAINT fk_todo_lists_user_id FOREIGN KEY (user_id) REFERENCES users (id_user) ON DELETE CASCADE
);
