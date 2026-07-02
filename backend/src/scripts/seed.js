require('dotenv').config();
const fs = require('fs/promises');
const path = require('path');
const { createMigrationConnection } = require('../utils/migration');

function getSeedersDir() {
  return path.join(__dirname, '..', '..', 'seeders');
}

async function listSeederFiles() {
  const files = await fs.readdir(getSeedersDir());
  return files.filter((file) => file.endsWith('.sql')).sort();
}

async function readSeederSql(filename) {
  return fs.readFile(path.join(getSeedersDir(), filename), 'utf8');
}

async function seed() {
  const connection = await createMigrationConnection({ multipleStatements: true });

  try {
    const files = await listSeederFiles();

    if (files.length === 0) {
      console.log('No seeder files found.');
      return;
    }

    for (const file of files) {
      const sql = await readSeederSql(file);
      await connection.query(sql);
      console.log(`Seeded: ${file}`);
    }

    console.log('Seeding completed');
  } finally {
    await connection.end();
  }
}

if (require.main === module) {
  seed().catch((error) => {
    console.error('Seeding failed:', error.message);
    process.exit(1);
  });
}

module.exports = {
  seed,
};
