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
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

INSERT INTO user_property_preferences (
  user_id,
  preferred_categories,
  preferred_location,
  min_price,
  max_price,
  min_bedrooms,
  min_bathrooms,
  min_building_area,
  min_land_area,
  notes
)
SELECT
  buyer.id AS user_id,
  JSON_ARRAY('Rumah', 'Villa') AS preferred_categories,
  'Bandung' AS preferred_location,
  500000000 AS min_price,
  2500000000 AS max_price,
  2 AS min_bedrooms,
  2 AS min_bathrooms,
  70 AS min_building_area,
  90 AS min_land_area,
  'Mencari properti siap huni dengan akses jalan utama yang mudah.' AS notes
FROM users buyer
WHERE buyer.role = 'pembeli'
  AND buyer.id = (
    SELECT MIN(id)
    FROM users
    WHERE role = 'pembeli'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM user_property_preferences existing
    WHERE existing.user_id = buyer.id
  );
