const consultationService = require('../services/consultationService');
const notificationService = require('../services/notificationService');

const VALID_CONTACT_METHODS = new Set(['WhatsApp', 'Telepon', 'Email']);
const VALID_STATUSES = new Set(['pending', 'contacted', 'resolved', 'rejected']);
const VALID_REVIEW_STATUSES = new Set(['contacted', 'resolved', 'rejected']);

function createError(message, statusCode) {
  const error = new Error(message);
  error.statusCode = statusCode;
  return error;
}

function normalizeStatus(value) {
  return String(value || '').trim().toLowerCase();
}

function validateConsultationId(value) {
  const id = Number.parseInt(String(value || ''), 10);

  if (!Number.isInteger(id) || id <= 0) {
    throw createError('ID permintaan konsultasi tidak valid', 400);
  }

  return id;
}

function validateOptionalPropertyId(value) {
  if (value == null || String(value).trim() === '') {
    return null;
  }

  const id = Number.parseInt(String(value), 10);
  if (!Number.isInteger(id) || id <= 0) {
    throw createError('Properti tidak valid', 400);
  }

  return id;
}

function validateBoundedText(value, label, { required = true, max = 255 } = {}) {
  const normalized = String(value || '').trim();
  if (required && !normalized) {
    throw createError(`${label} wajib diisi`, 400);
  }

  if (normalized.length > max) {
    throw createError(`${label} maksimal ${max} karakter`, 400);
  }

  return normalized || null;
}

function validateContactMethod(value) {
  const normalized = String(value || '').trim();
  if (!VALID_CONTACT_METHODS.has(normalized)) {
    throw createError('Metode kontak tidak valid. Pilih: WhatsApp, Telepon, atau Email', 400);
  }

  return normalized;
}

function validateCreateBody(body) {
  return {
    propertyId: validateOptionalPropertyId(body.propertyId),
    topic: validateBoundedText(body.topic, 'Topik konsultasi', { max: 100 }),
    preferredContactMethod: validateContactMethod(body.preferredContactMethod),
    message: validateBoundedText(body.message, 'Pesan konsultasi', { max: 1500 }),
  };
}

function validateStatusUpdateBody(body) {
  const status = normalizeStatus(body.status);
  if (!VALID_REVIEW_STATUSES.has(status)) {
    throw createError('Status konsultasi tidak valid', 400);
  }

  const staffNotes = validateBoundedText(body.staffNotes, 'Catatan staf', {
    required: status === 'rejected',
    max: 1500,
  });

  return { status, staffNotes };
}

function buildConsultationPayload(item) {
  return {
    id: item.id,
    buyerUserId: item.buyer_user_id,
    buyerName: item.buyer_name,
    buyerPhone: item.buyer_phone,
    buyerEmail: item.buyer_email,
    buyerWhatsapp: item.buyer_whatsapp,
    propertyId: item.property_id,
    propertyTitle: item.property_title,
    propertyLocation: item.property_location,
    topic: item.topic,
    preferredContactMethod: item.preferred_contact_method,
    message: item.message,
    status: item.status,
    staffNotes: item.staff_notes,
    processedByUserId: item.processed_by_user_id,
    processedByName: item.processed_by_name,
    processedAt: item.processed_at,
    createdAt: item.created_at,
    updatedAt: item.updated_at,
    lastMessage: item.last_message,
    lastMessageAt: item.last_message_at,
    lastMessageSenderUserId: item.last_message_sender_user_id,
    lastMessageReadAt: item.last_message_read_at,
    unreadCount: Number(item.unread_count || 0),
  };
}

function buildMessagePayload(item) {
  return {
    id: item.id,
    consultationId: item.consultation_id,
    senderUserId: item.sender_user_id,
    senderName: item.sender_name,
    senderRole: item.sender_role,
    messageType: item.message_type,
    message: item.message,
    mediaUrl: resolveAssetUrl(item.media_path),
    mediaName: item.media_name,
    mediaMime: item.media_mime,
    createdAt: item.created_at,
    readAt: item.read_at,
  };
}

