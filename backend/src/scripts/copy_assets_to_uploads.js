const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '../../../');
const assetsDir = path.join(repoRoot, 'assets', 'images');
const uploadsDir = path.join(repoRoot, 'backend', 'uploads', 'properties');

const filesToCopy = [
  '1.jpg',
  '2.jpg',
  '3.jpg',
  '4.jpg',
  '5.jpg',
  'home.jpg',
  'splash.jpg',
  'dapur.jpg',
  'kamar mandi.jpg',
  'kamar tidur 1.jpg',
  'kamar tidur 2.jpg',
  'ruang eluarga.jpg',
  'ruang tamu.jpg',
  'home atas.jpg'
];

async function copyFiles() {
  try {
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }

    for (const file of filesToCopy) {
      const src = path.join(assetsDir, file);
      const dest = path.join(uploadsDir, file);
      if (!fs.existsSync(src)) {
        console.warn('Source missing:', src);
        continue;
      }
      fs.copyFileSync(src, dest);
      console.log('Copied', file);
    }
    console.log('Asset copy complete');
  } catch (err) {
    console.error('Error copying assets:', err);
    process.exit(1);
  }
}

copyFiles();
