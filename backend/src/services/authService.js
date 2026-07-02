const pool = require('../config/db');
const { hashPassword, comparePassword } = require('../utils/password');

function createError(message, statusCode) {
  const error = new Error(message);
  error.statusCode = statusCode;
  return error;
}

async function findUserByEmail(email) {
  const [rows] = await pool.execute(
    'SELECT id_user AS id, name, email, phone, password_hash, role, is_active, profile_photo_path FROM users WHERE email = ? LIMIT 1',
    [email],
  );

  return rows[0] || null;
}

async function findUserById(id) {
  const [rows] = await pool.execute(
    'SELECT id_user AS id, name, email, phone, role, profile_photo_path FROM users WHERE id_user = ? LIMIT 1',
    [id],
  );

  return rows[0] || null;
}

function normalizeBuyerProfile(row) {
  if (!row) {
    return {
      email: '',
      phone: '',
      whatsapp: '',
      contact_note: '',
      recipient_name: '',
      address_line: '',
      province: '',
      city: '',
      district: '',
      subdistrict: '',
      postal_code: '',
      landmark: '',
    };
  }

  return {
    email: row.email || '',
    phone: row.phone || '',
    whatsapp: row.whatsapp || '',
    contact_note: row.contact_note || '',
    recipient_name: row.recipient_name || '',
    address_line: row.address_line || '',
    province: row.province || '',
    city: row.city || '',
    district: row.district || '',
    subdistrict: row.subdistrict || '',
    postal_code: row.postal_code || '',
    landmark: row.landmark || '',
  };
}

async function findBuyerProfileByUserId(userId) {
  const [rows] = await pool.execute(
    `SELECT u.email, u.phone, p.whatsapp, p.contact_note, p.recipient_name, p.address_line,
            p.province, p.city, p.district, p.subdistrict, p.postal_code, p.landmark
     FROM users u
     LEFT JOIN user_buyer_profiles p ON p.user_id = u.id_user
     WHERE u.id_user = ?
     LIMIT 1`,
    [userId],
  );

  return normalizeBuyerProfile(rows[0] || null);
}

async function ensureBuyerProfileRow(userId) {
  await pool.execute(
    `INSERT INTO user_buyer_profiles (user_id)
     VALUES (?)
     ON DUPLICATE KEY UPDATE user_id = VALUES(user_id)`,
    [userId],
  );
}

async function updateBuyerContact(userId, contact) {
  await pool.execute(
    `UPDATE users
     SET email = ?,
         phone = ?,
         updated_at = CURRENT_TIMESTAMP
     WHERE id_user = ?`,
    [contact.email, contact.phone, userId],
  );

  await ensureBuyerProfileRow(userId);
  await pool.execute(
    `UPDATE user_buyer_profiles
     SET whatsapp = ?,
         contact_note = ?,
         updated_at = CURRENT_TIMESTAMP
     WHERE user_id = ?`,
    [contact.whatsapp, contact.contactNote, userId],
  );

  return findBuyerProfileByUserId(userId);
}

async function updateBuyerAddress(userId, address) {
  await ensureBuyerProfileRow(userId);
  await pool.execute(
    `UPDATE user_buyer_profiles
     SET recipient_name = ?,
         address_line = ?,
         province = ?,
         city = ?,
         district = ?,
         subdistrict = ?,
         postal_code = ?,
         landmark = ?,
         updated_at = CURRENT_TIMESTAMP
     WHERE user_id = ?`,
    [
      address.recipientName,
      address.addressLine,
      address.province,
      address.city,
      address.district,
      address.subdistrict,
      address.postalCode,
      address.landmark,
      userId,
    ],
  );

  return findBuyerProfileByUserId(userId);
}

async function upsertBuyerProfile(userId, profile) {
  await updateBuyerContact(userId, profile);
  await updateBuyerAddress(userId, profile);
  return findBuyerProfileByUserId(userId);
}

async function createUser({ name, email, phone, password }) {
  const passwordHash = await hashPassword(password);

  const [result] = await pool.execute(
    `INSERT INTO users (name, email, phone, password_hash, role, profile_photo_path)
     VALUES (?, ?, ?, ?, 'pembeli', NULL)`,
    [name, email, phone, passwordHash],
  );

  return {
    id: result.insertId,
    name,
    email,
    phone,
    role: 'pembeli',
    profile_photo_path: null,
  };
}

