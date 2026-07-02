const reportService = require('../services/reportService');
const purchaseService = require('../services/purchaseService');

const VALID_TRANSACTION_STATUSES = new Set([
  'pending_payment',
  'payment_uploaded',
  'payment_review',
  'confirmed',
  'rejected',
  'cancelled',
]);

function createError(message, statusCode) {
  const error = new Error(message);
  error.statusCode = statusCode;
  return error;
}

function resolveAssetUrl(req, relPath) {
  if (!relPath) return null;
  if (/^https?:\/\//i.test(relPath)) return relPath;
  const normalised = relPath.startsWith('/') ? relPath : `/${relPath}`;
  return `${req.protocol}://${req.get('host')}${normalised}`;
}

function normalizeDate(value, fieldName) {
  const text = String(value || '').trim();
  if (!text) return null;
  if (!/^\d{4}-\d{2}-\d{2}$/.test(text)) {
    throw createError(`${fieldName} harus memakai format YYYY-MM-DD`, 400);
  }
  return text;
}

function normalizeMonth(value) {
  const text = String(value || '').trim();
  if (!text) return null;
  const month = Number.parseInt(text, 10);
  if (!Number.isInteger(month) || month < 1 || month > 12) {
    throw createError('Bulan filter harus bernilai 1-12', 400);
  }
  return month;
}

function normalizeYear(value) {
  const text = String(value || '').trim();
  if (!text) return null;
  const year = Number.parseInt(text, 10);
  if (!Number.isInteger(year) || year < 2000 || year > 2100) {
    throw createError('Tahun filter tidak valid', 400);
  }
  return year;
}

function parseDateFilters(query) {
  return {
    from: normalizeDate(query.from, 'Tanggal awal'),
    to: normalizeDate(query.to, 'Tanggal akhir'),
    month: normalizeMonth(query.month),
    year: normalizeYear(query.year),
  };
}

function normalizeStatus(value) {
  const status = String(value || '').trim().toLowerCase();
  if (!status) return null;
  if (!VALID_TRANSACTION_STATUSES.has(status)) {
    throw createError('Status transaksi tidak valid', 400);
  }
  return status;
}

function buildPurchasePayload(req, item) {
  return {
    id: item.id,
    buyerUserId: item.buyer_user_id,
    propertyId: item.property_id,
    propertyTitle: item.property_title,
    propertyLocation: item.property_location,
    propertyThumbnailUrl: resolveAssetUrl(req, item.property_thumbnail_url),
    propertyPrice: item.property_price,
    paymentMethod: item.payment_method,
    paymentAccountNumber: item.payment_account_number,
    paymentAccountName: item.payment_account_name,
    paymentBankNote: purchaseService.PAYMENT_BANK_NOTE,
    paymentAmount: item.payment_amount,
    paymentDueAt: item.payment_due_at,
    cancelledAt: item.cancelled_at,
    buyerNameSnapshot: item.buyer_name_snapshot,
    buyerPhoneSnapshot: item.buyer_phone_snapshot,
    buyerAddressSnapshot: item.buyer_address_snapshot,
    notes: item.notes,
    status: item.status,
    paymentProofUrl: resolveAssetUrl(req, item.payment_proof_path),
    paymentProofUploadedAt: item.payment_proof_uploaded_at,
    processedByUserId: item.processed_by_user_id,
    processedByName: item.processed_by_name,
    rejectionReason: item.rejection_reason,
    processedAt: item.processed_at,
    createdAt: item.created_at,
    updatedAt: item.updated_at,
  };
}

async function getGlobalReport(req, res, next) {
  try {
    const report = await reportService.getGlobalReport(parseDateFilters(req.query));
    return res.status(200).json({ message: 'Laporan global berhasil diambil', report });
  } catch (error) {
    return next(error);
  }
}

async function getSalesReport(req, res, next) {
  try {
    const report = await reportService.getSalesReport(parseDateFilters(req.query));
    return res.status(200).json({
      message: 'Laporan penjualan berhasil diambil',
      totalRevenue: report.totalRevenue,
      transactions: report.rows.map((row) => buildPurchasePayload(req, row)),
    });
  } catch (error) {
    return next(error);
  }
}

async function getAvailabilityReport(req, res, next) {
  try {
    const report = await reportService.getAvailabilityReport(parseDateFilters(req.query));
    return res.status(200).json({
      message: 'Laporan ketersediaan berhasil diambil',
      summary: report.summaryRows.map((row) => ({ status: row.status, total: row.total })),
      properties: report.properties.map((property) => ({
        id: property.id,
        title: property.title,
        category: property.category,
        location: property.location,
        price: property.price,
        status: property.status,
        updatedAt: property.updated_at,
      })),
    });
  } catch (error) {
    return next(error);
  }
}

async function getTransactions(req, res, next) {
  try {
    const status = normalizeStatus(req.query.status);
    const transactions = await reportService.getTransactions({
      status,
      ...parseDateFilters(req.query),
    });
    return res.status(200).json({
      message: 'Data transaksi berhasil diambil',
      transactions: transactions.map((tx) => buildPurchasePayload(req, tx)),
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  getGlobalReport,
  getSalesReport,
  getAvailabilityReport,
  getTransactions,
};
