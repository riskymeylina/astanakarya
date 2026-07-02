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
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);
