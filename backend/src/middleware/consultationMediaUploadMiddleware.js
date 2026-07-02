const fs = require('fs');
const path = require('path');
const multer = require('multer');

const uploadDirectory = path.join(__dirname, '..', '..', 'uploads', 'consultations');
fs.mkdirSync(uploadDirectory, { recursive: true });

const storage = multer.diskStorage({
  destination(_req, _file, callback) {
    callback(null, uploadDirectory);
  },
  filename(_req, file, callback) {
    const safeExt = path.extname(file.originalname || '').toLowerCase();
    const unique = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    callback(null, `${unique}${safeExt}`);
  },
});

function fileFilter(_req, file, callback) {
  const allowed = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'audio/mpeg',
    'audio/mp4',
    'audio/webm',
    'audio/wav',
    'application/pdf',
  ];
  if (!allowed.includes(file.mimetype)) {
    callback(new Error('Format file chat tidak didukung'));
    return;
  }
  callback(null, true);
}

const uploadConsultationMedia = multer({
  storage,
  fileFilter,
  limits: { fileSize: 10 * 1024 * 1024 },
}).single('media');

module.exports = { uploadConsultationMedia };
