const express = require('express');
const surveyController = require('../controllers/surveyController');
const { requireAuth, requireRole } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(requireAuth);

router.post('/', requireRole('pembeli'), surveyController.createSurveyRequest);
router.get('/my-requests', requireRole('pembeli'), surveyController.listMySurveyRequests);
router.get('/requests', requireRole('staf', 'admin'), surveyController.listSurveyRequestsForMarketing);
router.patch('/:id/status', requireRole('staf', 'admin'), surveyController.updateSurveyRequestStatus);
router.patch('/:id/cancel', requireRole('pembeli'), surveyController.cancelSurveyRequest);
router.put('/:id', requireRole('pembeli'), surveyController.updateSurveyRequest);

module.exports = router;
