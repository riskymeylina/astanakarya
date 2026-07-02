CREATE TABLE IF NOT EXISTS survey_requests (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
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
  PRIMARY KEY (id),
  KEY survey_requests_status_index (status),
  KEY survey_requests_buyer_user_id_index (buyer_user_id),
  KEY survey_requests_property_id_index (property_id),
  KEY survey_requests_processed_by_user_id_index (processed_by_user_id),
  CONSTRAINT survey_requests_buyer_user_id_foreign
    FOREIGN KEY (buyer_user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT survey_requests_property_id_foreign
    FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE,
  CONSTRAINT survey_requests_processed_by_user_id_foreign
    FOREIGN KEY (processed_by_user_id) REFERENCES users (id) ON DELETE SET NULL
);

INSERT INTO survey_requests (
  buyer_user_id,
  property_id,
  requested_date,
  requested_time,
  notes,
  status,
  approved_schedule_date,
  approved_schedule_time,
  rejection_reason,
  processed_by_user_id,
  processed_at
)
SELECT
  buyer.id AS buyer_user_id,
  pending_property.id AS property_id,
  DATE_ADD(CURDATE(), INTERVAL 2 DAY) AS requested_date,
  '10:00:00' AS requested_time,
  'Saya ingin melihat kondisi rumah dan area sekitar pada pagi hari.' AS notes,
  'pending' AS status,
  NULL AS approved_schedule_date,
  NULL AS approved_schedule_time,
  NULL AS rejection_reason,
  NULL AS processed_by_user_id,
  NULL AS processed_at
FROM users buyer
JOIN (
  SELECT id
  FROM properties
  WHERE slug = 'cluster-sunrise-residence'
  ORDER BY id ASC
  LIMIT 1
) pending_property ON 1 = 1
WHERE buyer.role = 'pembeli'
  AND buyer.id = (
    SELECT MIN(id)
    FROM users
    WHERE role = 'pembeli'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM survey_requests existing
    WHERE existing.buyer_user_id = buyer.id
      AND existing.property_id = pending_property.id
      AND existing.requested_date = DATE_ADD(CURDATE(), INTERVAL 2 DAY)
      AND existing.requested_time = '10:00:00'
      AND existing.status = 'pending'
  );

INSERT INTO survey_requests (
  buyer_user_id,
  property_id,
  requested_date,
  requested_time,
  notes,
  status,
  approved_schedule_date,
  approved_schedule_time,
  rejection_reason,
  processed_by_user_id,
  processed_at
)
SELECT
  buyer.id AS buyer_user_id,
  approved_property.id AS property_id,
  DATE_ADD(CURDATE(), INTERVAL 3 DAY) AS requested_date,
  '13:00:00' AS requested_time,
  'Mohon jadwal siang karena saya datang dari luar kota.' AS notes,
  'approved' AS status,
  DATE_ADD(CURDATE(), INTERVAL 4 DAY) AS approved_schedule_date,
  '14:00:00' AS approved_schedule_time,
  NULL AS rejection_reason,
  marketing.id AS processed_by_user_id,
  NOW() AS processed_at
FROM users buyer
JOIN (
  SELECT id
  FROM users
  WHERE role IN ('staf', 'admin')
  ORDER BY id ASC
  LIMIT 1
) marketing ON 1 = 1
JOIN (
  SELECT id
  FROM properties
  WHERE slug = 'villa-green-valley'
  ORDER BY id ASC
  LIMIT 1
) approved_property ON 1 = 1
WHERE buyer.role = 'pembeli'
  AND buyer.id = (
    SELECT MIN(id)
    FROM users
    WHERE role = 'pembeli'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM survey_requests existing
    WHERE existing.buyer_user_id = buyer.id
      AND existing.property_id = approved_property.id
      AND existing.requested_date = DATE_ADD(CURDATE(), INTERVAL 3 DAY)
      AND existing.requested_time = '13:00:00'
      AND existing.status = 'approved'
  );

INSERT INTO survey_requests (
  buyer_user_id,
  property_id,
  requested_date,
  requested_time,
  notes,
  status,
  approved_schedule_date,
  approved_schedule_time,
  rejection_reason,
  processed_by_user_id,
  processed_at
)
SELECT
  buyer.id AS buyer_user_id,
  rejected_property.id AS property_id,
  DATE_ADD(CURDATE(), INTERVAL 1 DAY) AS requested_date,
  '16:00:00' AS requested_time,
  'Saya hanya bisa survei sore hari setelah jam kerja.' AS notes,
  'rejected' AS status,
  NULL AS approved_schedule_date,
  NULL AS approved_schedule_time,
  'Jadwal sore penuh, silakan ajukan ulang pada slot pagi atau siang.' AS rejection_reason,
  marketing.id AS processed_by_user_id,
  NOW() AS processed_at
FROM users buyer
JOIN (
  SELECT id
  FROM users
  WHERE role IN ('staf', 'admin')
  ORDER BY id ASC
  LIMIT 1
) marketing ON 1 = 1
JOIN (
  SELECT id
  FROM properties
  WHERE slug = 'ruko-prime-bisnis'
  ORDER BY id ASC
  LIMIT 1
) rejected_property ON 1 = 1
WHERE buyer.role = 'pembeli'
  AND buyer.id = (
    SELECT MIN(id)
    FROM users
    WHERE role = 'pembeli'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM survey_requests existing
    WHERE existing.buyer_user_id = buyer.id
      AND existing.property_id = rejected_property.id
      AND existing.requested_date = DATE_ADD(CURDATE(), INTERVAL 1 DAY)
      AND existing.requested_time = '16:00:00'
      AND existing.status = 'rejected'
  );
