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
    FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE
);

INSERT INTO property_gallery_images (
  property_id,
  image_url,
  title,
  subtitle,
  detail_primary,
  detail_secondary,
  sort_order
)
SELECT
  p.id,
  seed.image_url,
  seed.title,
  seed.subtitle,
  seed.detail_primary,
  seed.detail_secondary,
  seed.sort_order
FROM properties p
JOIN (
  SELECT 'royal-merit-lodge' AS slug, '/uploads/properties/splash.jpg' AS image_url, 'Kamar Tidur Utama' AS title, 'Area istirahat dengan pencahayaan alami' AS subtitle, 'Luas kamar 24 m2' AS detail_primary, 'Lemari built-in + AC' AS detail_secondary, 1 AS sort_order
  UNION ALL
  SELECT 'royal-merit-lodge', '/uploads/properties/splash.jpg', 'Kamar Mandi' AS title, 'Fasilitas sanitasi modern' AS subtitle, 'Luas kamar mandi 8 m2' AS detail_primary, 'Shower air panas + vanity' AS detail_secondary, 2 AS sort_order
  UNION ALL
  SELECT 'cluster-sunrise-residence', '/uploads/properties/splash.jpg', 'Ruang Keluarga' AS title, 'Area kumpul keluarga yang lega' AS subtitle, 'Konsep open space' AS detail_primary, 'Terhubung ke area makan' AS detail_secondary, 1 AS sort_order
  UNION ALL
  SELECT 'cluster-sunrise-residence', '/uploads/properties/splash.jpg', 'Kamar Mandi Dalam' AS title, 'Finishing modern minimalis' AS subtitle, 'Ventilasi alami' AS detail_primary, 'Keramik anti slip' AS detail_secondary, 2 AS sort_order
  UNION ALL
  SELECT 'villa-green-valley', '/uploads/properties/splash.jpg', 'Teras Panorama' AS title, 'View bukit dan taman hijau' AS subtitle, 'Cocok untuk area santai' AS detail_primary, 'Akses langsung dari living room' AS detail_secondary, 1 AS sort_order
  UNION ALL
  SELECT 'villa-green-valley', '/uploads/properties/splash.jpg', 'Master Bathroom' AS title, 'Nuansa resort privat' AS subtitle, 'Area kering dan basah terpisah' AS detail_primary, 'Dilengkapi water heater' AS detail_secondary, 2 AS sort_order
  UNION ALL
  SELECT 'ruko-prime-bisnis', '/uploads/properties/splash.jpg', 'Area Usaha Lantai Dasar' AS title, 'Ruang display depan jalan utama' AS subtitle, 'Lebar muka optimal' AS detail_primary, 'Akses bongkar muat mudah' AS detail_secondary, 1 AS sort_order
  UNION ALL
  SELECT 'ruko-prime-bisnis', '/uploads/properties/splash.jpg', 'Ruang Kantor' AS title, 'Area operasional staf' AS subtitle, 'Sirkulasi udara baik' AS detail_primary, 'Siap untuk jaringan internet' AS detail_secondary, 2 AS sort_order
  UNION ALL
  SELECT 'kost-urban-living', '/uploads/properties/splash.jpg', 'Kamar Kost' AS title, 'Kamar privat untuk mahasiswa/profesional' AS subtitle, 'Luas efektif 12 m2' AS detail_primary, 'Kasur + meja kerja' AS detail_secondary, 1 AS sort_order
  UNION ALL
  SELECT 'kost-urban-living', '/uploads/properties/splash.jpg', 'Kamar Mandi' AS title, 'Kamar mandi bersih dan fungsional' AS subtitle, 'Sistem air lancar' AS detail_primary, 'Dilengkapi exhaust fan' AS detail_secondary, 2 AS sort_order
) AS seed
  ON seed.slug = p.slug
WHERE NOT EXISTS (
  SELECT 1
  FROM property_gallery_images existing
  WHERE existing.property_id = p.id
    AND existing.sort_order = seed.sort_order
);
