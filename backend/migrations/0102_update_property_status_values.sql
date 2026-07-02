-- Migration: Update status default value and existing values to Indonesian strings
-- Status map: available -> Tersedia, booking -> Sedang Dibooking, sold -> Terjual
-- Non-supported statuses (archived, draft) will be deleted.

-- Update existing records
UPDATE properties
SET status = 'Tersedia'
WHERE status = 'available';

UPDATE properties
SET status = 'Sedang Dibooking'
WHERE status = 'booking';

UPDATE properties
SET status = 'Terjual'
WHERE status = 'sold';

-- Delete properties with non-standard statuses (e.g. archived, draft)
DELETE FROM properties
WHERE status NOT IN ('Tersedia', 'Sedang Dibooking', 'Terjual');

-- Change table default
ALTER TABLE properties
  ALTER COLUMN status SET DEFAULT 'Tersedia';
