require('dotenv').config();
const {
  createMigrationConnection,
  ensureSchemaMigrationsTable,
  getAppliedMigrationRows,
  listMigrationFiles,
} = require('../utils/migration');

async function showStatus() {
  const connection = await createMigrationConnection();

  try {
    const files = await listMigrationFiles();
    await ensureSchemaMigrationsTable(connection);
    const appliedRows = await getAppliedMigrationRows(connection);
    const appliedMap = new Map(appliedRows.map((row) => [row.filename, row.applied_at]));

    for (const file of files) {
      const appliedAt = appliedMap.get(file);
      console.log(`${appliedAt ? 'APPLIED' : 'PENDING'} ${file}${appliedAt ? ` (${appliedAt})` : ''}`);
    }
  } finally {
    await connection.end();
  }
}

showStatus().catch((error) => {
  console.error('Failed to read migration status:', error.message);
  process.exit(1);
});