function resolveAssetUrl(relPath) {
  if (!relPath) return null;
  if (/^https?:\/\//i.test(relPath)) return relPath;
  return relPath;
}

function validateChatMessage(body) {
  return validateBoundedText(body.message, 'Pesan chat', {
    required: true,
    max: 1500,
  });
}

function ensureCanAccessConsultation(req, consultation) {
  const userRole = String(req.user?.role || '').toLowerCase();
  if (userRole === 'pembeli' && consultation.buyer_user_id !== req.user.sub) {
    throw createError('Anda tidak memiliki akses ke permintaan konsultasi ini', 403);
  }
}

async function createConsultationRequest(req, res, next) {
  try {
    const payload = validateCreateBody(req.body);

    if (payload.propertyId) {
      const property = await consultationService.findPropertyForConsultation(payload.propertyId);
      if (!property || property.status === 'Terjual') {
        throw createError('Properti tidak ditemukan atau tidak tersedia untuk konsultasi', 404);
      }
    }

    const consultation = await consultationService.createConsultationRequest({
      buyerUserId: req.user.sub,
      ...payload,
    });

    try {
      await notificationService.notifyStaffAndAdmins({
        title: 'Konsultasi Baru',
        message: `Permintaan konsultasi baru: ${payload.topic || 'Konsultasi Umum'}.`,
        type: 'consultation',
        actionUrl: '/consultations',
      });
    } catch (_) {}

    return res.status(201).json({
      message: 'Permintaan konsultasi berhasil diajukan',
      consultation: buildConsultationPayload(consultation),
    });
  } catch (error) {
    return next(error);
  }
}

async function listMyConsultationRequests(req, res, next) {
  try {
    const consultations = await consultationService.findConsultationsByBuyerId(req.user.sub);
    return res.status(200).json({
      message: 'Data permintaan konsultasi berhasil diambil',
      consultations: consultations.map((item) => buildConsultationPayload(item)),
    });
  } catch (error) {
    return next(error);
  }
}

async function getMyConsultationRoom(req, res, next) {
  try {
    const consultation = await consultationService.findOrCreateCustomerServiceRoom(req.user.sub);
    return res.status(200).json({
      message: 'Room konsultasi berhasil diambil',
      consultation: buildConsultationPayload(consultation),
    });
  } catch (error) {
    return next(error);
  }
}

async function listConsultationRequestsForStaff(req, res, next) {
  try {
    const rawStatus = normalizeStatus(req.query.status);
    const status = rawStatus && VALID_STATUSES.has(rawStatus) ? rawStatus : null;
    const consultations = await consultationService.findAllConsultations({
      status,
      viewerUserId: req.user.sub,
    });

    return res.status(200).json({
      message: 'Data permintaan konsultasi berhasil diambil',
      consultations: consultations.map((item) => buildConsultationPayload(item)),
    });
  } catch (error) {
    return next(error);
  }
}

async function getConsultationDetail(req, res, next) {
  try {
    const consultationId = validateConsultationId(req.params.id);
    const consultation = await consultationService.findConsultationById(consultationId);

    if (!consultation) {
      throw createError('Permintaan konsultasi tidak ditemukan', 404);
    }

    ensureCanAccessConsultation(req, consultation);

    return res.status(200).json({
      message: 'Detail permintaan konsultasi berhasil diambil',
      consultation: buildConsultationPayload(consultation),
    });
  } catch (error) {
    return next(error);
  }
}

async function listConsultationMessages(req, res, next) {
  try {
    const consultationId = validateConsultationId(req.params.id);
    const consultation = await consultationService.findConsultationById(consultationId);

    if (!consultation) {
      throw createError('Permintaan konsultasi tidak ditemukan', 404);
    }

    ensureCanAccessConsultation(req, consultation);

    await consultationService.markConsultationMessagesRead({
      consultationId,
      viewerUserId: req.user.sub,
    });
    const messages = await consultationService.findConsultationMessages(consultationId);
    return res.status(200).json({
      message: 'Chat konsultasi berhasil diambil',
      messages: messages.map(buildMessagePayload),
    });
  } catch (error) {
    return next(error);
  }
}

async function listMyChats(req, res, next) {
  try {
    const userRole = String(req.user?.role || '').toLowerCase();
    const consultations = userRole === 'pembeli'
      ? await consultationService.findConsultationsByBuyerId(req.user.sub)
      : await consultationService.findAllConsultations({ viewerUserId: req.user.sub });

    return res.status(200).json({
      message: 'Daftar chat konsultasi berhasil diambil',
      chats: consultations.map(buildConsultationPayload),
    });
  } catch (error) {
    return next(error);
  }
}

async function sendConsultationMessage(req, res, next) {
  try {
    const consultationId = validateConsultationId(req.params.id);
    const consultation = await consultationService.findConsultationById(consultationId);

    if (!consultation) {
      throw createError('Permintaan konsultasi tidak ditemukan', 404);
    }

    ensureCanAccessConsultation(req, consultation);

    const messageText = validateChatMessage(req.body);
    const senderRole = String(req.user.role || '').toLowerCase();
    const senderName = senderRole === 'pembeli'
      ? consultation.buyer_name
      : (req.user.email || 'Staf');
    const message = await consultationService.createConsultationMessage({
      consultationId,
      senderUserId: req.user.sub,
      senderName,
      senderRole,
      message: messageText,
    });

    try {
      const isBuyer = senderRole === 'pembeli';
      if (isBuyer) {
        await notificationService.notifyStaffAndAdmins({
          title: 'Pesan Konsultasi Baru',
          message: `${consultation.buyer_name || 'Pembeli'}: ${messageText.substring(0, 50)}${messageText.length > 50 ? '...' : ''}`,
          type: 'consultation',
          actionUrl: '/consultations',
        });
      } else {
        await notificationService.createNotification({
          userId: consultation.buyer_user_id,
          title: 'Pesan Konsultasi Baru',
          message: `${senderName}: ${messageText.substring(0, 50)}${messageText.length > 50 ? '...' : ''}`,
          type: 'consultation',
          actionUrl: '/consultations',
        });
      }
    } catch (_) {}

    return res.status(201).json({
      message: 'Pesan chat berhasil dikirim',
      chatMessage: buildMessagePayload(message),
    });
  } catch (error) {
    return next(error);
  }
}

async function sendConsultationMedia(req, res, next) {
  try {
    const consultationId = validateConsultationId(req.params.id);
    const consultation = await consultationService.findConsultationById(consultationId);

    if (!consultation) {
      throw createError('Permintaan konsultasi tidak ditemukan', 404);
    }

    ensureCanAccessConsultation(req, consultation);

    if (!req.file) {
      throw createError('File chat wajib diunggah', 400);
    }

    const senderRole = String(req.user.role || '').toLowerCase();
    const senderName = senderRole === 'pembeli'
      ? consultation.buyer_name
      : (req.user.email || 'Staf');
    const mime = req.file.mimetype || '';
    const messageType = mime.startsWith('image/')
      ? 'image'
      : mime.startsWith('audio/')
      ? 'audio'
      : 'file';
    const relativePath = `/uploads/consultations/${req.file.filename}`;
    const message = await consultationService.createConsultationMessage({
      consultationId,
      senderUserId: req.user.sub,
      senderName,
      senderRole,
      messageType,
      message: req.body.message || req.file.originalname || 'Lampiran',
      mediaPath: relativePath,
      mediaName: req.file.originalname,
      mediaMime: mime,
    });

    try {
      const isBuyer = senderRole === 'pembeli';
      const summary = req.body.message || req.file.originalname || 'Mengirim berkas';
      if (isBuyer) {
        await notificationService.notifyStaffAndAdmins({
          title: 'Media Konsultasi Baru',
          message: `${consultation.buyer_name || 'Pembeli'}: ${summary.substring(0, 50)}${summary.length > 50 ? '...' : ''}`,
          type: 'consultation',
          actionUrl: '/consultations',
        });
      } else {
        await notificationService.createNotification({
          userId: consultation.buyer_user_id,
          title: 'Media Konsultasi Baru',
          message: `${senderName}: ${summary.substring(0, 50)}${summary.length > 50 ? '...' : ''}`,
          type: 'consultation',
          actionUrl: '/consultations',
        });
      }
    } catch (_) {}

    return res.status(201).json({
      message: 'Media chat berhasil dikirim',
      chatMessage: buildMessagePayload(message),
    });
  } catch (error) {
    return next(error);
  }
}

async function updateConsultationStatus(req, res, next) {
  try {
    const consultationId = validateConsultationId(req.params.id);
    const payload = validateStatusUpdateBody(req.body);
    const consultation = await consultationService.findConsultationById(consultationId);

    if (!consultation) {
      throw createError('Permintaan konsultasi tidak ditemukan', 404);
    }

    if (consultation.status === 'resolved' || consultation.status === 'rejected') {
      throw createError('Permintaan konsultasi ini sudah selesai diproses', 400);
    }

    const updatedConsultation = await consultationService.updateConsultationStatus({
      id: consultationId,
      status: payload.status,
      staffNotes: payload.staffNotes,
      processedByUserId: req.user.sub,
    });

    try {
      let statusLabel = 'Diproses';
      if (payload.status === 'contacted') statusLabel = 'Sudah Dihubungi';
      else if (payload.status === 'resolved') statusLabel = 'Selesai';
      else if (payload.status === 'rejected') statusLabel = 'Ditolak';

      await notificationService.createNotification({
        userId: updatedConsultation.buyer_user_id,
        title: 'Status Konsultasi Diperbarui',
        message: `Status konsultasi Anda (${updatedConsultation.topic || 'Umum'}) kini diperbarui menjadi: ${statusLabel}.`,
        type: 'consultation',
        actionUrl: '/consultations',
      });
    } catch (_) {}

    return res.status(200).json({
      message: 'Status permintaan permintaan konsultasi berhasil diperbarui',
      consultation: buildConsultationPayload(updatedConsultation),
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  createConsultationRequest,
  listMyConsultationRequests,
  getMyConsultationRoom,
  listConsultationRequestsForStaff,
  getConsultationDetail,
  listMyChats,
  updateConsultationStatus,
  listConsultationMessages,
  sendConsultationMessage,
  sendConsultationMedia,
};
