#!/usr/bin/env node
/**
 * Tunggu MySQL sampai siap terima koneksi
 * Dipake di entrypoint Docker biar migration gak error
 */
const mysql = require("mysql2/promise");
const { getDbConfig } = require("../config/db");

const RETRY_INTERVAL_MS = 1000;
const MAX_RETRIES = 30;

async function waitForMysql() {
  let attempt = 0;

  while (attempt < MAX_RETRIES) {
    attempt++;
    try {
      const conn = await mysql.createConnection(
        getDbConfig({ includeDatabase: false })
      );
      await conn.end();
      console.log("[wait-for-mysql] MySQL siap!");
      process.exit(0);
    } catch (err) {
      process.stderr.write(".");
      await new Promise((r) => setTimeout(r, RETRY_INTERVAL_MS));
    }
  }

  console.error(
    `\n[wait-for-mysql] MySQL gak siap-siap setelah ${MAX_RETRIES} kali percobaan.`
  );
  process.exit(1);
}

waitForMysql();
