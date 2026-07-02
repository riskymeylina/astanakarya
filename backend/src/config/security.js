function getRequiredEnv(name) {
  const value = String(process.env[name] || '').trim();
  if (!value) {
    throw new Error(`${name} wajib diatur pada environment`);
  }
  return value;
}

function getJwtSecret() {
  return getRequiredEnv('JWT_SECRET');
}

function getAllowedCorsOrigins() {
  return String(process.env.CORS_ORIGIN || '')
    .split(',')
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0);
}

module.exports = {
  getJwtSecret,
  getAllowedCorsOrigins,
};
