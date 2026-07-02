const express = require('express');
const adminUserController = require('../controllers/adminUserController');
const { requireAuth, requireRole } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(requireAuth, requireRole('admin'));

router.get('/', adminUserController.listUsers);
router.post('/', adminUserController.createStaff);
router.patch('/:id', adminUserController.updateUser);

module.exports = router;
