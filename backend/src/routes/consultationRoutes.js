const express = require('express');
const consultationController = require('../controllers/consultationController');
const { requireAuth, requireRole } = require('../middleware/authMiddleware');
const { uploadConsultationMedia } = require('../middleware/consultationMediaUploadMiddleware');

const router = express.Router();

router.use(requireAuth);

router.post('/', requireRole('pembeli'), consultationController.createConsultationRequest);
router.get('/my-requests', requireRole('pembeli'), consultationController.listMyConsultationRequests);
router.get('/my-room', requireRole('pembeli'), consultationController.getMyConsultationRoom);
router.get('/requests', requireRole('staf', 'admin'), consultationController.listConsultationRequestsForStaff);
router.get('/chats', requireRole('pembeli', 'staf', 'admin'), consultationController.listMyChats);
router.get('/:id/messages', requireRole('pembeli', 'staf', 'admin'), consultationController.listConsultationMessages);
router.post('/:id/messages', requireRole('pembeli', 'staf', 'admin'), consultationController.sendConsultationMessage);
router.post('/:id/messages/media', requireRole('pembeli', 'staf', 'admin'), uploadConsultationMedia, consultationController.sendConsultationMedia);
router.get('/:id', requireRole('pembeli', 'staf', 'admin'), consultationController.getConsultationDetail);
router.patch('/:id/status', requireRole('staf', 'admin'), consultationController.updateConsultationStatus);

module.exports = router;
