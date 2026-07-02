UPDATE properties
SET
  thumbnail_url = '/uploads/properties/splash.jpg',
  image_url = '/uploads/properties/splash.jpg'
WHERE slug IN (
  'royal-merit-lodge',
  'cluster-sunrise-residence',
  'villa-green-valley',
  'ruko-prime-bisnis',
  'kost-urban-living'
)
AND (
  thumbnail_url <> '/uploads/properties/splash.jpg'
  OR image_url <> '/uploads/properties/splash.jpg'
);