async function registerUser({ name, email, phone, password }) {
  const existingUser = await findUserByEmail(email);
  if (existingUser) {
    throw createError('Email sudah digunakan', 409);
  }

  return createUser({ name, email, phone, password });
}

async function loginUser({ email, password }) {
  const user = await findUserByEmail(email);
  if (!user) {
    throw createError('Email atau password salah', 401);
  }

  if (user.is_active === 0 || user.is_active === false || user.is_active === '0') {
    throw createError('Akun Anda telah dinonaktifkan. Silakan hubungi admin.', 403);
  }

  const isPasswordValid = await comparePassword(password, user.password_hash);
  if (!isPasswordValid) {
    throw createError('Email atau password salah', 401);
  }

  return {
    id: user.id,
    name: user.name,
    email: user.email,
    phone: user.phone,
    role: user.role,
    profile_photo_path: user.profile_photo_path,
  };
}

async function findLatestPasswordResetRequestByUserId(userId) {
  const [rows] = await pool.execute(
    `SELECT user_id AS id, code_hash, expires_at, verified_at, consumed_at, attempt_count,
            last_sent_at, reset_session_token_hash, reset_session_expires_at, created_at, updated_at
     FROM password_reset_requests
     WHERE user_id = ? AND consumed_at IS NULL
     ORDER BY id DESC
     LIMIT 1`,
    [userId],
  );

  return rows[0] || null;
}

async function invalidatePasswordResetRequests(userId) {
  await pool.execute(
    `UPDATE password_reset_requests
     SET consumed_at = NOW(),
         updated_at = CURRENT_TIMESTAMP
     WHERE user_id = ? AND consumed_at IS NULL`,
    [userId],
  );
}

async function createPasswordResetRequest({ userId, codeHash, expiresAt }) {
  await invalidatePasswordResetRequests(userId);

  const [result] = await pool.execute(
    `INSERT INTO password_reset_requests (
      user_id,
      code_hash,
      expires_at,
      last_sent_at
    ) VALUES (?, ?, ?, NOW())`,
    [userId, codeHash, expiresAt],
  );

  return findPasswordResetRequestById(result.insertId);
}

async function findPasswordResetRequestById(id) {
  const [rows] = await pool.execute(
    `SELECT user_id AS id, code_hash, expires_at, verified_at, consumed_at, attempt_count,
            last_sent_at, reset_session_token_hash, reset_session_expires_at, created_at, updated_at
     FROM password_reset_requests
     WHERE user_id = ?
     LIMIT 1`,
    [id],
  );

  return rows[0] || null;
}

async function incrementPasswordResetAttempt(requestId) {
  await pool.execute(
    `UPDATE password_reset_requests
     SET attempt_count = attempt_count + 1,
         updated_at = CURRENT_TIMESTAMP
     WHERE id = ?`,
    [requestId],
  );

  return findPasswordResetRequestById(requestId);
}

async function markPasswordResetVerified(requestId, resetSessionTokenHash, resetSessionExpiresAt) {
  await pool.execute(
    `UPDATE password_reset_requests
     SET verified_at = NOW(),
         reset_session_token_hash = ?,
         reset_session_expires_at = ?,
         updated_at = CURRENT_TIMESTAMP
     WHERE user_id = ?`,
    [resetSessionTokenHash, resetSessionExpiresAt, requestId],
  );

  return findPasswordResetRequestById(requestId);
}

async function findValidPasswordResetSession(userId, resetSessionTokenHash) {
  const [rows] = await pool.execute(
    `SELECT user_id AS id, code_hash, expires_at, verified_at, consumed_at, attempt_count,
            last_sent_at, reset_session_token_hash, reset_session_expires_at, created_at, updated_at
     FROM password_reset_requests
     WHERE user_id = ?
       AND reset_session_token_hash = ?
       AND verified_at IS NOT NULL
       AND consumed_at IS NULL
       AND reset_session_expires_at IS NOT NULL
       AND reset_session_expires_at > NOW()
     ORDER BY id DESC
     LIMIT 1`,
    [userId, resetSessionTokenHash],
  );

  return rows[0] || null;
}

