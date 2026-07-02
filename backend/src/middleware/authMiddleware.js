const jwt = require('jsonwebtoken');
const { getJwtSecret } = require('../config/security');

function requireAuth(req, res, next) {
  const authorization = req.headers.authorization || '';
  const [type, token] = authorization.split(' ');

  if (type !== 'Bearer' || !token) {
    return res.status(401).json({ message: 'Token tidak valid atau tidak ditemukan' });
  }

  try {
    const payload = jwt.verify(token, getJwtSecret());
    req.user = payload;
    return next();
  } catch (_) {
    return res.status(401).json({ message: 'Token invalid atau sudah kedaluwarsa' });
  }
}

function requireRole(...allowedRoles) {
  const normalizedRoles = allowedRoles.map((role) => String(role || '').trim().toLowerCase());

  return function roleGuard(req, res, next) {
    const userRole = String(req.user?.role || '').trim().toLowerCase();

    if (!normalizedRoles.includes(userRole)) {
      return res.status(403).json({ message: 'Anda tidak memiliki akses ke fitur ini' });
    }

    return next();
  };
}

module.exports = {
  requireAuth,
  requireRole,
};
