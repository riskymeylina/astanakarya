const pool = require('../config/db');

const SELECT_COLUMNS = `
  cr.id_property_consultation_request AS id,
  cr.buyer_user_id,
  cr.property_id,
  cr.topic,
  cr.preferred_contact_method,
  cr.message,
  cr.status,
  cr.staff_notes,
  cr.processed_by_user_id,
  cr.processed_at,
  cr.created_at,
  cr.updated_at,
  buyer.name AS buyer_name,
  buyer.phone AS buyer_phone,
  buyer.email AS buyer_email,
  ubp.whatsapp AS buyer_whatsapp,
  p.title AS property_title,
  p.location AS property_location,
  processor.name AS processed_by_name
`;

const BASE_JOIN = `
  FROM property_consultation_requests cr
  INNER JOIN users buyer ON buyer.id_user = cr.buyer_user_id
  LEFT JOIN user_buyer_profiles ubp ON ubp.user_id = buyer.id_user
  LEFT JOIN properties p ON p.id_property = cr.property_id
  LEFT JOIN users processor ON processor.id_user = cr.processed_by_user_id
`;

async function findConsultationById(id) {
  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLUMNS} ${BASE_JOIN} WHERE cr.id_property_consultation_request = ? LIMIT 1`,
    [id],
  );
  return rows[0] || null;
}

async function findDefaultStaffUser() {
  const [rows] = await pool.execute(
    `SELECT id_user AS id, email
     FROM users
     WHERE role IN ('staf', 'admin')
     ORDER BY FIELD(role, 'staf', 'admin'), id_user ASC
     LIMIT 1`,
  );
  return rows[0] || null;
}

async function findOrCreateCustomerServiceRoom(buyerUserId) {
  const [existingRows] = await pool.execute(
    `SELECT ${SELECT_COLUMNS} ${BASE_JOIN}
     WHERE cr.buyer_user_id = ?
       AND cr.property_id IS NULL
       AND cr.topic = 'Konsultasi umum'
     ORDER BY cr.id_property_consultation_request ASC
     LIMIT 1`,
    [buyerUserId],
  );

  if (existingRows[0]) {
    return existingRows[0];
  }

  const staff = await findDefaultStaffUser();
  const [result] = await pool.execute(
    `INSERT INTO property_consultation_requests (
       buyer_user_id,
       property_id,
       topic,
       preferred_contact_method,
       message,
       status,
       staff_notes,
       processed_by_user_id,
       processed_at
     ) VALUES (?, NULL, 'Konsultasi umum', 'Chat Aplikasi', 'Halo, ada yang bisa kami bantu?', 'contacted', 'Staf siap membantu melalui chat.', ?, NOW())`,
    [buyerUserId, staff?.id || null],
  );

  return findConsultationById(result.insertId);
}

async function findConsultationsByBuyerId(buyerUserId) {
  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLUMNS},
            last_message.message AS last_message,
            last_message.created_at AS last_message_at,
            last_message.sender_user_id AS last_message_sender_user_id,
            last_message.read_at AS last_message_read_at,
            COALESCE(unread.unread_count, 0) AS unread_count
     ${BASE_JOIN}
     LEFT JOIN consultation_messages last_message ON last_message.id_consultation_message = (
       SELECT cm.id_consultation_message
       FROM consultation_messages cm
       WHERE cm.consultation_id = cr.id_property_consultation_request
       ORDER BY cm.created_at DESC, cm.id_consultation_message DESC
       LIMIT 1
     )
     LEFT JOIN (
       SELECT consultation_id, COUNT(*) AS unread_count
       FROM consultation_messages
       WHERE sender_user_id <> ? AND read_at IS NULL
       GROUP BY consultation_id
     ) unread ON unread.consultation_id = cr.id_property_consultation_request
     WHERE cr.buyer_user_id = ?
     ORDER BY COALESCE(last_message.created_at, cr.updated_at, cr.created_at) DESC, cr.id_property_consultation_request DESC`,
    [buyerUserId, buyerUserId],
  );
  return rows;
}

