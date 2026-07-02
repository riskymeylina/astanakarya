const rateLimit = require('express-rate-limit');

function createAuthRateLimiter({ windowMinutes, maxRequests, message }) {
  return rateLimit({
    windowMs: windowMinutes * 60 * 1000,
    max: maxRequests,
    standardHeaders: true,
    legacyHeaders: false,
    message: { message },
  });
}

const registerRateLimiter = createAuthRateLimiter({
  windowMinutes: 15,
  maxRequests: process.env.NODE_ENV === 'production' ? 10 : 1000,
  message: 'Terlalu banyak percobaan pendaftaran. Coba lagi beberapa saat lagi.',
});

const loginRateLimiter = createAuthRateLimiter({
  windowMinutes: 15,
  maxRequests: process.env.NODE_ENV === 'production' ? 8 : 1000,
  message: 'Terlalu banyak percobaan login. Coba lagi beberapa saat lagi.',
});

const forgotPasswordRateLimiter = createAuthRateLimiter({
  windowMinutes: 15,
  maxRequests: process.env.NODE_ENV === 'production' ? 5 : 1000,
  message: 'Terlalu banyak permintaan reset password. Coba lagi beberapa saat lagi.',
});

const verifyResetCodeRateLimiter = createAuthRateLimiter({
  windowMinutes: 10,
  maxRequests: process.env.NODE_ENV === 'production' ? 10 : 1000,
  message: 'Terlalu banyak percobaan verifikasi kode. Coba lagi beberapa saat lagi.',
});

const resetPasswordRateLimiter = createAuthRateLimiter({
  windowMinutes: 15,
  maxRequests: process.env.NODE_ENV === 'production' ? 8 : 1000,
  message: 'Terlalu banyak percobaan ubah kata sandi. Coba lagi beberapa saat lagi.',
});

module.exports = {
  registerRateLimiter,
  loginRateLimiter,
  forgotPasswordRateLimiter,
  verifyResetCodeRateLimiter,
  resetPasswordRateLimiter,
};
