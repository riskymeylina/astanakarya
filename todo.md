# TODO: Fitur yang Belum Terimplementasi

Daftar ini hanya memuat fitur yang masih belum selesai, masih stub, atau masih parsial berdasarkan kondisi kode saat ini. Item yang sudah selesai seperti revisi metode pembayaran, konfirmasi pesanan, informasi pembayaran, invoice transaksi PDF/print/share, UI transaksi staf/admin, Marketing screen dasar, Buyer Administration, Consultation Detail, Purchase Detail, Home Search/Filter/Explore, Pengaturan, dan Help tidak dicantumkan lagi.

## Auth

- [ ] Implementasikan login Google dan Facebook.
  - Status: Stub.
  - Role terdampak: pembeli, staf, admin.
  - Bukti: `lib/screens/auth/login_screen.dart`.
  - Catatan: tombol social login masih memanggil handler `_handleSocialLogin()` yang menampilkan pesan "Login ... belum tersedia". Belum ada integrasi OAuth/Firebase/social provider, callback, token exchange, atau mapping user role.

## Admin

- [ ] Implementasikan export/cetak laporan admin ke file atau print native.
  - Status: Parsial.
  - Role terdampak: admin.
  - Bukti: `lib/screens/admin/admin_pages.dart`, `lib/services/admin_report_service.dart`.
  - Catatan: laporan global, sales, dan availability sudah tampil di aplikasi, tetapi belum ada generate PDF/Excel/CSV, share file, atau print native untuk laporan. Invoice transaksi sudah memiliki PDF/print/share terpisah dan tidak termasuk TODO ini.

- [ ] Lengkapi CRUD properti admin untuk upload media dan gallery.
  - Status: Parsial.
  - Role terdampak: admin.
  - Bukti: `lib/screens/admin/admin_pages.dart`, `backend/src/controllers/propertyController.js`, `backend/src/services/propertyService.js`.
  - Catatan: CRUD dasar properti sudah ada, tetapi form admin masih mempertahankan `thumbnailUrl` dan `imageUrl` lama saat simpan. Belum ada input upload thumbnail, upload image utama, upload/gallery multi-image, preview media, hapus/reorder gallery, atau endpoint upload media khusus dari form admin.

## Marketing / Staf Pemasaran

- [ ] Lengkapi Konfirmasi Ketersediaan Properti dengan aksi update status.
  - Status: Parsial.
  - Role terdampak: staf/marketing.
  - Bukti: `lib/screens/property/marketing_property_availability_page.dart`.
  - Catatan: halaman menampilkan properti dan tombol `Lihat Detail`, tetapi belum ada aksi staf untuk mengubah status properti menjadi `available`, `reserved`, `sold`, atau `archived`. Belum ada dialog konfirmasi status, catatan perubahan, atau refresh setelah update status.

- [ ] Batasi data Marketing "Saya" ke transaksi yang ditugaskan ke staf terkait.
  - Status: Belum ada assignment/filter staf.
  - Role terdampak: staf/marketing, admin.
  - Bukti: `lib/screens/purchases/marketing_orders_page.dart`, `lib/screens/purchases/marketing_transaction_recap_page.dart`, `backend/src/services/purchaseService.js`.
  - Catatan: halaman marketing saat ini memakai data semua order. Belum ada field assignment/owner staf pada transaksi, endpoint filter order milik staf tertentu, ataupun UI admin untuk assign/reassign order ke staf.

## Notifications

- [ ] Lengkapi routing action notification untuk semua `actionUrl` backend.
  - Status: Parsial.
  - Role terdampak: pembeli, staf, admin.
  - Bukti: `lib/screens/notifications/notifications_page.dart`, `backend/src/controllers/notificationController.js`.
  - Catatan: backend dan frontend baru mengenali beberapa path utama (`/consultation`, `/buyer-survey-requests`, `/purchase-status`, `/home`). Route lain seperti detail purchase, detail survey, admin/staf screens, dan detail konsultasi masih belum punya mapping action URL yang lengkap.

- [ ] Implementasikan push notification delivery native/realtime.
  - Status: Belum ada integrasi push delivery.
  - Role terdampak: pembeli, staf, admin.
  - Bukti: `lib/screens/notifications/notifications_page.dart`, `backend/src/routes/notificationRoutes.js`.
  - Catatan: inbox dan permission notification sudah ada, tetapi belum terlihat integrasi FCM/APNs, device token registration, topic/subscription, background handler, atau realtime delivery. Notifikasi masih berbasis fetch/inbox aplikasi.

## Testing / Quality

- [ ] Perbaiki smoke test Flutter bawaan.
  - Status: Gagal.
  - Bukti: `test/widget_test.dart`.
  - Catatan: `flutter test` gagal karena test masih mencari counter template teks "0", sementara aplikasi sudah bukan counter app. Test perlu diganti menjadi smoke test aplikasi nyata, misalnya memastikan `MyApp` render, route login/home tersedia, atau halaman awal tidak crash.

- [ ] Investigasi crash Flutter/Dart analyzer.
  - Status: Tooling crash/intermiten.
  - Bukti: `flutter_11.log`, `flutter_12.log`, hasil `flutter analyze` / `dart analyze` sebelumnya.
  - Catatan: analyzer pernah crash dengan analysis server exit code 255 dan library cycle/link exception. `flutter build web --no-pub` berhasil, tetapi analyzer tetap perlu dicek ulang setelah dependency dan generated plugin berubah.
