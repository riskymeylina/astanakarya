const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const { getJwtSecret } = require('../config/security');

function generateToken(user) {
  return jwt.sign(
    {
      sub: user.id,
      email: user.email,
      role: user.role,
    },
    getJwtSecret(),
    { expiresIn: '7d' },
  );
}

function generateResetCode(length = 6) {
  let code = '';

  while (code.length < length) {
    code += crypto.randomInt(0, 10).toString();
  }

  return code.slice(0, length);
}

function generateResetSessionToken() {
  return crypto.randomBytes(32).toString('hex');
}

function hashResetValue(value) {
  return crypto.createHash('sha256').update(String(value)).digest('hex');
}

module.exports = {
  generateToken,
  generateResetCode,
  generateResetSessionToken,
  hashResetValue,
};
