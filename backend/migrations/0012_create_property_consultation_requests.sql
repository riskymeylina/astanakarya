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
    FOREIGN KEY (buyer_user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT property_consultation_requests_property_id_foreign
    FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE SET NULL,
  CONSTRAINT property_consultation_requests_processed_by_user_id_foreign
    FOREIGN KEY (processed_by_user_id) REFERENCES users (id) ON DELETE SET NULL
);

INSERT INTO property_consultation_requests (
  buyer_user_id,
  property_id,
  topic,
  preferred_contact_method,
  message,
  status,
  staff_notes,
  processed_by_user_id,
  processed_at
)
SELECT
  buyer.id AS buyer_user_id,
  pending_property.id AS property_id,
  'Cari rumah sesuai budget' AS topic,
  'WhatsApp' AS preferred_contact_method,
  'Saya ingin konsultasi pilihan rumah keluarga dengan budget sekitar dua miliar dan akses sekolah yang dekat.' AS message,
  'pending' AS status,
  NULL AS staff_notes,
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
    FROM property_consultation_requests existing
    WHERE existing.buyer_user_id = buyer.id
      AND existing.property_id = pending_property.id
      AND existing.topic = 'Cari rumah sesuai budget'
      AND existing.status = 'pending'
  );

INSERT INTO property_consultation_requests (
  buyer_user_id,
  property_id,
  topic,
  preferred_contact_method,
  message,
  status,
  staff_notes,
  processed_by_user_id,
  processed_at
)
SELECT
  buyer.id AS buyer_user_id,
  contacted_property.id AS property_id,
  'Simulasi KPR' AS topic,
  'Telepon' AS preferred_contact_method,
  'Mohon dibantu hitung simulasi KPR dan estimasi biaya awal untuk properti ini.' AS message,
  'contacted' AS status,
  'Sudah dihubungi dan diarahkan untuk menyiapkan dokumen penghasilan.' AS staff_notes,
  staff.id AS processed_by_user_id,
  NOW() AS processed_at
FROM users buyer
JOIN (
  SELECT id
  FROM users
  WHERE role IN ('staf', 'admin')
  ORDER BY id ASC
  LIMIT 1
) staff ON 1 = 1
JOIN (
  SELECT id
  FROM properties
  WHERE slug = 'villa-green-valley'
  ORDER BY id ASC
  LIMIT 1
) contacted_property ON 1 = 1
WHERE buyer.role = 'pembeli'
  AND buyer.id = (
    SELECT MIN(id)
    FROM users
    WHERE role = 'pembeli'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM property_consultation_requests existing
    WHERE existing.buyer_user_id = buyer.id
      AND existing.property_id = contacted_property.id
      AND existing.topic = 'Simulasi KPR'
      AND existing.status = 'contacted'
  );
