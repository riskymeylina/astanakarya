#!/bin/sh
# =====================================================
# Docker Entrypoint — Auto migrate + start server
# =====================================================
set -e

echo "[entrypoint] Menunggu MySQL siap..."

node src/scripts/waitForMysql.js

echo "[entrypoint] MySQL siap. Menjalankan migration..."

npm run migrate

echo "[entrypoint] Migration selesai. Menjalankan server..."

exec node src/server.js
