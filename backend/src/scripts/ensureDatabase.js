require('dotenv').config();
const { getDatabaseName } = require('../config/db');
const { createMigrationConnection } = require('../utils/migration');

async function ensureDatabase() {
  const connection = await createMigrationConnection({ includeDatabase: false });

  try {
    const databaseName = getDatabaseName();
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${databaseName}\``);
    console.log(`Database ready: ${databaseName}`);
  } finally {
    await connection.end();
  }
}

ensureDatabase().catch((error) => {
  console.error('Failed to ensure database:', error.message);
  process.exit(1);
});
