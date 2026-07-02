ALTER TABLE property_purchases
  ADD COLUMN payment_account_number VARCHAR(50) NULL AFTER payment_method,
  ADD COLUMN payment_account_name VARCHAR(150) NULL AFTER payment_account_number,
  ADD COLUMN payment_amount BIGINT UNSIGNED NULL AFTER payment_account_name,
  ADD COLUMN payment_due_at DATETIME NULL AFTER payment_amount,
  ADD COLUMN cancelled_at DATETIME NULL AFTER payment_due_at;

CREATE INDEX pp_payment_due_at_index ON property_purchases (payment_due_at);
