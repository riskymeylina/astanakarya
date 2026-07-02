const fs = require('fs/promises');
const path = require('path');

function toPublicProfilePhotoPath(filename) {
  return `/uploads/profile-photos/${filename}`;
}

function toAbsoluteUploadPath(publicPath) {
  const normalized = (publicPath || '').replace(/^\/+/, '');
  return path.join(__dirname, '..', '..', normalized);
}

async function deleteFileIfExists(publicPath) {
  if (!publicPath) return;

  try {
    await fs.unlink(toAbsoluteUploadPath(publicPath));
  } catch (error) {
    if (error.code !== 'ENOENT') {
      throw error;
    }
  }
}

module.exports = {
  toPublicProfilePhotoPath,
  deleteFileIfExists,
};
