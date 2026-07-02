CREATE TABLE IF NOT EXISTS property_purchases (
  id                        BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  buyer_user_id             BIGINT UNSIGNED   NOT NULL,
  property_id               BIGINT UNSIGNED   NOT NULL,
  payment_method            VARCHAR(30)       NOT NULL,
  buyer_name_snapshot       VARCHAR(150)      NOT NULL,
  buyer_phone_snapshot      VARCHAR(20)       NULL,
  buyer_address_snapshot    TEXT              NULL,
  notes                     TEXT              NULL,
  status                    VARCHAR(30)       NOT NULL DEFAULT 'pending_payment',
  payment_proof_path        VARCHAR(500)      NULL,
  payment_proof_uploaded_at DATETIME          NULL,
  processed_by_user_id      BIGINT UNSIGNED   NULL,
  processed_by_name         VARCHAR(150)      NULL,
  rejection_reason          VARCHAR(500)      NULL,
  processed_at              DATETIME          NULL,
  created_at                TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at                TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  KEY pp_buyer_user_id_index        (buyer_user_id),
  KEY pp_property_id_index          (property_id),
  KEY pp_status_index               (status),
  KEY pp_processed_by_user_id_index (processed_by_user_id),

  CONSTRAINT pp_buyer_user_id_foreign
    FOREIGN KEY (buyer_user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT pp_property_id_foreign
    FOREIGN KEY (property_id)  REFERENCES properties (id) ON DELETE CASCADE,
  CONSTRAINT pp_processed_by_user_id_foreign
    FOREIGN KEY (processed_by_user_id) REFERENCES users (id) ON DELETE SET NULL
);
