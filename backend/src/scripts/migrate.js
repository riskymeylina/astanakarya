require('dotenv').config();
const {
  createMigrationConnection,
  ensureSchemaMigrationsTable,
  getAppliedMigrationSet,
  listMigrationFiles,
  readMigrationSql,
} = require('../utils/migration');

async function applyMigration(connection, file) {
  const sql = await readMigrationSql(file);
  await connection.query(sql);
  await connection.query('INSERT INTO schema_migrations (filename) VALUES (?)', [file]);
  console.log(`Applied migration: ${file}`);
}

async function migrate() {
  const connection = await createMigrationConnection({ multipleStatements: true });

  try {
    await ensureSchemaMigrationsTable(connection);
    const files = await listMigrationFiles();
    const applied = await getAppliedMigrationSet(connection);

    for (const file of files) {
      if (applied.has(file)) {
        console.log(`Skipped migration: ${file}`);
        continue;
      }

      await applyMigration(connection, file);
    }

    console.log('Migration completed');
  } finally {
    await connection.end();
  }
}

if (require.main === module) {
  migrate().catch((error) => {
    console.error('Migration failed:', error.message);
    process.exit(1);
  });
}

module.exports = {
  migrate,
};
