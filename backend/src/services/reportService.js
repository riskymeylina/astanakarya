const pool = require('../config/db');
const purchaseService = require('./purchaseService');

function applyDateFilters({ conditions, params, from, to, month, year, alias = 'pp' }) {
  const dateExpression = `DATE(COALESCE(${alias}.processed_at, ${alias}.updated_at, ${alias}.created_at))`;

  if (from) {
    conditions.push(`${dateExpression} >= ?`);
    params.push(from);
  }

  if (to) {
    conditions.push(`${dateExpression} <= ?`);
    params.push(to);
  }

  if (month) {
    conditions.push(`MONTH(COALESCE(${alias}.processed_at, ${alias}.updated_at, ${alias}.created_at)) = ?`);
    params.push(month);
  }

  if (year) {
    conditions.push(`YEAR(COALESCE(${alias}.processed_at, ${alias}.updated_at, ${alias}.created_at)) = ?`);
    params.push(year);
  }
}

function buildDateConditions({ from, to, month, year } = {}) {
  const conditions = [`pp.status = 'confirmed'`];
  const params = [];
  applyDateFilters({ conditions, params, from, to, month, year });

  return { conditions, params };
}

async function getSalesReport({ from, to, month, year } = {}) {
  const { conditions, params } = buildDateConditions({ from, to, month, year });
  const whereClause = `WHERE ${conditions.join(' AND ')}`;

  const [rows] = await pool.execute(
    `SELECT pp.id_purchase AS id,
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
            p.title AS property_title,
            p.location AS property_location,
            (SELECT image_url FROM property_gallery_images WHERE property_id = p.id_property ORDER BY sort_order ASC, id_property_gallery_image ASC LIMIT 1) AS property_thumbnail_url,
            p.price AS property_price
     FROM property_purchases pp
     INNER JOIN properties p ON p.id_property = pp.property_id
     ${whereClause}
     ORDER BY COALESCE(pp.processed_at, pp.updated_at, pp.created_at) DESC`,
    params,
  );

  const totalRevenue = rows.reduce((total, row) => total + Number(row.property_price || 0), 0);
  return { rows, totalRevenue };
}

async function getAvailabilityReport({ from, to, month, year } = {}) {
  const propertyConditions = [];
  const propertyParams = [];

  if (from) {
    propertyConditions.push('DATE(updated_at) >= ?');
    propertyParams.push(from);
  }

  if (to) {
    propertyConditions.push('DATE(updated_at) <= ?');
    propertyParams.push(to);
  }

  if (month) {
    propertyConditions.push('MONTH(updated_at) = ?');
    propertyParams.push(month);
  }

  if (year) {
    propertyConditions.push('YEAR(updated_at) = ?');
    propertyParams.push(year);
  }

  const whereClause = propertyConditions.length > 0 ? `WHERE ${propertyConditions.join(' AND ')}` : '';

  const [summaryRows] = await pool.execute(
    `SELECT status, COUNT(*) AS total
     FROM properties
     ${whereClause}
     GROUP BY status
     ORDER BY status ASC`,
    propertyParams,
  );

  const [properties] = await pool.execute(
    `SELECT id_property AS id, title, category, location, price, status, updated_at
     FROM properties
     ${whereClause}
     ORDER BY status ASC, title ASC`,
    propertyParams,
  );

  return { summaryRows, properties };
}

async function getGlobalReport({ from, to, month, year } = {}) {
  const purchaseConditions = [];
  const purchaseParams = [];
  applyDateFilters({ conditions: purchaseConditions, params: purchaseParams, from, to, month, year });
  const purchaseWhere = purchaseConditions.length > 0 ? `AND ${purchaseConditions.join(' AND ')}` : '';

  const [summaryRows] = await pool.execute(
    `SELECT
       (SELECT COUNT(*) FROM properties) AS total_properties,
       (SELECT COUNT(*) FROM properties WHERE status = 'Tersedia') AS available_properties,
       (SELECT COUNT(*) FROM properties WHERE status = 'Sedang Dibooking') AS booking_properties,
       (SELECT COUNT(*) FROM properties WHERE status = 'Terjual') AS sold_properties,
       (SELECT COUNT(*) FROM users WHERE role = 'pembeli') AS total_buyers,
       (SELECT COUNT(*) FROM users WHERE role = 'staf') AS total_staff,
       (SELECT COUNT(*) FROM property_purchases pp WHERE 1=1 ${purchaseWhere}) AS total_transactions,
       (SELECT COUNT(*) FROM property_purchases pp WHERE pp.status = 'confirmed' ${purchaseWhere}) AS confirmed_transactions,
       COALESCE((
         SELECT SUM(p.price)
         FROM property_purchases pp
         INNER JOIN properties p ON p.id_property = pp.property_id
          WHERE pp.status = 'confirmed'
          ${purchaseWhere}
       ), 0) AS total_revenue`,
    [...purchaseParams, ...purchaseParams, ...purchaseParams],
  );

  return summaryRows[0];
}

async function getTransactions({ status, from, to, month, year } = {}) {
  return purchaseService.findAllPurchases({ status, from, to, month, year });
}

module.exports = {
  getSalesReport,
  getAvailabilityReport,
  getGlobalReport,
  getTransactions,
};
