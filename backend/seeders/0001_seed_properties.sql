-- ============================================================
-- Seeder: 0001_seed_properties
-- Description: Seed data untuk properti dan galeri gambar
-- Jalankan setelah migration schema selesai.
-- ============================================================

START TRANSACTION;

-- -----------------------------------------------
-- 1. SEED: Properties (7 rumah Astana Karya)
-- -----------------------------------------------
INSERT INTO properties (title, category, location, price, status) VALUES
  ('Astana Residence Prambanan', 'rumah', 'Tlogo, Prambanan, Klaten', 185000000, 'Tersedia'),
  ('Astana Residence Prambanan', 'rumah', 'Tlogo, Prambanan, Klaten', 245000000, 'Tersedia'),
  ('Astana Residence Prambanan', 'rumah', 'Tlogo, Prambanan, Klaten', 320000000, 'Tersedia'),
  ('Astana Green Living',        'rumah', 'Bugisan, Prambanan, Klaten', 385000000, 'Tersedia'),
  ('Astana Garden House',        'rumah', 'Kebondalem Kidul, Prambanan, Klaten', 450000000, 'Tersedia'),
  ('Astana Family Residence',    'rumah', 'Tlogo, Prambanan, Klaten', 520000000, 'Tersedia'),
  ('Astana Premium Residence',   'rumah', 'Manisrenggo, Klaten', 650000000, 'Tersedia');

-- -----------------------------------------------
-- 2. SEED: Property Gallery Images
--    Menggunakan LAST_INSERT_ID() untuk mendapatkan id properti pertama
--    lalu menghitung offset untuk masing-masing properti.
-- -----------------------------------------------
SET @first_property_id = LAST_INSERT_ID();

