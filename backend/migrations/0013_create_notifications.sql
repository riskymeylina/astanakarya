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
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

INSERT INTO notifications (
  user_id,
  title,
  message,
  type,
  action_url,
  image_url,
  read_at
)
SELECT
  buyer.id,
  'Permintaan konsultasi diterima',
  'Tim Puimey sudah menerima permintaan konsultasi properti Anda dan akan segera menghubungi Anda.',
  'consultation',
  '/consultation',
  NULL,
  NULL
FROM users buyer
WHERE buyer.role = 'pembeli'
  AND buyer.id = (
    SELECT MIN(id)
    FROM users
    WHERE role = 'pembeli'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM notifications existing
    WHERE existing.user_id = buyer.id
      AND existing.title = 'Permintaan konsultasi diterima'
      AND existing.type = 'consultation'
  );

INSERT INTO notifications (
  user_id,
  title,
  message,
  type,
  action_url,
  image_url,
  read_at
)
SELECT
  buyer.id,
  'Jadwal survei sedang diproses',
  'Request survei properti Anda sedang ditinjau. Cek halaman jadwal survei untuk status terbaru.',
  'survey',
  '/buyer-survey-requests',
  NULL,
  NULL
FROM users buyer
WHERE buyer.role = 'pembeli'
  AND buyer.id = (
    SELECT MIN(id)
    FROM users
    WHERE role = 'pembeli'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM notifications existing
    WHERE existing.user_id = buyer.id
      AND existing.title = 'Jadwal survei sedang diproses'
      AND existing.type = 'survey'
  );
