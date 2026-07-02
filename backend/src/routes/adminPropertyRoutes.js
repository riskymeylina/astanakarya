const express = require('express');
const propertyController = require('../controllers/propertyController');
const { requireAuth, requireRole } = require('../middleware/authMiddleware');
const { uploadPropertyImages } = require('../middleware/uploadMiddleware');

const router = express.Router();

router.use(requireAuth, requireRole('admin'));

router.get('/', propertyController.listAdminProperties);
router.post('/', propertyController.createAdminProperty);
router.patch('/:id', propertyController.updateAdminProperty);
router.delete('/:id', propertyController.deleteAdminProperty);

router.post('/upload-images', uploadPropertyImages.array('images', 10), propertyController.uploadImagesTemp);
router.post('/:id/images', uploadPropertyImages.array('images', 10), propertyController.uploadImagesToProperty);
router.delete('/images/:imageId', propertyController.deleteImage);
router.put('/images/:imageId/primary', propertyController.setPrimaryImage);

module.exports = router;