-- Property 1: Astana Residence Prambanan (185jt)
INSERT INTO property_gallery_images (property_id, image_url, title, subtitle, detail_primary, detail_secondary, sort_order) VALUES
  (@first_property_id + 0, 'https://plus.unsplash.com/premium_photo-1676823547752-1d24e8597047?q=80&w=1170&auto=format', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1),
  (@first_property_id + 0, 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2),
  (@first_property_id + 0, 'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=1200&q=80', 'Kamar Tidur', 'Interior', 'Kamar tidur', '', 3),
  (@first_property_id + 0, 'https://images.unsplash.com/photo-1616046229478-9901c5536a45?q=80&w=880&auto=format', 'Dapur', 'Interior', 'Dapur', '', 4),
  (@first_property_id + 0, 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?q=80&w=958&auto=format', 'Kamar Mandi', 'Interior', 'Kamar mandi', '', 5),
  (@first_property_id + 0, 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=80', 'Halaman', 'Eksterior', 'Halaman', '', 6);

-- Property 2: Astana Residence Prambanan (245jt)
INSERT INTO property_gallery_images (property_id, image_url, title, subtitle, detail_primary, detail_secondary, sort_order) VALUES
  (@first_property_id + 1, 'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1200&q=80', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1),
  (@first_property_id + 1, 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=1200&q=80', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2),
  (@first_property_id + 1, 'https://images.unsplash.com/photo-1615873968403-89e068629265?q=80&w=1032&auto=format', 'Kamar Tidur', 'Interior', 'Kamar tidur', '', 3),
  (@first_property_id + 1, 'https://plus.unsplash.com/premium_photo-1674815329488-c4fc6bf4ced8?q=80&w=1170&auto=format', 'Dapur', 'Interior', 'Dapur', '', 4),
  (@first_property_id + 1, 'https://plus.unsplash.com/premium_photo-1670360414483-64e6d9ba9038?q=80&w=1170&auto=format', 'Kamar Mandi', 'Interior', 'Kamar mandi', '', 5),
  (@first_property_id + 1, 'https://images.unsplash.com/photo-1616137422495-1e9e46e2aa77?q=80&w=1031&auto=format', 'Carport', 'Eksterior', 'Carport/garasi', '', 6);

-- Property 3: Astana Residence Prambanan (320jt)
INSERT INTO property_gallery_images (property_id, image_url, title, subtitle, detail_primary, detail_secondary, sort_order) VALUES
  (@first_property_id + 2, 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=1200&q=80', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1),
  (@first_property_id + 2, 'https://images.unsplash.com/photo-1649083048337-4aeb6dda80bb?q=80&w=1171&auto=format', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2),
  (@first_property_id + 2, 'https://images.unsplash.com/photo-1554995207-c18c203602cb?q=80&w=1170&auto=format', 'Kamar Tidur', 'Interior', 'Kamar tidur', '', 3),
  (@first_property_id + 2, 'https://images.unsplash.com/photo-1540574163026-643ea20ade25?auto=format&fit=crop&w=1200&q=80', 'Dapur', 'Interior', 'Dapur', '', 4),
  (@first_property_id + 2, 'https://images.unsplash.com/photo-1649083048337-4aeb6dda80bb?q=80&w=1171&auto=format', 'Kamar Mandi', 'Interior', 'Kamar mandi', '', 5),
  (@first_property_id + 2, 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=1200&q=80', 'Halaman', 'Eksterior', 'Halaman belakang', '', 6);

-- Property 4: Astana Green Living (385jt)
INSERT INTO property_gallery_images (property_id, image_url, title, subtitle, detail_primary, detail_secondary, sort_order) VALUES
  (@first_property_id + 3, 'https://images.unsplash.com/photo-1649083048337-4aeb6dda80bb?q=80&w=1171&auto=format', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1),
  (@first_property_id + 3, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=80', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2),
  (@first_property_id + 3, 'https://images.unsplash.com/photo-1472224371017-08207f84aaae?auto=format&fit=crop&w=1200&q=80', 'Kamar Tidur', 'Interior', 'Kamar tidur', '', 3),
  (@first_property_id + 3, 'https://images.unsplash.com/photo-1554995207-c18c203602cb?q=80&w=1170&auto=format', 'Dapur', 'Interior', 'Dapur', '', 4),
  (@first_property_id + 3, 'https://images.unsplash.com/photo-1649083048337-4aeb6dda80bb?q=80&w=1171&auto=format', 'Kamar Mandi', 'Interior', 'Kamar mandi', '', 5),
  (@first_property_id + 3, 'https://images.unsplash.com/photo-1449844908441-8829872d2607?auto=format&fit=crop&w=1200&q=80', 'Halaman', 'Eksterior', 'Halaman', '', 6);

-- Property 5: Astana Garden House (450jt)
INSERT INTO property_gallery_images (property_id, image_url, title, subtitle, detail_primary, detail_secondary, sort_order) VALUES
  (@first_property_id + 4, 'https://images.unsplash.com/photo-1554995207-c18c203602cb?q=80&w=1170&auto=format', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1),
  (@first_property_id + 4, 'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?auto=format&fit=crop&w=1200&q=80', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2),
  (@first_property_id + 4, 'https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?auto=format&fit=crop&w=1200&q=80', 'Kamar Tidur', 'Interior', 'Kamar tidur', '', 3),
  (@first_property_id + 4, 'https://images.unsplash.com/photo-1472224371017-08207f84aaae?auto=format&fit=crop&w=1200&q=80', 'Dapur', 'Interior', 'Dapur', '', 4),
  (@first_property_id + 4, 'https://images.unsplash.com/photo-1649083048337-4aeb6dda80bb?q=80&w=1171&auto=format', 'Kamar Mandi', 'Interior', 'Kamar mandi', '', 5),
  (@first_property_id + 4, 'https://images.unsplash.com/photo-1472224371017-08207f84aaae?auto=format&fit=crop&w=1200&q=80', 'Carport', 'Eksterior', 'Carport/garasi', '', 6);

-- Property 6: Astana Family Residence (520jt)
INSERT INTO property_gallery_images (property_id, image_url, title, subtitle, detail_primary, detail_secondary, sort_order) VALUES
  (@first_property_id + 5, 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=1200&q=80', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1),
  (@first_property_id + 5, 'https://images.unsplash.com/photo-1649083048428-3d8ed23a3ce0?q=80&w=1171&auto=format0', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2),
  (@first_property_id + 5, 'https://images.unsplash.com/photo-1554995207-c18c203602cb?q=80&w=1170&auto=format', 'Kamar Tidur', 'Interior', 'Kamar tidur', '', 3),
  (@first_property_id + 5, 'https://images.unsplash.com/photo-1616137466211-f939a420be84?q=80&w=1032&auto=format', 'Dapur', 'Interior', 'Dapur', '', 4),
  (@first_property_id + 5, 'https://images.unsplash.com/photo-1649083048337-4aeb6dda80bb?q=80&w=1171&auto=format', 'Kamar Mandi', 'Interior', 'Kamar mandi', '', 5),
  (@first_property_id + 5, 'https://images.unsplash.com/photo-1503174971373-b1f69850bded?q=80&w=913&auto=format', 'Halaman', 'Eksterior', 'Halaman', '', 6);

-- Property 7: Astana Premium Residence (650jt)
INSERT INTO property_gallery_images (property_id, image_url, title, subtitle, detail_primary, detail_secondary, sort_order) VALUES
  (@first_property_id + 6, 'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1200&q=80', 'Tampilan Depan', 'Visual utama properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 1),
  (@first_property_id + 6, 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80', 'Sudut Interior', 'Area dalam properti', 'Foto referensi dari aset splash', 'Gambar backend-served', 2),
  (@first_property_id + 6, 'https://images.unsplash.com/photo-1554995207-c18c203602cb?q=80&w=1170&auto=format', 'Kamar Tidur', 'Interior', 'Kamar tidur', '', 3),
  (@first_property_id + 6, 'https://images.unsplash.com/photo-1540574163026-643ea20ade25?auto=format&fit=crop&w=1200&q=80', 'Dapur', 'Interior', 'Dapur', '', 4),
  (@first_property_id + 6, 'https://images.unsplash.com/photo-1649083048337-4aeb6dda80bb?q=80&w=1171&auto=format', 'Kamar Mandi', 'Interior', 'Kamar mandi', '', 5),
  (@first_property_id + 6, 'https://images.unsplash.com/photo-1449844908441-8829872d2607?auto=format&fit=crop&w=1200&q=80', 'Carport', 'Eksterior', 'Carport/garasi', '', 6);

-- -----------------------------------------------
-- 3. SEED: Default Users (admin, staf, pembeli)
--    Password: password123 (bcrypt hash)
--    Menggunakan ID eksplisit agar konsisten dengan testing session
-- -----------------------------------------------
INSERT INTO users (id_user, name, email, phone, password_hash, role) VALUES
  (1, 'Admin', 'admin@gmail.com', '012345678901', '$2b$10$Beqsvmfn2rPP4ZucjJffB.UU1.oCWfUUfI3xqVJ.PfzF.Xmrkx4xW', 'admin'),
  (2, 'Staf',  'staf@gmail.com',  '098765432109', '$2b$10$Beqsvmfn2rPP4ZucjJffB.UU1.oCWfUUfI3xqVJ.PfzF.Xmrkx4xW', 'staf'),
  (6, 'Rony Parulian', 'roni@gmail.com', '085158266890', '$2b$10$Beqsvmfn2rPP4ZucjJffB.UU1.oCWfUUfI3xqVJ.PfzF.Xmrkx4xW', 'pembeli');

-- -----------------------------------------------
-- 4. SEED: Property Consultations
-- -----------------------------------------------
INSERT INTO property_consultation_requests (id_property_consultation_request, buyer_user_id, property_id, topic, preferred_contact_method, message, status, staff_notes, processed_by_user_id, processed_at) VALUES
  (2, 6, @first_property_id + 1, 'Simulasi KPR', 'Telepon', 'Mohon dibantu hitung simulasi KPR dan estimasi biaya awal untuk properti ini.', 'contacted', 'Sudah dihubungi dan diarahkan untuk menyiapkan dokumen penghasilan.', 2, NOW());

-- -----------------------------------------------
-- 5. SEED: Consultation Messages (Chat)
-- -----------------------------------------------
INSERT INTO consultation_messages (id_consultation_message, consultation_id, sender_user_id, sender_name, sender_role, message_type, message) VALUES
  (1, 2, 6, 'Rony Parulian', 'pembeli', 'text', 'Mohon dibantu hitung simulasi KPR dan estimasi biaya awal untuk properti ini.'),
  (2, 2, 2, 'Staf', 'staf', 'text', 'Halo Kak Rony, baik mohon ditunggu sebentar ya saya hitungkan dahulu.');

COMMIT;
