const invoiceService = require('../services/invoiceService');
const purchaseService = require('../services/purchaseService');

function createError(message, statusCode) {
  const error = new Error(message);
  error.statusCode = statusCode;
  return error;
}

function buildInvoicePayload(req, invoice) {
  return {
    id: invoice.id,
    invoiceNumber: invoice.invoice_number,
    purchaseId: invoice.purchase_id,
    buyerId: invoice.buyer_id,
    propertyId: invoice.property_id,
    propertyName: invoice.property_name,
    propertyPrice: invoice.property_price,
    paymentMethod: invoice.payment_method,
    paymentProofUrl: invoice.payment_proof_url ? `${req.protocol}://${req.get('host')}${invoice.payment_proof_url}` : null,
    paymentStatus: invoice.payment_status,
    issuedAt: invoice.issued_at,
    dueDate: invoice.due_date,
    createdAt: invoice.created_at,
    updatedAt: invoice.updated_at,
  };
}

async function getInvoiceByPurchase(req, res, next) {
  try {
    const purchaseId = parseInt(req.params.purchaseId, 10);
    if (!Number.isInteger(purchaseId) || purchaseId <= 0) {
      throw createError('ID pemesanan tidak valid', 400);
    }

    const purchase = await purchaseService.findPurchaseById(purchaseId);
    if (!purchase) {
      throw createError('Pemesanan tidak ditemukan', 404);
    }

    const { invoice, error } = await invoiceService.getInvoiceByPurchaseId(purchaseId);
    if (error) {
      throw createError('Gagal mengambil invoice', 500);
    }

    if (!invoice) {
      throw createError('Invoice tidak ditemukan untuk pemesanan ini', 404);
    }

    res.status(200).json({
      message: 'Invoice berhasil diambil',
      invoice: buildInvoicePayload(req, invoice),
    });
  } catch (error) {
    next(error);
  }
}

async function getInvoiceById(req, res, next) {
  try {
    const invoiceId = parseInt(req.params.id, 10);
    if (!Number.isInteger(invoiceId) || invoiceId <= 0) {
      throw createError('ID invoice tidak valid', 400);
    }

    const { invoice, error } = await invoiceService.getInvoiceById(invoiceId);
    if (error) {
      throw createError('Gagal mengambil invoice', 500);
    }

    if (!invoice) {
      throw createError('Invoice tidak ditemukan', 404);
    }

    const userRole = String(req.user?.role || '').toLowerCase();
    if (userRole === 'pembeli' && invoice.buyer_id !== req.user.sub) {
      throw createError('Anda tidak memiliki akses ke invoice ini', 403);
    }

    res.status(200).json({
      message: 'Invoice berhasil diambil',
      invoice: buildInvoicePayload(req, invoice),
    });
  } catch (error) {
    next(error);
  }
}

async function getInvoicesByBuyer(req, res, next) {
  try {
    const limit = Math.min(100, parseInt(req.query.limit || 20, 10));
    const offset = Math.max(0, parseInt(req.query.offset || 0, 10));

    const { invoices, error } = await invoiceService.getInvoicesByBuyerId(req.user.sub, { limit, offset });
    if (error) {
      throw createError('Gagal mengambil daftar invoice', 500);
    }

    res.status(200).json({
      message: 'Daftar invoice berhasil diambil',
      invoices: invoices.map(inv => buildInvoicePayload(req, inv)),
      pagination: { limit, offset },
    });
  } catch (error) {
    next(error);
  }
}

async function getAllInvoices(req, res, next) {
  try {
    const limit = Math.min(100, parseInt(req.query.limit || 20, 10));
    const offset = Math.max(0, parseInt(req.query.offset || 0, 10));

    const { invoices, error } = await invoiceService.getAllInvoices({ limit, offset });
    if (error) {
      throw createError('Gagal mengambil daftar invoice', 500);
    }

    res.status(200).json({
      message: 'Daftar invoice berhasil diambil',
      invoices: invoices.map(inv => buildInvoicePayload(req, inv)),
      pagination: { limit, offset },
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getInvoiceByPurchase,
  getInvoiceById,
  getInvoicesByBuyer,
  getAllInvoices,
};
