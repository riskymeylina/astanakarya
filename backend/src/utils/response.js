function buildUserPayload(user) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    phone: user.phone,
    role: user.role,
    profilePhotoPath: user.profile_photo_path || user.profilePhotoPath || null,
  };
}

function buildAuthResponse(message, token, user) {
  return {
    message,
    token,
    user: buildUserPayload(user),
  };
}

function buildUserResponse(message, user) {
  return {
    message,
    user: buildUserPayload(user),
  };
}

module.exports = {
  buildAuthResponse,
  buildUserResponse,
};
