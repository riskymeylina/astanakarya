const fs = require('fs');
const path = require('path');
const multer = require('multer');

const uploadDirectory = path.join(__dirname, '..', '..', 'uploads', 'payment-proofs');
const allowedMimeTypes = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
};

function ensureUploadDirectory() {
  fs.mkdirSync(uploadDirectory, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    ensureUploadDirectory();
    cb(null, uploadDirectory);
  },
  filename: (req, file, cb) => {
    const extension = allowedMimeTypes[file.mimetype] || '.jpg';
    cb(null, `proof-${req.params.id}-${req.user.sub}-${Date.now()}${extension}`);
  },
});

function fileFilter(req, file, cb) {
  const expectedExtension = allowedMimeTypes[file.mimetype];
  const actualExtension = path.extname(file.originalname || '').toLowerCase();

  if (!expectedExtension || actualExtension !== expectedExtension) {
    cb(new Error('File bukti pembayaran harus berupa gambar JPG, PNG, atau WEBP yang valid'));
    return;
  }

  cb(null, true);
}

const uploadPaymentProof = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 8 * 1024 * 1024,
  },
}).single('paymentProof');

module.exports = {
  uploadPaymentProof,
};
