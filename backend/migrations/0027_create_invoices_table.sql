-- Migration: 0027_create_invoices_table
-- Description: Store invoice information for transactions

CREATE TABLE IF NOT EXISTS invoices (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  invoice_number VARCHAR(50) NOT NULL UNIQUE,
  purchase_id BIGINT UNSIGNED NOT NULL UNIQUE,
  buyer_id BIGINT UNSIGNED NOT NULL,
  property_id BIGINT UNSIGNED NOT NULL,
  property_name VARCHAR(255) NOT NULL,
  property_price DECIMAL(15,2) NOT NULL,
  payment_method VARCHAR(100) NULL,
  payment_proof_url VARCHAR(500) NULL,
  payment_status VARCHAR(50) DEFAULT 'pending',
  issued_at TIMESTAMP NULL,
  due_date DATE NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY idx_invoice_number (invoice_number),
  KEY idx_purchase_id (purchase_id),
  KEY idx_buyer_id (buyer_id),
  KEY idx_property_id (property_id),
  KEY idx_issued_at (issued_at),

  CONSTRAINT fk_invoice_purchase_id
    FOREIGN KEY (purchase_id) REFERENCES property_purchases (id) ON DELETE CASCADE,
  CONSTRAINT fk_invoice_buyer_id
    FOREIGN KEY (buyer_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_invoice_property_id
    FOREIGN KEY (property_id) REFERENCES properties (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
