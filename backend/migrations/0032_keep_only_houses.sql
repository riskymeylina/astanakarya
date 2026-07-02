START TRANSACTION;

-- Delete consultation requests that reference properties that are not 'rumah'
DELETE FROM property_consultation_requests 
WHERE property_id IN (SELECT id FROM properties WHERE category <> 'rumah');

-- Delete properties where category is not 'rumah'
-- This cascades automatically to: property_purchases, invoices, survey_requests, property_gallery_images, property_images, and property_extended_details.
DELETE FROM properties WHERE category <> 'rumah';

COMMIT;
