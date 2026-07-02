const pool = require('../config/db');

const PAYMENT_ACCOUNT_NUMBER = String(process.env.PAYMENT_ACCOUNT_NUMBER || '1234567890').trim();
const PAYMENT_ACCOUNT_NAME = String(process.env.PAYMENT_ACCOUNT_NAME || 'PT. Astana Karya Bandawasa').trim();
const PAYMENT_BANK_NOTE = String(process.env.PAYMENT_BANK_NOTE || 'Bank BCA').trim();
const PAYMENT_DEADLINE_DAYS = 3;

const SELECT_COLUMNS = `
  pp.id_purchase AS id,
  pp.buyer_user_id,
  pp.property_id,
  pp.payment_method,
  pp.payment_account_number,
  pp.payment_account_name,
  pp.payment_amount,
  pp.payment_due_at,
  pp.cancelled_at,
  pp.buyer_name_snapshot,
  pp.buyer_phone_snapshot,
  pp.buyer_address_snapshot,
  pp.notes,
  pp.status,
  pp.payment_proof_path,
  pp.payment_proof_uploaded_at,
  pp.processed_by_user_id,
  pp.processed_by_name,
  pp.rejection_reason,
  pp.processed_at,
  pp.created_at,
  pp.updated_at,
  p.title    AS property_title,
  p.location AS property_location,
  (SELECT image_url FROM property_gallery_images WHERE property_id = p.id_property ORDER BY sort_order ASC, id_property_gallery_image ASC LIMIT 1) AS property_thumbnail_url,
  p.price    AS property_price
`;

const BASE_JOIN = `
  FROM property_purchases pp
  INNER JOIN properties p ON p.id_property = pp.property_id
`;

async function findPurchaseById(id) {
  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLUMNS} ${BASE_JOIN} WHERE pp.id_purchase = ? LIMIT 1`,
    [id],
  );
  return rows[0] || null;
}

async function cancelOverduePendingPayments() {
  const [overdue] = await pool.execute(
    `SELECT DISTINCT property_id FROM property_purchases
     WHERE status = 'pending_payment'
       AND payment_due_at IS NOT NULL
       AND payment_due_at < NOW()`,
  );

  if (overdue.length > 0) {
    const ids = overdue.map((r) => r.property_id);
    for (const pid of ids) {
      await pool.execute(
        `UPDATE properties SET status = 'Tersedia', updated_at = CURRENT_TIMESTAMP WHERE id_property = ?`,
        [pid],
      );
    }
  }

  await pool.execute(
    `UPDATE property_purchases
     SET status = 'cancelled',
         cancelled_at = COALESCE(cancelled_at, NOW())
     WHERE status = 'pending_payment'
       AND payment_due_at IS NOT NULL
       AND payment_due_at < NOW()`,
  );
}

async function findPurchasesByBuyerId(buyerUserId) {
  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLUMNS} ${BASE_JOIN}
     WHERE pp.buyer_user_id = ?
     ORDER BY FIELD(pp.status,
       'pending_payment',
       'payment_uploaded',
       'payment_review',
       'confirmed',
       'rejected',
       'cancelled'
     ), pp.created_at DESC`,
    [buyerUserId],
  );
  return rows;
}

function addDateFilters({ conditions, params, from, to, month, year }) {
  const dateExpression = 'DATE(COALESCE(pp.processed_at, pp.updated_at, pp.created_at))';

  if (from) {
    conditions.push(`${dateExpression} >= ?`);
    params.push(from);
  }

  if (to) {
    conditions.push(`${dateExpression} <= ?`);
    params.push(to);
  }

  if (month) {
    conditions.push('MONTH(COALESCE(pp.processed_at, pp.updated_at, pp.created_at)) = ?');
    params.push(month);
  }

  if (year) {
    conditions.push('YEAR(COALESCE(pp.processed_at, pp.updated_at, pp.created_at)) = ?');
    params.push(year);
  }
}

