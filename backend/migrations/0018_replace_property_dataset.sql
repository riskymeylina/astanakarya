START TRANSACTION;

ALTER TABLE properties
  ADD COLUMN property_code VARCHAR(20) NULL AFTER id,
  ADD COLUMN facilities TEXT NULL AFTER short_description;

CREATE TABLE IF NOT EXISTS properties_backup_20260531 LIKE properties;
INSERT INTO properties_backup_20260531 SELECT * FROM properties;

SET @thumb = '/uploads/properties/splash.jpg';
SET @image = '/uploads/properties/splash.jpg';

INSERT INTO properties (
  property_code,
  slug,
  title,
  category,
  location,
  address,
  price,
  thumbnail_url,
  image_url,
  promo_badge,
  short_description,
  facilities,
  description,
  bedrooms,
  bathrooms,
  building_area,
  land_area,
  status,
  is_featured
)
VALUES
  ('PR001', 'pr001-astana-residence-prambanan', 'Astana Residence Prambanan', 'rumah', 'Tlogo, Prambanan, Klaten', 'Tlogo, Prambanan, Klaten', 185000000, @thumb, @image, NULL, 'Rumah Tipe 36 di kawasan perumahan modern', JSON_ARRAY('Carport', 'Ruang Tamu', 'Dapur'), 'Rumah Tipe 36 dengan akses mudah ke kawasan utama Prambanan.', 2, 1, 36, 72, 'available', FALSE),
  ('PR002', 'pr002-astana-residence-prambanan', 'Astana Residence Prambanan', 'rumah', 'Tlogo, Prambanan, Klaten', 'Tlogo, Prambanan, Klaten', 245000000, @thumb, @image, NULL, 'Rumah Tipe 45 siap huni', JSON_ARRAY('Carport', 'Taman Depan', 'Dapur'), 'Rumah Tipe 45 untuk keluarga kecil dengan lingkungan yang nyaman.', 2, 1, 45, 90, 'sold', FALSE),
  ('PR003', 'pr003-astana-residence-prambanan', 'Astana Residence Prambanan', 'rumah', 'Tlogo, Prambanan, Klaten', 'Tlogo, Prambanan, Klaten', 320000000, @thumb, @image, NULL, 'Rumah Tipe 60 lega dan fungsional', JSON_ARRAY('Carport', 'Taman', 'Ruang Keluarga'), 'Rumah Tipe 60 dengan ruang keluarga lebih luas.', 3, 2, 60, 120, 'available', FALSE),
  ('PR004', 'pr004-astana-green-living', 'Astana Green Living', 'rumah', 'Bugisan, Prambanan, Klaten', 'Bugisan, Prambanan, Klaten', 385000000, @thumb, @image, NULL, 'Rumah Tipe 70 dengan sistem one gate', JSON_ARRAY('One Gate System', 'CCTV', 'Mushola'), 'Rumah Tipe 70 untuk hunian modern yang lebih aman dan tertata.', 3, 2, 70, 135, 'booking', FALSE),
  ('PR005', 'pr005-astana-garden-house', 'Astana Garden House', 'rumah', 'Kebondalem Kidul, Prambanan, Klaten', 'Kebondalem Kidul, Prambanan, Klaten', 450000000, @thumb, @image, NULL, 'Rumah Tipe 80 dengan taman belakang', JSON_ARRAY('Carport 2 Mobil', 'Taman Belakang'), 'Rumah Tipe 80 cocok untuk keluarga yang membutuhkan ruang lebih leluasa.', 3, 2, 80, 150, 'available', FALSE),
  ('PR006', 'pr006-astana-family-residence', 'Astana Family Residence', 'rumah', 'Tlogo, Prambanan, Klaten', 'Tlogo, Prambanan, Klaten', 520000000, @thumb, @image, NULL, 'Rumah Tipe 90 untuk keluarga besar', JSON_ARRAY('Carport', 'Balkon', 'Ruang Keluarga'), 'Rumah Tipe 90 dengan fasilitas lengkap untuk keluarga besar.', 4, 2, 90, 160, 'available', FALSE),
  ('PR007', 'pr007-astana-premium-residence', 'Astana Premium Residence', 'rumah', 'Manisrenggo, Klaten', 'Manisrenggo, Klaten', 650000000, @thumb, @image, NULL, 'Rumah Tipe 100 premium dan modern', JSON_ARRAY('Smart Lock Door', 'CCTV', 'Taman'), 'Rumah Tipe 100 dengan konsep premium dan keamanan modern.', 4, 3, 100, 180, 'booking', FALSE),
  ('PR008', 'pr008-astana-kost-prambanan', 'Astana Kost Prambanan', 'rumah kost', 'Dekat Stasiun Prambanan', 'Dekat Stasiun Prambanan', 950000000, @thumb, @image, NULL, 'Kost 10 kamar di lokasi strategis', JSON_ARRAY('Area Parkir', 'Wifi', 'CCTV'), 'Bangunan kost investasi dengan akses dekat stasiun.', 10, 10, 220, 250, 'available', FALSE),
  ('PR009', 'pr009-astana-business-ruko', 'Astana Business Ruko', 'ruko', 'Jalan Raya Solo–Yogyakarta', 'Jalan Raya Solo–Yogyakarta', 780000000, @thumb, @image, NULL, 'Ruko 2 lantai untuk usaha', JSON_ARRAY('Area Usaha', 'Parkir Luas'), 'Ruko strategis untuk bisnis dengan visibilitas tinggi.', 2, 2, 120, 100, 'available', FALSE),
  ('PR010', 'pr010-astana-cafe-corner', 'Astana Cafe Corner', 'bangunan usaha cafe', 'Kawasan Wisata Candi Prambanan', 'Kawasan Wisata Candi Prambanan', 850000000, @thumb, @image, NULL, 'Bangunan usaha cafe 1 lantai', JSON_ARRAY('Area Indoor', 'Outdoor', 'Parkir'), 'Bangunan usaha cafe dengan area indoor dan outdoor.', 0, 2, 140, 180, 'available', FALSE)
ON DUPLICATE KEY UPDATE
  title = VALUES(title),
  category = VALUES(category),
  location = VALUES(location),
  address = VALUES(address),
  price = VALUES(price),
  thumbnail_url = VALUES(thumbnail_url),
  image_url = VALUES(image_url),
  promo_badge = VALUES(promo_badge),
  short_description = VALUES(short_description),
  facilities = VALUES(facilities),
  description = VALUES(description),
  bedrooms = VALUES(bedrooms),
  bathrooms = VALUES(bathrooms),
  building_area = VALUES(building_area),
  land_area = VALUES(land_area),
  status = VALUES(status),
  is_featured = VALUES(is_featured);

UPDATE properties
SET status = 'archived'
WHERE property_code IS NULL
  AND slug NOT LIKE 'pr%';

COMMIT;