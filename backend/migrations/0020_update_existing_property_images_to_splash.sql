START TRANSACTION;

UPDATE properties
SET thumbnail_url = '/uploads/properties/splash.jpg', image_url = '/uploads/properties/splash.jpg'
WHERE thumbnail_url LIKE '%default-thumb%' OR image_url LIKE '%default%'
   OR thumbnail_url LIKE '%Thumnails%' OR image_url LIKE '%image-inside%';

UPDATE property_gallery_images
SET image_url = '/uploads/properties/splash.jpg'
WHERE image_url LIKE '%default%' OR image_url LIKE '%Thumnails%' OR image_url LIKE '%image-inside%';

COMMIT;