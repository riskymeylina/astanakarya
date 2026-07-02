START TRANSACTION;

-- Replace gallery images for items titled 'Kamar Mandi' with online Unsplash bathroom images
UPDATE property_gallery_images
SET image_url = 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1200&q=80'
WHERE LOWER(title) LIKE '%kamar mandi%';

-- Also update any gallery subtitle mentioning bathroom (defensive)
UPDATE property_gallery_images
SET image_url = 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1200&q=80'
WHERE LOWER(subtitle) LIKE '%kamar mandi%';

COMMIT;
