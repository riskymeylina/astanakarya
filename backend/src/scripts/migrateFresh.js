require('dotenv').config();
const { getDatabaseName } = require('../config/db');
const { createMigrationConnection } = require('../utils/migration');
const { migrate } = require('./migrate');

async function migrateFresh() {
  const connection = await createMigrationConnection({ includeDatabase: false });

  try {
    const databaseName = getDatabaseName();
    await connection.query(`DROP DATABASE IF EXISTS \`${databaseName}\``);
    await connection.query(`CREATE DATABASE \`${databaseName}\``);
    console.log(`Database reset: ${databaseName}`);
  } finally {
    await connection.end();
  }

  await migrate();
}

migrateFresh().catch((error) => {
  console.error('Fresh migration failed:', error.message);
  process.exit(1);
});
