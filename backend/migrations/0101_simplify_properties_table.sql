-- Migration: Sederhanakan tabel properties menjadi hanya 8 kolom inti
-- Kolom yang dipertahankan: id, title, category, location, status, price, created_at, updated_at

-- Hapus kolom-kolom yang tidak diperlukan
ALTER TABLE properties
  DROP COLUMN property_code,
  DROP COLUMN slug,
  DROP COLUMN cluster_name,
  DROP COLUMN address,
  DROP COLUMN google_maps_link,
  DROP COLUMN thumbnail_url,
  DROP COLUMN image_url,
  DROP COLUMN promo_badge,
  DROP COLUMN short_description,
  DROP COLUMN facilities,
  DROP COLUMN description,
  DROP COLUMN bedrooms,
  DROP COLUMN bathrooms,
  DROP COLUMN ruang_tamu,
  DROP COLUMN dapur,
  DROP COLUMN garasi,
  DROP COLUMN carport,
  DROP COLUMN sertifikat,
  DROP COLUMN daya_listrik,
  DROP COLUMN tahun_dibangun,
  DROP COLUMN hadap_rumah,
  DROP COLUMN sumber_air,
  DROP COLUMN fasilitas_tambahan,
  DROP COLUMN building_area,
  DROP COLUMN land_area,
  DROP COLUMN is_featured,
  DROP COLUMN is_draft;
