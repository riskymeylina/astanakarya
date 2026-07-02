const adminUserService = require('../services/adminUserService');
const authService = require('../services/authService');
const notificationService = require('../services/notificationService');

function createError(message, statusCode) {
  const error = new Error(message);
  error.statusCode = statusCode;
  return error;
}

function validateUserId(value) {
  const id = Number.parseInt(String(value || ''), 10);
  if (!Number.isInteger(id) || id <= 0) {
    throw createError('ID user tidak valid', 400);
  }
  return id;
}

function buildUserPayload(user) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    phone: user.phone,
    role: user.role,
    isActive: user.is_active === 1 || user.is_active === true || user.is_active === '1',
    profilePhotoPath: user.profile_photo_path,
    createdAt: user.created_at,
    updatedAt: user.updated_at,
  };
}

async function listUsers(req, res, next) {
  try {
    const role = req.query.role;
    const users = await adminUserService.findUsers({ role });
    return res.status(200).json({
      message: 'Data user berhasil diambil',
      users: users.map(buildUserPayload),
    });
  } catch (error) {
    return next(error);
  }
}

async function createStaff(req, res, next) {
  try {
    const { name, email, phone, password } = req.body;
    if (!name?.trim() || !email?.trim() || !phone?.trim() || !password) {
      throw createError('Semua field wajib diisi', 400);
    }

    const existingUser = await authService.findUserByEmail(email.trim().toLowerCase());
    if (existingUser) {
      throw createError('Email sudah terdaftar', 409);
    }

    const staff = await adminUserService.createStaff({
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      password,
    });

    try {
      await notificationService.notifyStaffAndAdmins({
        title: 'Akun Staf Baru Ditambahkan',
        message: `Staf baru telah ditambahkan ke sistem: ${staff.name} (${staff.email}).`,
        type: 'user',
        actionUrl: '/home',
      });
    } catch (_) {}

    return res.status(201).json({
      message: 'Akun staf berhasil dibuat',
      user: buildUserPayload(staff),
    });
  } catch (error) {
    return next(error);
  }
}

async function updateUser(req, res, next) {
  try {
    const userId = validateUserId(req.params.id);
    const { name, email, phone, isActive } = req.body;

    if (!name?.trim() || !email?.trim() || !phone?.trim()) {
      throw createError('Nama, email, dan nomor telepon wajib diisi', 400);
    }

    const user = await authService.findUserById(userId);
    if (!user) {
      throw createError('User tidak ditemukan', 404);
    }

    const emailOwner = await authService.findUserByEmail(email.trim().toLowerCase());
    if (emailOwner && Number(emailOwner.id) !== Number(userId)) {
      throw createError('Email sudah digunakan oleh akun lain', 409);
    }

    const updated = await adminUserService.updateUser(userId, {
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      isActive: isActive !== false, // Default to true if not specified
    });

    return res.status(200).json({
      message: 'Data staf berhasil diperbarui',
      user: buildUserPayload(updated),
    });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  listUsers,
  createStaff,
  updateUser,
};
