import 'package:flutter/material.dart';

import '../../../features/shared/profile/profile_setting_tile.dart';
import '../../../services/auth_service.dart';

class AdminProfileController {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? get session => _authService.getSession();

  String get userName => session?['name']?.toString() ?? 'Administrator';
  String get email => session?['email']?.toString() ?? '-';
  String get roleLabel =>
      UserRoles.label(session?['role']?.toString() ?? UserRoles.pembeli);
  String get accountStatus =>
      _isVerified ? 'Akun Aktif' : 'Sesi Offline';
  bool get _isVerified =>
      session?['sessionState']?.toString() == SessionState.verified;
  String get avatarInitials {
    final name = userName.trim();
    if (name.isEmpty) return 'A';
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

  List<ProfileSectionData> get sections => [
        ProfileSectionData(
          title: 'Manajemen Sistem',
          items: const [
            ProfileSettingTileData(
              label: 'Manajemen User',
              subtitle: 'Kelola calon pembeli dan akun pengguna',
              icon: Icons.person_search_rounded,
              route: '/admin/buyers',
            ),
            ProfileSettingTileData(
              label: 'Manajemen Staff',
              subtitle: 'Kelola staf pemasaran dan hak akses',
              icon: Icons.group_add_rounded,
              route: '/admin/staff',
            ),
            ProfileSettingTileData(
              label: 'Manajemen Properti',
              subtitle: 'Kelola daftar properti dan inventaris',
              icon: Icons.apartment_rounded,
              route: '/admin/properties',
            ),
            ProfileSettingTileData(
              label: 'Manajemen Survei',
              subtitle: 'Laporan dan detail aktivitas survei',
              icon: Icons.manage_search_rounded,
              route: '/admin/reports/global',
            ),
            ProfileSettingTileData(
              label: 'Statistik Sistem',
              subtitle: 'Pantau performa sistem dan laporan',
              icon: Icons.analytics_rounded,
              route: '/admin/reports/sales',
            ),
          ],
        ),
        ProfileSectionData(
          title: 'Dukungan',
          items: const [
            ProfileSettingTileData(
              label: 'Notifikasi',
              subtitle: 'Kelola pemberitahuan sistem',
              icon: Icons.notifications_rounded,
              route: '/notifications',
            ),
          ],
        ),
      ];
}