async function findAllPurchases({ status, from, to, month, year } = {}) {
  const params = [];
  const conditions = [];

  if (status) {
    conditions.push('pp.status = ?');
    params.push(status);
  }

  addDateFilters({ conditions, params, from, to, month, year });

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLUMNS} ${BASE_JOIN}
     ${whereClause}
     ORDER BY FIELD(pp.status,
       'pending_payment',
       'payment_uploaded',
       'payment_review',
       'confirmed',
       'rejected',
       'cancelled'
     ), pp.created_at DESC`,
    params,
  );
  return rows;
}

async function createPurchase({
  buyerUserId,
  propertyId,
  paymentMethod,
  buyerNameSnapshot,
  buyerPhoneSnapshot,
  buyerAddressSnapshot,
  notes,
}) {
  const [result] = await pool.execute(
    `INSERT INTO property_purchases (
       buyer_user_id, property_id, payment_method,
       payment_account_number, payment_account_name, payment_amount, payment_due_at,
       buyer_name_snapshot, buyer_phone_snapshot, buyer_address_snapshot,
       notes, status
     )
     SELECT ?, ?, ?, ?, ?, p.price, DATE_ADD(NOW(), INTERVAL ? DAY), ?, ?, ?, ?, 'pending_payment'
     FROM properties p
     WHERE p.id_property = ?`,
    [
      buyerUserId,
      propertyId,
      paymentMethod,
      PAYMENT_ACCOUNT_NUMBER,
      PAYMENT_ACCOUNT_NAME,
      PAYMENT_DEADLINE_DAYS,
      buyerNameSnapshot,
      buyerPhoneSnapshot || null,
      buyerAddressSnapshot || null,
      notes || null,
      propertyId,
    ],
  );

  await pool.execute(
    `UPDATE properties SET status = 'Sedang Dibooking', updated_at = CURRENT_TIMESTAMP WHERE id_property = ?`,
    [propertyId]
  );

  return findPurchaseById(result.insertId);
}

async function setPaymentProof({ id, paymentProofPath }) {
  await pool.execute(
    `UPDATE property_purchases
     SET status = 'payment_uploaded',
         payment_proof_path = ?,
         payment_proof_uploaded_at = NOW()
     WHERE id_purchase = ? AND status = 'pending_payment'`,
    [paymentProofPath, id],
  );
  return findPurchaseById(id);
}

async function updatePurchaseStatus({
  id,
  status,
  rejectionReason,
  processedByUserId,
  processedByName,
}) {
  await pool.execute(
    `UPDATE property_purchases
     SET status = ?,
         rejection_reason = ?,
         processed_by_user_id = ?,
         processed_by_name = ?,
         processed_at = NOW()
     WHERE id_purchase = ?`,
    [status, rejectionReason || null, processedByUserId, processedByName, id],
  );

  const purchase = await findPurchaseById(id);
  if (purchase) {
    let propertyStatus = 'Tersedia';
    if (status === 'confirmed') {
      propertyStatus = 'Terjual';
    } else if (status === 'pending_payment' || status === 'payment_uploaded' || status === 'payment_review') {
      propertyStatus = 'Sedang Dibooking';
    } else if (status === 'rejected' || status === 'cancelled') {
      propertyStatus = 'Tersedia';
    }

    await pool.execute(
      `UPDATE properties SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id_property = ?`,
      [propertyStatus, purchase.property_id],
    );
  }

  return purchase;
}

async function findPropertyForPurchase(propertyId) {
  const [rows] = await pool.execute(
    `SELECT id_property AS id, title, location, status FROM properties WHERE id_property = ? LIMIT 1`,
    [propertyId],
  );
  return rows[0] || null;
}

async function findBuyerProfile(userId) {
  const [rows] = await pool.execute(
    `SELECT u.name,
            ubp.whatsapp,
            ubp.recipient_name,
            ubp.address_line,
            ubp.district,
            ubp.city,
            ubp.province,
            ubp.postal_code
     FROM users u
     LEFT JOIN user_buyer_profiles ubp ON ubp.user_id = u.id_user
     WHERE u.id_user = ?
     LIMIT 1`,
    [userId],
  );
  return rows[0] || null;
}

module.exports = {
  findPurchaseById,
  cancelOverduePendingPayments,
  findPurchasesByBuyerId,
  findAllPurchases,
  createPurchase,
  setPaymentProof,
  updatePurchaseStatus,
  findPropertyForPurchase,
  findBuyerProfile,
  PAYMENT_BANK_NOTE,
};
