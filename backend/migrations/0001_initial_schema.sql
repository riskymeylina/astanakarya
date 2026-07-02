-- ============================================================
-- Migration: 0001_initial_schema
-- Description: Consolidated initial schema for Astana Karya
-- Combines all previous migrations (0001–0105) into one file
-- reflecting the final database state.
-- ============================================================

-- -----------------------------------------------
-- 1. USERS
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id_user BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(191) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('staf', 'admin', 'pembeli') NOT NULL DEFAULT 'pembeli',
  profile_photo_path VARCHAR(255) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_user),
  UNIQUE KEY users_email_unique (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------
-- 2. PASSWORD RESET REQUESTS
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS password_reset_requests (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  token VARCHAR(64) NOT NULL,
  otp_code VARCHAR(6) NOT NULL,
  otp_verified TINYINT(1) NOT NULL DEFAULT 0,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY password_reset_requests_token_unique (token),
  KEY password_reset_requests_user_id_index (user_id),
  CONSTRAINT password_reset_requests_user_id_foreign
    FOREIGN KEY (user_id) REFERENCES users (id_user) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------
-- 3. PROPERTIES
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS properties (
  id_property BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  title VARCHAR(150) NOT NULL,
  category VARCHAR(50) NOT NULL DEFAULT 'rumah',
  location VARCHAR(200) NOT NULL,
  price BIGINT UNSIGNED NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'Tersedia',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_property)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------
-- 4. PROPERTY GALLERY IMAGES
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS property_gallery_images (
  id_property_gallery_image BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  property_id BIGINT UNSIGNED NOT NULL,
  image_url VARCHAR(500) NOT NULL,
  title VARCHAR(100) NULL,
  subtitle VARCHAR(150) NULL,
  detail_primary VARCHAR(255) NULL,
  detail_secondary VARCHAR(255) NULL,
  sort_order SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_property_gallery_image),
  KEY property_gallery_images_property_id_index (property_id),
  CONSTRAINT property_gallery_images_property_id_foreign
    FOREIGN KEY (property_id) REFERENCES properties (id_property) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------
-- 5. PROPERTY IMAGES (additional image store)
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS property_images (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  property_id BIGINT UNSIGNED NOT NULL,
  image_url VARCHAR(255) NOT NULL,
  display_order SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  is_primary TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY property_images_property_id_index (property_id),
  CONSTRAINT property_images_property_id_foreign
    FOREIGN KEY (property_id) REFERENCES properties (id_property) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------
-- 6. SURVEY REQUESTS
-- -----------------------------------------------
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------
-- 7. USER PROPERTY PREFERENCES
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS user_property_preferences (
  id_user_property_preference BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
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
  PRIMARY KEY (id_user_property_preference),
  UNIQUE KEY user_property_preferences_user_id_unique (user_id),
  CONSTRAINT user_property_preferences_user_id_foreign
    FOREIGN KEY (user_id) REFERENCES users (id_user) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------
-- 8. USER BUYER PROFILES
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS user_buyer_profiles (
  id_user_buyer_profile BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
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
  PRIMARY KEY (id_user_buyer_profile),
  UNIQUE KEY user_buyer_profiles_user_id_unique (user_id),
  CONSTRAINT user_buyer_profiles_user_id_foreign
    FOREIGN KEY (user_id) REFERENCES users (id_user) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------
-- 9. PROPERTY PURCHASES
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS property_purchases (
  id_purchase BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  buyer_user_id BIGINT UNSIGNED NOT NULL,
  property_id BIGINT UNSIGNED NOT NULL,
  payment_method VARCHAR(30) NOT NULL,
  payment_account_number VARCHAR(50) NULL,
  payment_account_name VARCHAR(150) NULL,
  payment_amount BIGINT UNSIGNED NULL,
  payment_due_at DATETIME NULL,
  cancelled_at DATETIME NULL,
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
  KEY pp_buyer_user_id_index (buyer_user_id),
  KEY pp_property_id_index (property_id),
  KEY pp_status_index (status),
  KEY pp_processed_by_user_id_index (processed_by_user_id),
  KEY pp_payment_due_at_index (payment_due_at),
  CONSTRAINT pp_buyer_user_id_foreign
    FOREIGN KEY (buyer_user_id) REFERENCES users (id_user) ON DELETE CASCADE,
  CONSTRAINT pp_property_id_foreign
    FOREIGN KEY (property_id) REFERENCES properties (id_property) ON DELETE CASCADE,
  CONSTRAINT pp_processed_by_user_id_foreign
    FOREIGN KEY (processed_by_user_id) REFERENCES users (id_user) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------
-- 10. PROPERTY CONSULTATION REQUESTS
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS property_consultation_requests (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  buyer_user_id BIGINT UNSIGNED NOT NULL,
  property_id BIGINT UNSIGNED NULL,
  subject VARCHAR(150) NOT NULL,
  message TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  rejection_reason VARCHAR(255) NULL,
  processed_by_user_id BIGINT UNSIGNED NULL,
  processed_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY pcr_buyer_user_id_index (buyer_user_id),
  KEY pcr_property_id_index (property_id),
  KEY pcr_status_index (status),
  KEY pcr_processed_by_user_id_index (processed_by_user_id),
  CONSTRAINT property_consultation_requests_buyer_user_id_foreign
    FOREIGN KEY (buyer_user_id) REFERENCES users (id_user) ON DELETE CASCADE,
  CONSTRAINT property_consultation_requests_property_id_foreign
    FOREIGN KEY (property_id) REFERENCES properties (id_property) ON DELETE SET NULL,
  CONSTRAINT property_consultation_requests_processed_by_user_id_foreign
    FOREIGN KEY (processed_by_user_id) REFERENCES users (id_user) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------
-- 11. CONSULTATION MESSAGES
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS consultation_messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  consultation_id BIGINT UNSIGNED NOT NULL,
  sender_user_id BIGINT UNSIGNED NOT NULL,
  message TEXT NOT NULL,
  media_url VARCHAR(500) NULL,
  media_type VARCHAR(20) NULL,
  read_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY cm_consultation_id_index (consultation_id),
  KEY cm_sender_user_id_index (sender_user_id),
  CONSTRAINT consultation_messages_consultation_id_foreign
    FOREIGN KEY (consultation_id) REFERENCES property_consultation_requests (id) ON DELETE CASCADE,
  CONSTRAINT consultation_messages_sender_user_id_foreign
    FOREIGN KEY (sender_user_id) REFERENCES users (id_user) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------
-- 12. NOTIFICATIONS
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  type VARCHAR(50) NOT NULL,
  title VARCHAR(150) NOT NULL,
  message TEXT NOT NULL,
  reference_type VARCHAR(50) NULL,
  reference_id BIGINT UNSIGNED NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY notifications_user_id_index (user_id),
  KEY notifications_type_index (type),
  KEY notifications_is_read_index (is_read),
  CONSTRAINT notifications_user_id_foreign
    FOREIGN KEY (user_id) REFERENCES users (id_user) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------
-- 13. INVOICES
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS invoices (
  id_invoice BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  invoice_number VARCHAR(50) NOT NULL,
  purchase_id BIGINT UNSIGNED NOT NULL,
  buyer_id BIGINT UNSIGNED NOT NULL,
  property_id BIGINT UNSIGNED NOT NULL,
  amount BIGINT UNSIGNED NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'unpaid',
  due_date DATE NULL,
  paid_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_invoice),
  UNIQUE KEY invoices_invoice_number_unique (invoice_number),
  KEY fk_invoice_purchase_id (purchase_id),
  KEY fk_invoice_buyer_id (buyer_id),
  KEY fk_invoice_property_id (property_id),
  CONSTRAINT fk_invoice_purchase_id
    FOREIGN KEY (purchase_id) REFERENCES property_purchases (id_purchase) ON DELETE CASCADE,
  CONSTRAINT fk_invoice_buyer_id
    FOREIGN KEY (buyer_id) REFERENCES users (id_user) ON DELETE CASCADE,
  CONSTRAINT fk_invoice_property_id
    FOREIGN KEY (property_id) REFERENCES properties (id_property) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- -----------------------------------------------
-- 14. TODO LISTS
-- -----------------------------------------------
CREATE TABLE IF NOT EXISTS todo_lists (
  id_todo_list BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  description TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  status ENUM('pending', 'completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  due_date DATE NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id_todo_list),
  KEY idx_todo_user_id (user_id),
  KEY idx_todo_status (status),
  KEY idx_todo_due_date (due_date),
  CONSTRAINT fk_todo_lists_user_id
    FOREIGN KEY (user_id) REFERENCES users (id_user) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
