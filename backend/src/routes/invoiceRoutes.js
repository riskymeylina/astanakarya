const express = require('express');
const invoiceController = require('../controllers/invoiceController');
const { requireAuth, requireRole } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(requireAuth);

router.get('/purchase/:purchaseId', invoiceController.getInvoiceByPurchase);
router.get('/my-invoices', requireRole('pembeli'), invoiceController.getInvoicesByBuyer);
router.get('/:id', invoiceController.getInvoiceById);
router.get('/', requireRole('staf', 'admin'), invoiceController.getAllInvoices);

module.exports = router;
