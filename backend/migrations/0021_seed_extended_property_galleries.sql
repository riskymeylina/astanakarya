START TRANSACTION;

-- Seed a richer gallery for each PR property using assets copied into uploads
INSERT INTO property_gallery_images (
  property_id,
  image_url,
  title,
  subtitle,
  detail_primary,
  detail_secondary,
  sort_order
)
SELECT p.id, seed.image_url, seed.title, seed.subtitle, seed.detail_primary, seed.detail_secondary, seed.sort_order
FROM properties p
JOIN (
  SELECT 'PR001' AS property_code, '/uploads/properties/splash.jpg' AS image_url, 'Tampak Depan' AS title, 'Eksterior' AS subtitle, 'Tampak depan properti' AS detail_primary, '' AS detail_secondary, 1 AS sort_order
  UNION ALL SELECT 'PR001','/uploads/properties/1.jpg','Ruang Tamu','Interior','Ruang tamu utama','','2'
  UNION ALL SELECT 'PR001','/uploads/properties/2.jpg','Kamar Tidur','Interior','Kamar tidur utama','','3'
  UNION ALL SELECT 'PR001','/uploads/properties/3.jpg','Dapur','Interior','Area dapur','','4'
  UNION ALL SELECT 'PR001','/uploads/properties/4.jpg','Kamar Mandi','Interior','Kamar mandi utama','','5'
  UNION ALL SELECT 'PR001','/uploads/properties/5.jpg','Halaman','Eksterior','Halaman belakang/ruang terbuka','','6'

  UNION ALL SELECT 'PR002','/uploads/properties/splash.jpg','Tampak Depan','Eksterior','Tampilan depan','','1'
  UNION ALL SELECT 'PR002','/uploads/properties/1.jpg','Ruang Tamu','Interior','Ruang tamu','','2'
  UNION ALL SELECT 'PR002','/uploads/properties/2.jpg','Kamar Tidur','Interior','Kamar tidur','','3'
  UNION ALL SELECT 'PR002','/uploads/properties/3.jpg','Dapur','Interior','Dapur','','4'
  UNION ALL SELECT 'PR002','/uploads/properties/4.jpg','Kamar Mandi','Interior','Kamar mandi','','5'
  UNION ALL SELECT 'PR002','/uploads/properties/5.jpg','Carport','Eksterior','Carport/garasi','','6'

  UNION ALL SELECT 'PR003','/uploads/properties/splash.jpg','Tampak Depan','Eksterior','Tampilan depan','','1'
  UNION ALL SELECT 'PR003','/uploads/properties/1.jpg','Ruang Tamu','Interior','Ruang tamu','','2'
  UNION ALL SELECT 'PR003','/uploads/properties/2.jpg','Kamar Tidur','Interior','Kamar tidur','','3'
  UNION ALL SELECT 'PR003','/uploads/properties/3.jpg','Dapur','Interior','Dapur','','4'
  UNION ALL SELECT 'PR003','/uploads/properties/4.jpg','Kamar Mandi','Interior','Kamar mandi','','5'
  UNION ALL SELECT 'PR003','/uploads/properties/5.jpg','Halaman','Eksterior','Halaman belakang','','6'

  -- Repeat pattern for other PR properties up to PR010
  UNION ALL SELECT 'PR004','/uploads/properties/splash.jpg','Tampak Depan','Eksterior','Tampilan depan','','1'
  UNION ALL SELECT 'PR004','/uploads/properties/1.jpg','Ruang Tamu','Interior','Ruang tamu','','2'
  UNION ALL SELECT 'PR004','/uploads/properties/2.jpg','Kamar Tidur','Interior','Kamar tidur','','3'
  UNION ALL SELECT 'PR004','/uploads/properties/3.jpg','Dapur','Interior','Dapur','','4'
  UNION ALL SELECT 'PR004','/uploads/properties/4.jpg','Kamar Mandi','Interior','Kamar mandi','','5'
  UNION ALL SELECT 'PR004','/uploads/properties/5.jpg','Halaman','Eksterior','Halaman','','6'

  UNION ALL SELECT 'PR005','/uploads/properties/splash.jpg','Tampak Depan','Eksterior','Tampilan depan','','1'
  UNION ALL SELECT 'PR005','/uploads/properties/1.jpg','Ruang Tamu','Interior','Ruang tamu','','2'
  UNION ALL SELECT 'PR005','/uploads/properties/2.jpg','Kamar Tidur','Interior','Kamar tidur','','3'
  UNION ALL SELECT 'PR005','/uploads/properties/3.jpg','Dapur','Interior','Dapur','','4'
  UNION ALL SELECT 'PR005','/uploads/properties/4.jpg','Kamar Mandi','Interior','Kamar mandi','','5'
  UNION ALL SELECT 'PR005','/uploads/properties/5.jpg','Carport','Eksterior','Carport/garasi','','6'

  UNION ALL SELECT 'PR006','/uploads/properties/splash.jpg','Tampak Depan','Eksterior','Tampilan depan','','1'
  UNION ALL SELECT 'PR006','/uploads/properties/1.jpg','Ruang Tamu','Interior','Ruang tamu','','2'
  UNION ALL SELECT 'PR006','/uploads/properties/2.jpg','Kamar Tidur','Interior','Kamar tidur','','3'
  UNION ALL SELECT 'PR006','/uploads/properties/3.jpg','Dapur','Interior','Dapur','','4'
  UNION ALL SELECT 'PR006','/uploads/properties/4.jpg','Kamar Mandi','Interior','Kamar mandi','','5'
  UNION ALL SELECT 'PR006','/uploads/properties/5.jpg','Halaman','Eksterior','Halaman','','6'

  UNION ALL SELECT 'PR007','/uploads/properties/splash.jpg','Tampak Depan','Eksterior','Tampilan depan','','1'
  UNION ALL SELECT 'PR007','/uploads/properties/1.jpg','Ruang Tamu','Interior','Ruang tamu','','2'
  UNION ALL SELECT 'PR007','/uploads/properties/2.jpg','Kamar Tidur','Interior','Kamar tidur','','3'
  UNION ALL SELECT 'PR007','/uploads/properties/3.jpg','Dapur','Interior','Dapur','','4'
  UNION ALL SELECT 'PR007','/uploads/properties/4.jpg','Kamar Mandi','Interior','Kamar mandi','','5'
  UNION ALL SELECT 'PR007','/uploads/properties/5.jpg','Carport','Eksterior','Carport/garasi','','6'

  UNION ALL SELECT 'PR008','/uploads/properties/splash.jpg','Tampak Depan','Eksterior','Tampilan depan','','1'
  UNION ALL SELECT 'PR008','/uploads/properties/1.jpg','Ruang Tamu','Interior','Ruang tamu','','2'
  UNION ALL SELECT 'PR008','/uploads/properties/2.jpg','Kamar Tidur','Interior','Kamar tidur','','3'
  UNION ALL SELECT 'PR008','/uploads/properties/3.jpg','Dapur','Interior','Dapur','','4'
  UNION ALL SELECT 'PR008','/uploads/properties/4.jpg','Kamar Mandi','Interior','Kamar mandi','','5'
  UNION ALL SELECT 'PR008','/uploads/properties/5.jpg','Halaman','Eksterior','Halaman','','6'

  UNION ALL SELECT 'PR009','/uploads/properties/splash.jpg','Tampak Depan','Eksterior','Tampilan depan','','1'
  UNION ALL SELECT 'PR009','/uploads/properties/1.jpg','Ruang Tamu','Interior','Ruang tamu','','2'
  UNION ALL SELECT 'PR009','/uploads/properties/2.jpg','Kamar Tidur','Interior','Kamar tidur','','3'
  UNION ALL SELECT 'PR009','/uploads/properties/3.jpg','Dapur','Interior','Dapur','','4'
  UNION ALL SELECT 'PR009','/uploads/properties/4.jpg','Kamar Mandi','Interior','Kamar mandi','','5'
  UNION ALL SELECT 'PR009','/uploads/properties/5.jpg','Carport','Eksterior','Carport/garasi','','6'

  UNION ALL SELECT 'PR010','/uploads/properties/splash.jpg','Tampak Depan','Eksterior','Tampilan depan','','1'
  UNION ALL SELECT 'PR010','/uploads/properties/1.jpg','Ruang Tamu','Interior','Ruang tamu','','2'
  UNION ALL SELECT 'PR010','/uploads/properties/2.jpg','Kamar Tidur','Interior','Kamar tidur','','3'
  UNION ALL SELECT 'PR010','/uploads/properties/3.jpg','Dapur','Interior','Dapur','','4'
  UNION ALL SELECT 'PR010','/uploads/properties/4.jpg','Kamar Mandi','Interior','Kamar mandi','','5'
  UNION ALL SELECT 'PR010','/uploads/properties/5.jpg','Halaman','Eksterior','Halaman','','6'

) AS seed
  ON seed.property_code = p.property_code
WHERE NOT EXISTS (
  SELECT 1
  FROM property_gallery_images existing
  WHERE existing.property_id = p.id
    AND existing.sort_order = seed.sort_order
);

COMMIT;
