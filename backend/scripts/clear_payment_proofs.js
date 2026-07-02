const fs = require('fs').promises;
const path = require('path');

async function clearDir(dir) {
  try {
    const entries = await fs.readdir(dir);
    if (entries.length === 0) {
      console.log(`No files in ${dir}`);
      return;
    }
    for (const entry of entries) {
      const full = path.join(dir, entry);
      const stat = await fs.lstat(full);
      if (stat.isDirectory()) {
        await fs.rm(full, { recursive: true, force: true });
        console.log(`Removed directory: ${full}`);
      } else {
        await fs.unlink(full);
        console.log(`Removed file: ${full}`);
      }
    }
    console.log(`Cleared ${dir}`);
  } catch (err) {
    if (err.code === 'ENOENT') {
      console.log(`Directory not found: ${dir}`);
      return;
    }
    console.error('Error while clearing directory:', err);
    process.exitCode = 1;
  }
}

(async () => {
  const uploadsDir = path.resolve(__dirname, '../uploads/payment-proofs');
  console.log('Clearing payment proof uploads in', uploadsDir);
  await clearDir(uploadsDir);
})();
