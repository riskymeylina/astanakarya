import 'package:flutter/material.dart';

import '../../../features/shared/profile/profile_setting_tile.dart';
import '../../../services/auth_service.dart';

class BuyerProfileController {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? get session => _authService.getSession();

  String get userName => session?['name']?.toString() ?? 'Calon Pembeli';
  String get email => session?['email']?.toString() ?? '-';
  String get roleLabel =>
      UserRoles.label(session?['role']?.toString() ?? UserRoles.pembeli);
  String get accountStatus =>
      _isVerified ? 'Akun Aktif' : 'Sesi Offline';
  bool get _isVerified =>
      session?['sessionState']?.toString() == SessionState.verified;

  String get avatarInitials {
    final name = userName.trim();
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String? get avatarUrl =>
      _authService.resolveProfilePhotoUrl(
        session?['profilePhotoPath']?.toString(),
      );

  // Sections utama (tanpa logout)
  List<ProfileSectionData> get sections => [
        ProfileSectionData(
          title: 'Akun & Data Diri',
          items: const [
            ProfileSettingTileData(
              label: 'Data Pribadi',
              subtitle: 'Kelola data pribadi, kontak, dan alamat Anda',
              icon: Icons.person_rounded,
              route: '/buyer-administration',
            ),
            ProfileSettingTileData(
              label: 'Preferensi Properti',
              subtitle: 'Atur preferensi pencarian properti Anda',
              icon: Icons.house_rounded,
              route: '/property-preferences',
            ),
          ],
        ),
        ProfileSectionData(
          title: 'Aktivitas Pembelian',
          items: const [
            ProfileSettingTileData(
              label: 'Pengajuan Survei',
              subtitle: 'Lihat dan kelola jadwal survei',
              icon: Icons.event_available_rounded,
              route: '/buyer-survey-requests',
            ),
            ProfileSettingTileData(
              label: 'Status Pemesanan',
              subtitle: 'Pantau status pemesanan properti Anda',
              icon: Icons.assignment_turned_in_rounded,
              route: '/purchase-status',
            ),
          ],
        ),
      ];

  // Item logout terpisah
  static const ProfileSettingTileData logoutItem = ProfileSettingTileData(
    label: 'Keluar',
    subtitle: 'Keluar dari akun Anda',
    icon: Icons.logout_rounded,
    route: '__logout__',
  );
}