async function consumePasswordResetRequest(requestId) {
  await pool.execute(
    `UPDATE password_reset_requests
     SET consumed_at = NOW(),
         updated_at = CURRENT_TIMESTAMP
     WHERE user_id = ?`,
    [requestId],
  );
}

async function updateUserPassword(userId, password) {
  const passwordHash = await hashPassword(password);
  await pool.execute(
    'UPDATE users SET password_hash = ? WHERE id_user = ?',
    [passwordHash, userId],
  );

  return findUserById(userId);
}

async function updateProfilePhotoPath(userId, profilePhotoPath) {
  await pool.execute('UPDATE users SET profile_photo_path = ? WHERE id_user = ?', [profilePhotoPath, userId]);
  return findUserById(userId);
}

function normalizePropertyPreferences(row) {
  if (!row) {
    return {
      preferred_categories: [],
      preferred_location: '',
      min_price: null,
      max_price: null,
      min_bedrooms: null,
      min_bathrooms: null,
      min_building_area: null,
      min_land_area: null,
      notes: '',
    };
  }

  let preferredCategories = [];
  try {
    const parsed = JSON.parse(row.preferred_categories || '[]');
    if (Array.isArray(parsed)) {
      preferredCategories = parsed
        .map((item) => String(item || '').trim())
        .filter((item) => item.length > 0);
    }
  } catch (_) {
    preferredCategories = [];
  }

  return {
    preferred_categories: preferredCategories,
    preferred_location: row.preferred_location || '',
    min_price: row.min_price ?? null,
    max_price: row.max_price ?? null,
    min_bedrooms: row.min_bedrooms ?? null,
    min_bathrooms: row.min_bathrooms ?? null,
    min_building_area: row.min_building_area ?? null,
    min_land_area: row.min_land_area ?? null,
    notes: row.notes || '',
  };
}

async function findUserPropertyPreferencesByUserId(userId) {
  const [rows] = await pool.execute(
    `SELECT user_id, preferred_categories, preferred_location, min_price, max_price,
            min_bedrooms, min_bathrooms, min_building_area, min_land_area, notes
     FROM user_property_preferences
     WHERE user_id = ?
     LIMIT 1`,
    [userId],
  );

  return normalizePropertyPreferences(rows[0] || null);
}

async function upsertUserPropertyPreferences(userId, preferences) {
  await pool.execute(
    `INSERT INTO user_property_preferences (
      user_id,
      preferred_categories,
      preferred_location,
      min_price,
      max_price,
      min_bedrooms,
      min_bathrooms,
      min_building_area,
      min_land_area,
      notes
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      preferred_categories = VALUES(preferred_categories),
      preferred_location = VALUES(preferred_location),
      min_price = VALUES(min_price),
      max_price = VALUES(max_price),
      min_bedrooms = VALUES(min_bedrooms),
      min_bathrooms = VALUES(min_bathrooms),
      min_building_area = VALUES(min_building_area),
      min_land_area = VALUES(min_land_area),
      notes = VALUES(notes),
      updated_at = CURRENT_TIMESTAMP`,
    [
      userId,
      JSON.stringify(preferences.preferredCategories),
      preferences.preferredLocation,
      preferences.minPrice,
      preferences.maxPrice,
      preferences.minBedrooms,
      preferences.minBathrooms,
      preferences.minBuildingArea,
      preferences.minLandArea,
      preferences.notes,
    ],
  );

  return findUserPropertyPreferencesByUserId(userId);
}

module.exports = {
  findUserByEmail,
  findUserById,
  registerUser,
  loginUser,
  findLatestPasswordResetRequestByUserId,
  createPasswordResetRequest,
  incrementPasswordResetAttempt,
  markPasswordResetVerified,
  findValidPasswordResetSession,
  consumePasswordResetRequest,
  invalidatePasswordResetRequests,
  updateUserPassword,
  updateProfilePhotoPath,
  findBuyerProfileByUserId,
  updateBuyerContact,
  updateBuyerAddress,
  upsertBuyerProfile,
  findUserPropertyPreferencesByUserId,
  upsertUserPropertyPreferences,
};
