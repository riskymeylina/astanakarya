const fs = require('fs/promises');
const path = require('path');
const mysql = require('mysql2/promise');
const { getDbConfig } = require('../config/db');

function createMigrationConnection({ includeDatabase = true, multipleStatements = false } = {}) {
  return mysql.createConnection(getDbConfig({ includeDatabase, multipleStatements }));
}

function getMigrationsDir() {
  return path.join(__dirname, '..', '..', 'migrations');
}

async function listMigrationFiles() {
  const files = await fs.readdir(getMigrationsDir());
  return files.filter((file) => file.endsWith('.sql')).sort();
}

async function ensureSchemaMigrationsTable(connection) {
  await connection.query(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      filename VARCHAR(255) NOT NULL,
      applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY schema_migrations_filename_unique (filename)
    )
  `);
}

async function getAppliedMigrationRows(connection) {
  const [rows] = await connection.query('SELECT filename, applied_at FROM schema_migrations ORDER BY filename ASC');
  return rows;
}

async function getAppliedMigrationSet(connection) {
  const rows = await getAppliedMigrationRows(connection);
  return new Set(rows.map((row) => row.filename));
}

function getMigrationFilePath(filename) {
  return path.join(getMigrationsDir(), filename);
}

async function readMigrationSql(filename) {
  return fs.readFile(getMigrationFilePath(filename), 'utf8');
}

module.exports = {
  createMigrationConnection,
  ensureSchemaMigrationsTable,
  getAppliedMigrationRows,
  getAppliedMigrationSet,
  getMigrationFilePath,
  getMigrationsDir,
  listMigrationFiles,
  readMigrationSql,
};
