const express = require('express');
const notificationController = require('../controllers/notificationController');
const { requireAuth } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(requireAuth);

router.get('/', notificationController.listNotifications);
router.get('/:id', notificationController.getNotificationDetail);
router.patch('/:id/read', notificationController.markNotificationAsRead);
router.delete('/:id', notificationController.deleteNotification);

module.exports = router;
