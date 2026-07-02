const notificationService = require('../services/notificationService');

function createError(message, statusCode) {
  const error = new Error(message);
  error.statusCode = statusCode;
  return error;
}

function validateNotificationId(value) {
  const id = Number.parseInt(String(value || ''), 10);
  if (!Number.isInteger(id) || id <= 0) {
    throw createError('ID notifikasi tidak valid', 400);
  }
  return id;
}

const ALLOWED_ACTION_URLS = new Set([
  '/consultation',
  '/buyer-survey-requests',
  '/purchase-status',
  '/home',
]);

function normalizeSearch(value) {
  const search = String(value || '').trim();
  return search || null;
}

function normalizeActionUrl(value) {
  const actionUrl = String(value || '').trim();
  return ALLOWED_ACTION_URLS.has(actionUrl) ? actionUrl : null;
}

function buildNotificationPayload(item) {
  return {
    id: item.id,
    userId: item.user_id,
    title: item.title,
    message: item.message,
    type: item.type,
    actionUrl: normalizeActionUrl(item.action_url),
    imageUrl: item.image_url,
    readAt: item.read_at,
    createdAt: item.created_at,
    updatedAt: item.updated_at,
  };
}

async function listNotifications(req, res, next) {
  try {
    const notifications = await notificationService.findNotificationsByUserId(req.user.sub, {
      search: normalizeSearch(req.query.search),
      limit: req.query.limit,
      offset: req.query.offset,
    });

    return res.status(200).json({
      message: 'Data notifikasi berhasil diambil',
      notifications: notifications.map((item) => buildNotificationPayload(item)),
    });
  } catch (error) {
    return next(error);
  }
}

async function getNotificationDetail(req, res, next) {
  try {
    const notificationId = validateNotificationId(req.params.id);
    const notification = await notificationService.findNotificationForUser({
      id: notificationId,
      userId: req.user.sub,
    });

    if (!notification) {
      throw createError('Notifikasi tidak ditemukan', 404);
    }

    return res.status(200).json({
      message: 'Detail notifikasi berhasil diambil',
      notification: buildNotificationPayload(notification),
    });
  } catch (error) {
    return next(error);
  }
}

async function markNotificationAsRead(req, res, next) {
  try {
    const notificationId = validateNotificationId(req.params.id);
    const notification = await notificationService.markNotificationAsRead({
      id: notificationId,
      userId: req.user.sub,
    });

    if (!notification) {
      throw createError('Notifikasi tidak ditemukan', 404);
    }

    return res.status(200).json({
      message: 'Notifikasi berhasil ditandai sudah dibaca',
      notification: buildNotificationPayload(notification),
    });
  } catch (error) {
    return next(error);
  }
}

async function deleteNotification(req, res, next) {
  try {
    const notificationId = validateNotificationId(req.params.id);
    const deleted = await notificationService.deleteNotificationForUser({
      id: notificationId,
      userId: req.user.sub,
    });

    if (!deleted) {
      throw createError('Notifikasi tidak ditemukan', 404);
    }

    return res.status(200).json({ message: 'Notifikasi berhasil dihapus' });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  listNotifications,
  getNotificationDetail,
  markNotificationAsRead,
  deleteNotification,
};
