-- Migration: Hapus semua data transaksi (property_purchases)
-- WARNING: This will permanently remove all purchase records. Run only when intended.
START TRANSACTION;

DELETE FROM property_purchases;

-- Reset auto-increment so new purchases start from 1
ALTER TABLE property_purchases AUTO_INCREMENT = 1;

COMMIT;

-- End
