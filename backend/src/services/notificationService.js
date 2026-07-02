const pool = require('../config/db');

const SELECT_COLUMNS = `
  id_notification AS id,
  user_id,
  title,
  message,
  type,
  action_url,
  image_url,
  read_at,
  created_at,
  updated_at
`;

function normalizeLimit(value) {
  const limit = Number.parseInt(String(value || ''), 10);
  if (!Number.isInteger(limit) || limit <= 0) {
    return 50;
  }
  return Math.min(limit, 100);
}

function normalizeOffset(value) {
  const offset = Number.parseInt(String(value || ''), 10);
  return Number.isInteger(offset) && offset > 0 ? offset : 0;
}

async function findNotificationsByUserId(userId, { search, limit, offset } = {}) {
  const params = [userId];
  const conditions = ['user_id = ?'];

  if (search) {
    conditions.push('(title LIKE ? OR message LIKE ? OR type LIKE ?)');
    const keyword = `%${search}%`;
    params.push(keyword, keyword, keyword);
  }

  const normalizedLimit = normalizeLimit(limit);
  const normalizedOffset = normalizeOffset(offset);

  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLUMNS}
     FROM notifications
     WHERE ${conditions.join(' AND ')}
     ORDER BY created_at DESC, id_notification DESC
     LIMIT ${normalizedLimit} OFFSET ${normalizedOffset}`,
    params,
  );
  return rows;
}

async function findNotificationForUser({ id, userId }) {
  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLUMNS}
     FROM notifications
     WHERE id_notification = ? AND user_id = ?
     LIMIT 1`,
    [id, userId],
  );
  return rows[0] || null;
}

async function markNotificationAsRead({ id, userId }) {
  await pool.execute(
    `UPDATE notifications
     SET read_at = COALESCE(read_at, NOW())
     WHERE id_notification = ? AND user_id = ?`,
    [id, userId],
  );
  return findNotificationForUser({ id, userId });
}

async function deleteNotificationForUser({ id, userId }) {
  const [result] = await pool.execute(
    `DELETE FROM notifications
     WHERE id_notification = ? AND user_id = ?`,
    [id, userId],
  );
  return result.affectedRows > 0;
}

module.exports = {
  findNotificationsByUserId,
  findNotificationForUser,
  markNotificationAsRead,
  deleteNotificationForUser,
};

async function createNotification({ userId, title, message, type = 'info', actionUrl = null, imageUrl = null }) {
  const [result] = await pool.execute(
    `INSERT INTO notifications (user_id, title, message, type, action_url, image_url) VALUES (?, ?, ?, ?, ?, ?)`,
    [userId, title, message, type, actionUrl, imageUrl],
  );

  const [rows] = await pool.execute(
    `SELECT ${SELECT_COLUMNS} FROM notifications WHERE id_notification = ? LIMIT 1`,
    [result.insertId],
  );

  return rows[0] || null;
}

module.exports.createNotification = createNotification;

async function notifyStaffAndAdmins({ title, message, type = 'info', actionUrl = null, imageUrl = null }) {
  const [users] = await pool.execute(
    `SELECT id_user FROM users WHERE role IN ('staf', 'admin') AND is_active = 1`
  );
  
  if (users.length === 0) return;
  
  const values = users.map(u => [u.id_user, title, message, type, actionUrl, imageUrl]);
  
  // Use bulk insert for efficiency
  const placeholders = values.map(() => '(?, ?, ?, ?, ?, ?)').join(', ');
  const flatValues = values.flat();
  
  await pool.execute(
    `INSERT INTO notifications (user_id, title, message, type, action_url, image_url) VALUES ${placeholders}`,
    flatValues
  );
}

module.exports.notifyStaffAndAdmins = notifyStaffAndAdmins;

async function notifyAllBuyers({ title, message, type = 'info', actionUrl = null, imageUrl = null }) {
  const [users] = await pool.execute(
    `SELECT id_user FROM users WHERE role = 'pembeli' AND is_active = 1`
  );
  
  if (users.length === 0) return;
  
  const values = users.map(u => [u.id_user, title, message, type, actionUrl, imageUrl]);
  
  const placeholders = values.map(() => '(?, ?, ?, ?, ?, ?)').join(', ');
  const flatValues = values.flat();
  
  await pool.execute(
    `INSERT INTO notifications (user_id, title, message, type, action_url, image_url) VALUES ${placeholders}`,
    flatValues
  );
}

module.exports.notifyAllBuyers = notifyAllBuyers;
