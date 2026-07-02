const express = require('express');
const propertyController = require('../controllers/propertyController');
const { requireAuth, requireRole } = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/', propertyController.listProperties);
router.get('/filters', propertyController.listPropertyFilters);
router.patch('/:id/status', requireAuth, requireRole('staf', 'admin'), propertyController.updatePropertyStatus);
router.get('/:id', propertyController.getPropertyDetail);

module.exports = router;
