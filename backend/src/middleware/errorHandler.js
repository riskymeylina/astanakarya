function isDebugEnabled() {
  return String(process.env.DEBUG_ERRORS || '').trim().toLowerCase() === 'true'
    || String(process.env.NODE_ENV || 'development').trim().toLowerCase() !== 'production';
}

function buildErrorPayload(error, statusCode, showDetails) {
  const payload = {
    message: statusCode === 500 ? 'Terjadi kesalahan pada server' : error.message,
  };

  if (statusCode === 500 && showDetails) {
    payload.error = error.message;

    if (error.code) {
      payload.code = error.code;
    }

    if (error.sqlMessage) {
      payload.sqlMessage = error.sqlMessage;
    }

    if (error.stack) {
      payload.stack = error.stack;
    }
  }

  return payload;
}

function logError(error, req, statusCode, showDetails) {
  const parts = [
    `[${new Date().toISOString()}]`,
    `${req.method} ${req.originalUrl || req.url}`,
    `status=${statusCode}`,
    `message=${error.message}`,
  ];

  if (error.code) {
    parts.push(`code=${error.code}`);
  }

  if (error.sqlMessage) {
    parts.push(`sqlMessage=${error.sqlMessage}`);
  }

  console.error(parts.join(' | '));

  if (showDetails && error.stack) {
    console.error(error.stack);
  }
}

function errorHandler(error, req, res, next) {
  if (res.headersSent) {
    return next(error);
  }

  const statusCode = error.statusCode || 500;
  const showDetails = isDebugEnabled();

  logError(error, req, statusCode, showDetails);

  return res.status(statusCode).json(buildErrorPayload(error, statusCode, showDetails));
}

module.exports = errorHandler;
