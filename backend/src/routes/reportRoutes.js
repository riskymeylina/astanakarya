const express = require('express');
const reportController = require('../controllers/reportController');
const { requireAuth, requireRole } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(requireAuth, requireRole('admin'));

router.get('/global', reportController.getGlobalReport);
router.get('/sales', reportController.getSalesReport);
router.get('/availability', reportController.getAvailabilityReport);
router.get('/transactions', reportController.getTransactions);

module.exports = router;
