START TRANSACTION;

-- Normalize gallery images by title/role so each slot shows a distinct representative image

-- Tampak Depan / Exterior -> splash/home
UPDATE property_gallery_images
SET image_url = '/uploads/properties/splash.jpg'
WHERE LOWER(title) LIKE '%tampak depan%'
   OR LOWER(title) LIKE '%tampilan depan%'
   OR LOWER(subtitle) LIKE '%eksterior%'
   OR sort_order = 1;

-- Ruang Tamu / Interior -> 1.jpg
UPDATE property_gallery_images
SET image_url = '/uploads/properties/1.jpg'
WHERE LOWER(title) LIKE '%ruang tamu%'
   OR LOWER(subtitle) LIKE '%interior%'
   AND sort_order = 2;

-- Kamar Tidur -> 2.jpg
UPDATE property_gallery_images
SET image_url = '/uploads/properties/2.jpg'
WHERE LOWER(title) LIKE '%kamar tidur%'
   OR LOWER(title) LIKE '%kamar%'
   AND sort_order = 3;

-- Dapur -> 3.jpg
UPDATE property_gallery_images
SET image_url = '/uploads/properties/3.jpg'
WHERE LOWER(title) LIKE '%dapur%'
   OR LOWER(subtitle) LIKE '%dapur%'
   AND sort_order = 4;

-- Kamar Mandi -> Unsplash (already set by previous migration, keep as is)

-- Halaman / Garden -> 4.jpg
UPDATE property_gallery_images
SET image_url = '/uploads/properties/4.jpg'
WHERE LOWER(title) LIKE '%halaman%'
   OR LOWER(title) LIKE '%taman%'
   OR LOWER(subtitle) LIKE '%eksterior%'
   AND sort_order = 6;

-- Carport / Garasi -> 5.jpg
UPDATE property_gallery_images
SET image_url = '/uploads/properties/5.jpg'
WHERE LOWER(title) LIKE '%carport%'
   OR LOWER(title) LIKE '%garasi%'
   OR LOWER(subtitle) LIKE '%carport%'
   OR LOWER(subtitle) LIKE '%garasi%';

COMMIT;
