UPDATE properties
SET
  price = 750000000,
  promo_badge = 'Promo Penjualan Perdana',
  short_description = 'Hunian villa privat dengan interior hangat dan suasana lingkungan yang tenang.',
  description = 'Royal Merit Lodge adalah villa siap beli dengan konsep kamar modern hangat, sentuhan kayu premium, dan akses cepat ke destinasi kuliner Ubud. Cocok untuk keluarga, investor properti, dan pembeli yang mencari aset bernilai di lokasi strategis.'
WHERE slug = 'royal-merit-lodge';

UPDATE properties
SET
  description = 'Villa Green Valley cocok untuk keluarga yang mengutamakan kenyamanan tinggal dan pertumbuhan nilai aset jangka panjang. Memiliki panorama hijau, area semi outdoor, dan suasana resort yang tenang.'
WHERE slug = 'villa-green-valley';

UPDATE properties
SET
  price = 1850000000,
  promo_badge = 'Investasi Kos Produktif',
  short_description = 'Kos modern dengan potensi investasi yang stabil di area kampus.',
  description = 'Kost Urban Living menawarkan bangunan kos siap beli dengan akses internet cepat, sistem keamanan area, dan jarak dekat ke kampus serta pusat kuliner Cimahi. Cocok untuk investor yang mencari aset produktif dan bernilai jual kembali.'
WHERE slug = 'kost-urban-living';