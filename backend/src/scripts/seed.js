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

async function ensureSchemaSeedersTable(connection) {
  await connection.query(`
    CREATE TABLE IF NOT EXISTS schema_seeders (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      filename VARCHAR(255) NOT NULL,
      applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY schema_seeders_filename_unique (filename)
    )
  `);
}

async function getAppliedSeederSet(connection) {
  const [rows] = await connection.query('SELECT filename FROM schema_seeders');
  return new Set(rows.map((row) => row.filename));
}

async function seed() {
  const connection = await createMigrationConnection({ multipleStatements: true });

  try {
    await ensureSchemaSeedersTable(connection);
    const files = await listSeederFiles();
    const applied = await getAppliedSeederSet(connection);

    if (files.length === 0) {
      console.log('No seeder files found.');
      return;
    }

    for (const file of files) {
      if (applied.has(file)) {
        console.log(`Skipped seeder: ${file}`);
        continue;
      }

      const sql = await readSeederSql(file);
      await connection.query(sql);
      await connection.query('INSERT INTO schema_seeders (filename) VALUES (?)', [file]);
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
