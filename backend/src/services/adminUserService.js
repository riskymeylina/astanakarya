const pool = require('../config/db');

async function findUsers({ role } = {}) {
  const params = [];
  const conditions = [];

  if (role) {
    conditions.push('role = ?');
    params.push(role);
  }

  const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
  const [rows] = await pool.execute(
    `SELECT id_user AS id, name, email, phone, role, is_active, profile_photo_path, created_at, updated_at
     FROM users
     ${whereClause}
     ORDER BY created_at DESC, id_user DESC`,
    params,
  );

  return rows;
}

async function findUserById(id) {
  const [rows] = await pool.execute(
    `SELECT id_user AS id, name, email, phone, role, is_active, profile_photo_path, created_at, updated_at
     FROM users
     WHERE id_user = ?
     LIMIT 1`,
    [id],
  );
  return rows[0] || null;
}

async function createStaff({ name, email, phone, password }) {
  const { hashPassword } = require('../utils/password');
  const passwordHash = await hashPassword(password);
  const [result] = await pool.execute(
    `INSERT INTO users (name, email, phone, password_hash, role, is_active)
     VALUES (?, ?, ?, ?, 'staf', 1)`,
    [name, email, phone, passwordHash],
  );
  return findUserById(result.insertId);
}

async function updateUser(id, { name, email, phone, isActive }) {
  await pool.execute(
    `UPDATE users
     SET name = ?, email = ?, phone = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP
     WHERE id_user = ?`,
    [name, email, phone, isActive ? 1 : 0, id],
  );
  return findUserById(id);
}

async function updateUserRole(id, role) {
  await pool.execute(
    `UPDATE users
     SET role = ?, updated_at = CURRENT_TIMESTAMP
     WHERE id_user = ?`,
    [role, id],
  );
  return findUserById(id);
}

async function deleteUser(id) {
  const [result] = await pool.execute('DELETE FROM users WHERE id_user = ?', [id]);
  return result.affectedRows > 0;
}

module.exports = {
  findUsers,
  findUserById,
  createStaff,
  updateUser,
  updateUserRole,
  deleteUser,
};
