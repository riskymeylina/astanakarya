START TRANSACTION;

-- Assign unique local thumbnails/images per property (using files copied into uploads)
UPDATE properties SET thumbnail_url = '/uploads/properties/1.jpg', image_url = '/uploads/properties/1.jpg' WHERE property_code = 'PR001';
UPDATE properties SET thumbnail_url = '/uploads/properties/2.jpg', image_url = '/uploads/properties/2.jpg' WHERE property_code = 'PR002';
UPDATE properties SET thumbnail_url = '/uploads/properties/3.jpg', image_url = '/uploads/properties/3.jpg' WHERE property_code = 'PR003';
UPDATE properties SET thumbnail_url = '/uploads/properties/4.jpg', image_url = '/uploads/properties/4.jpg' WHERE property_code = 'PR004';
UPDATE properties SET thumbnail_url = '/uploads/properties/5.jpg', image_url = '/uploads/properties/5.jpg' WHERE property_code = 'PR005';
UPDATE properties SET thumbnail_url = '/uploads/properties/home.jpg', image_url = '/uploads/properties/home.jpg' WHERE property_code = 'PR006';
UPDATE properties SET thumbnail_url = '/uploads/properties/splash.jpg', image_url = '/uploads/properties/splash.jpg' WHERE property_code = 'PR007';
UPDATE properties SET thumbnail_url = '/uploads/properties/1.jpg', image_url = '/uploads/properties/1.jpg' WHERE property_code = 'PR008';
UPDATE properties SET thumbnail_url = '/uploads/properties/2.jpg', image_url = '/uploads/properties/2.jpg' WHERE property_code = 'PR009';
UPDATE properties SET thumbnail_url = '/uploads/properties/3.jpg', image_url = '/uploads/properties/3.jpg' WHERE property_code = 'PR010';

-- Replace interior gallery images with curated Unsplash links per role
-- Living room / Ruang Tamu
UPDATE property_gallery_images
SET image_url = 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=1200&q=80'
WHERE LOWER(title) LIKE '%ruang tamu%'
   OR LOWER(subtitle) LIKE '%ruang tamu%'
   OR sort_order = 2;

-- Bedroom / Kamar Tidur
UPDATE property_gallery_images
SET image_url = 'https://images.unsplash.com/photo-1505691723518-36a5d4a4b3b1?auto=format&fit=crop&w=1200&q=80'
WHERE LOWER(title) LIKE '%kamar tidur%'
   OR (LOWER(title) LIKE '%kamar%' AND LOWER(title) NOT LIKE '%kamar mandi%')
   OR sort_order = 3;

-- Kitchen / Dapur
UPDATE property_gallery_images
SET image_url = 'https://images.unsplash.com/photo-1556911220-e15b29be8c11?auto=format&fit=crop&w=1200&q=80'
WHERE LOWER(title) LIKE '%dapur%'
   OR LOWER(subtitle) LIKE '%dapur%'
   OR sort_order = 4;

-- Bathroom kept as Unsplash from previous migration; ensure matches
UPDATE property_gallery_images
SET image_url = 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1200&q=80'
WHERE LOWER(title) LIKE '%kamar mandi%'
   OR LOWER(subtitle) LIKE '%kamar mandi%';

-- Garden / Halaman
UPDATE property_gallery_images
SET image_url = 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=80'
WHERE LOWER(title) LIKE '%halaman%'
   OR LOWER(title) LIKE '%taman%'
   OR sort_order = 6;

-- Carport / Garasi
UPDATE property_gallery_images
SET image_url = 'https://images.unsplash.com/photo-1524758631624-e2822e304c36?auto=format&fit=crop&w=1200&q=80'
WHERE LOWER(title) LIKE '%carport%'
   OR LOWER(title) LIKE '%garasi%'
   OR LOWER(subtitle) LIKE '%carport%'
   OR LOWER(subtitle) LIKE '%garasi%';

COMMIT;
