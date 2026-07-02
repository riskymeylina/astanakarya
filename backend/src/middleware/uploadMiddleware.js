const fs = require('fs');
const path = require('path');
const multer = require('multer');

// --- Profile Photo Upload ---
const profileUploadDirectory = path.join(__dirname, '..', '..', 'uploads', 'profile-photos');
const profileAllowedMimeTypes = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
};

function ensureProfileUploadDirectory() {
  fs.mkdirSync(profileUploadDirectory, { recursive: true });
}

const profileStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    ensureProfileUploadDirectory();
    cb(null, profileUploadDirectory);
  },
  filename: (req, file, cb) => {
    const extension = profileAllowedMimeTypes[file.mimetype] || '.jpg';
    cb(null, `user-${req.user.sub}-${Date.now()}${extension}`);
  },
});

function profileFileFilter(req, file, cb) {
  const expectedExtension = profileAllowedMimeTypes[file.mimetype];
  const actualExtension = path.extname(file.originalname || '').toLowerCase();

  if (!expectedExtension || actualExtension !== expectedExtension) {
    cb(new Error('File harus berupa gambar JPG, PNG, atau WEBP yang valid'));
    return;
  }

  cb(null, true);
}

const uploadProfilePhoto = multer({
  storage: profileStorage,
  fileFilter: profileFileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024,
  },
}).single('photo');

// --- Property Images Upload ---
const propertyStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    let uploadPath = path.join(__dirname, '../../uploads/properties');
    
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }

    if (req.params.id) {
      uploadPath = path.join(uploadPath, `property-${req.params.id}`);
      if (!fs.existsSync(uploadPath)) {
        fs.mkdirSync(uploadPath, { recursive: true });
      }
    }
    
    cb(null, uploadPath);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const propertyFileFilter = (req, file, cb) => {
  const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp'];
  if (allowedMimeTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Hanya format JPG, PNG, dan WEBP yang diperbolehkan!'), false);
  }
};

const uploadPropertyImages = multer({ 
  storage: propertyStorage,
  limits: {
    fileSize: 5 * 1024 * 1024,
    files: 10
  },
  fileFilter: propertyFileFilter
});

module.exports = {
  uploadProfilePhoto,
  uploadPropertyImages,
};
