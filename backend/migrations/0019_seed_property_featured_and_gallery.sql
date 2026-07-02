START TRANSACTION;

UPDATE properties
SET is_featured = TRUE
WHERE property_code IN ('PR001', 'PR003', 'PR009');

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
  SELECT 'PR001' AS property_code, '/uploads/properties/splash.jpg' AS image_url, 'Tampilan Depan' AS title, 'Visual utama properti' AS subtitle, 'Foto referensi dari aset splash' AS detail_primary, 'Gambar backend-served' AS detail_secondary, 1 AS sort_order
  UNION ALL
  SELECT 'PR001', '/uploads/properties/splash.jpg', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2 AS sort_order
  UNION ALL
  SELECT 'PR002', '/uploads/properties/splash.jpg', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1 AS sort_order
  UNION ALL
  SELECT 'PR002', '/uploads/properties/splash.jpg', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2 AS sort_order
  UNION ALL
  SELECT 'PR003', '/uploads/properties/splash.jpg', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1 AS sort_order
  UNION ALL
  SELECT 'PR003', '/uploads/properties/splash.jpg', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2 AS sort_order
  UNION ALL
  SELECT 'PR004', '/uploads/properties/splash.jpg', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1 AS sort_order
  UNION ALL
  SELECT 'PR004', '/uploads/properties/splash.jpg', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2 AS sort_order
  UNION ALL
  SELECT 'PR005', '/uploads/properties/splash.jpg', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1 AS sort_order
  UNION ALL
  SELECT 'PR005', '/uploads/properties/splash.jpg', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2 AS sort_order
  UNION ALL
  SELECT 'PR006', '/uploads/properties/splash.jpg', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1 AS sort_order
  UNION ALL
  SELECT 'PR006', '/uploads/properties/splash.jpg', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2 AS sort_order
  UNION ALL
  SELECT 'PR007', '/uploads/properties/splash.jpg', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1 AS sort_order
  UNION ALL
  SELECT 'PR007', '/uploads/properties/splash.jpg', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2 AS sort_order
  UNION ALL
  SELECT 'PR008', '/uploads/properties/splash.jpg', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1 AS sort_order
  UNION ALL
  SELECT 'PR008', '/uploads/properties/splash.jpg', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2 AS sort_order
  UNION ALL
  SELECT 'PR009', '/uploads/properties/splash.jpg', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1 AS sort_order
  UNION ALL
  SELECT 'PR009', '/uploads/properties/splash.jpg', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2 AS sort_order
  UNION ALL
  SELECT 'PR010', '/uploads/properties/splash.jpg', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1 AS sort_order
  UNION ALL
  SELECT 'PR010', '/uploads/properties/splash.jpg', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2 AS sort_order
) AS seed
  ON seed.property_code = p.property_code
WHERE NOT EXISTS (
  SELECT 1
  FROM property_gallery_images existing
  WHERE existing.property_id = p.id
    AND existing.sort_order = seed.sort_order
);

COMMIT;