async function findAllConsultations({ status, viewerUserId } = {}) {
  const params = [];
  const conditions = [];

  if (status) {
    conditions.push('cr.status = ?');
    params.push(status);
  }

  // Filter out if buyer is not active or not a pembeli anymore
  conditions.push("buyer.role = 'pembeli'");
  conditions.push("buyer.is_active = 1");

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLUMNS},
            last_message.message AS last_message,
            last_message.created_at AS last_message_at,
            last_message.sender_user_id AS last_message_sender_user_id,
            last_message.read_at AS last_message_read_at,
            COALESCE(unread.unread_count, 0) AS unread_count
     ${BASE_JOIN}
     LEFT JOIN consultation_messages last_message ON last_message.id_consultation_message = (
       SELECT cm.id_consultation_message
       FROM consultation_messages cm
       WHERE cm.consultation_id = cr.id_property_consultation_request
       ORDER BY cm.created_at DESC, cm.id_consultation_message DESC
       LIMIT 1
     )
     LEFT JOIN (
       SELECT consultation_id, COUNT(*) AS unread_count
       FROM consultation_messages
       WHERE sender_user_id <> ? AND read_at IS NULL
       GROUP BY consultation_id
     ) unread ON unread.consultation_id = cr.id_property_consultation_request
     ${whereClause}
     ORDER BY COALESCE(last_message.created_at, cr.updated_at, cr.created_at) DESC, cr.id_property_consultation_request DESC`,
    [viewerUserId || 0, ...params],
  );
  return rows;
}

async function createConsultationRequest({
  buyerUserId,
  propertyId,
  topic,
  preferredContactMethod,
  message,
}) {
  const [result] = await pool.execute(
    `INSERT INTO property_consultation_requests (
       buyer_user_id,
       property_id,
       topic,
       preferred_contact_method,
       message,
       status
     ) VALUES (?, ?, ?, ?, ?, 'pending')`,
    [buyerUserId, propertyId || null, topic, preferredContactMethod, message],
  );

  return findConsultationById(result.insertId);
}

async function updateConsultationStatus({ id, status, staffNotes, processedByUserId }) {
  await pool.execute(
    `UPDATE property_consultation_requests
     SET status = ?,
         staff_notes = ?,
         processed_by_user_id = ?,
         processed_at = NOW()
     WHERE id_property_consultation_request = ?`,
    [status, staffNotes || null, processedByUserId, id],
  );
  return findConsultationById(id);
}

async function findPropertyForConsultation(propertyId) {
  const [rows] = await pool.execute(
    `SELECT id_property AS id, title, location, status FROM properties WHERE id_property = ? LIMIT 1`,
    [propertyId],
  );
  return rows[0] || null;
}

async function findConsultationMessages(consultationId) {
  const [rows] = await pool.execute(
    `SELECT id_consultation_message AS id, consultation_id, sender_user_id, sender_name, sender_role,
            message_type, message, media_path, media_name, media_mime, created_at, read_at
     FROM consultation_messages
     WHERE consultation_id = ?
     ORDER BY created_at ASC, id_consultation_message ASC`,
    [consultationId],
  );
  return rows;
}

async function markConsultationMessagesRead({ consultationId, viewerUserId }) {
  await pool.execute(
    `UPDATE consultation_messages
     SET read_at = COALESCE(read_at, NOW())
     WHERE consultation_id = ? AND sender_user_id <> ? AND read_at IS NULL`,
    [consultationId, viewerUserId],
  );
}

async function createConsultationMessage({
  consultationId,
  senderUserId,
  senderName,
  senderRole,
  message,
  messageType = 'text',
  mediaPath = null,
  mediaName = null,
  mediaMime = null,
}) {
  const [result] = await pool.execute(
    `INSERT INTO consultation_messages (
       consultation_id, sender_user_id, sender_name, sender_role,
       message_type, message, media_path, media_name, media_mime
     ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      consultationId,
      senderUserId,
      senderName,
      senderRole,
      messageType,
      message,
      mediaPath,
      mediaName,
      mediaMime,
    ],
  );

  const [rows] = await pool.execute(
    `SELECT id_consultation_message AS id, consultation_id, sender_user_id, sender_name, sender_role,
            message_type, message, media_path, media_name, media_mime, created_at, read_at
     FROM consultation_messages
     WHERE id_consultation_message = ?
     LIMIT 1`,
    [result.insertId],
  );
  return rows[0] || null;
}

module.exports = {
  findConsultationById,
  findOrCreateCustomerServiceRoom,
  findConsultationsByBuyerId,
  findAllConsultations,
  createConsultationRequest,
  updateConsultationStatus,
  findPropertyForConsultation,
  findConsultationMessages,
  markConsultationMessagesRead,
  createConsultationMessage,
};
