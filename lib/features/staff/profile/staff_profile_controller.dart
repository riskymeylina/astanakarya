import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class StaffHeaderStat {
  final String label;
  final int count;
  final String sublabel;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const StaffHeaderStat({
    required this.label,
    required this.count,
    required this.sublabel,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}

class OperationalMenuData {
  final String label;
  final String subtitle;
  final IconData icon;
  final String route;

  const OperationalMenuData({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}

class UpcomingSurveyItem {
  final String propertyName;
  final String location;
  final String clientName;
  final String date;
  final String time;
  final String status;

  const UpcomingSurveyItem({
    required this.propertyName,
    required this.location,
    required this.clientName,
    required this.date,
    required this.time,
    required this.status,
  });
}

class SystemMenuData {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String? route;
  final bool isLogout;

  const SystemMenuData({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.route,
    this.isLogout = false,
  });
}

class StaffProfileController {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? get session => _authService.getSession();

  Future<void> logout() async {
    await _authService.clearSession();
  }

  String get userName => session?['name']?.toString() ?? 'Staf Pemasaran';
  String get email => session?['email']?.toString() ?? '-';
  String get roleLabel => session?['role']?.toString() ?? 'Staf Pemasaran';
  String get accountStatus => _isVerified ? 'Akun Aktif' : 'Sesi Offline';
  bool get _isVerified => session?['sessionState']?.toString() == 'verified';

  String get avatarInitials {
    final name = userName.trim();
    if (name.isEmpty) return 'S';
    final parts = name.split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String? get avatarUrl => _authService.resolveProfilePhotoUrl(
        session?['profilePhotoPath']?.toString(),
      );

  String get phone => session?['phone']?.toString() ?? '0812-3456-7890';
  String get joinDate => session?['joinDate']?.toString() ?? '12 Januari 2024';
  String get department => 'Pemasaran & Penjualan';
  String get jabatan => session?['role']?.toString() ?? 'Staf Pemasaran';
  String get officeAddress => 'Jl. Raya Solo Baru No. 88, Sukoharjo, Jawa Tengah 57552';
  String get workHours => 'Senin – Jumat, 08:00 – 17:00';

  List<StaffHeaderStat> get headerStats => const [
        StaffHeaderStat(
          label: 'Chat Konsultasi',
          count: 32,
          sublabel: 'Bulan ini',
          icon: Icons.chat_bubble_outline_rounded,
          iconColor: Color(0xFF4A90D9),
          iconBg: Color(0xFFE8F2FC),
        ),
        StaffHeaderStat(
          label: 'Survei Dijadwalkan',
          count: 18,
          sublabel: 'Bulan ini',
          icon: Icons.calendar_today_rounded,
          iconColor: Color(0xFF3DAA6E),
          iconBg: Color(0xFFE6F7EE),
        ),
        StaffHeaderStat(
          label: 'Survei Selesai',
          count: 12,
          sublabel: 'Bulan ini',
          icon: Icons.check_circle_outline_rounded,
          iconColor: Color(0xFF6B4FD8),
          iconBg: Color(0xFFF0EEFC),
        ),
        StaffHeaderStat(
          label: 'Pemesanan Ditangani',
          count: 24,
          sublabel: 'Bulan ini',
          icon: Icons.assignment_outlined,
          iconColor: Color(0xFFCB7D2A),
          iconBg: Color(0xFFFFF2E0),
        ),
      ];

  List<OperationalMenuData> get operationalMenus => const [
        OperationalMenuData(
          label: 'Jadwal Survei',
          subtitle: 'Kelola dan lihat jadwal survei properti',
          icon: Icons.calendar_month_outlined,
          route: '/marketing-survey-requests',
        ),
        OperationalMenuData(
          label: 'Rekap Data',
          subtitle: 'Lihat rekap aktivitas penjualan dan survei',
          icon: Icons.bar_chart_rounded,
          route: '/marketing-transaction-recap',
        ),
        OperationalMenuData(
          label: 'Konsultasi Konsumen',
          subtitle: 'Lihat dan balas chat konsumen',
          icon: Icons.chat_outlined,
          route: '/staff/konsultasi',
        ),
        OperationalMenuData(
          label: 'Ketersediaan Properti',
          subtitle: 'Kelola ketersediaan unit properti',
          icon: Icons.home_outlined,
          route: '/staff/ketersediaan-properti',
        ),
      ];

  List<UpcomingSurveyItem> get upcomingSurveys => const [
        UpcomingSurveyItem(
          propertyName: 'Astana Residence Prambanan',
          location: 'Tlogo, Prambanan, Klaten',
          clientName: 'Budi Santoso',
          date: '12 Jun 2026',
          time: '10:00 WIB',
          status: 'Dijadwalkan',
        ),
        UpcomingSurveyItem(
          propertyName: 'Grand Harmoni Residence',
          location: 'Manisrenggo, Klaten',
          clientName: 'Andi Pratama',
          date: '12 Jun 2026',
          time: '14:00 WIB',
          status: 'Dijadwalkan',
        ),
        UpcomingSurveyItem(
          propertyName: 'Permata Village Klaten',
          location: 'Karanganom, Klaten',
          clientName: 'Siti Aminah',
          date: '13 Jun 2026',
          time: '09:00 WIB',
          status: 'Dijadwalkan',
        ),
      ];

  List<SystemMenuData> get systemMenus => const [
        SystemMenuData(
          label: 'Notifikasi',
          subtitle: 'Atur preferensi notifikasi Anda',
          icon: Icons.notifications_none_rounded,
          iconColor: Color(0xFFCB7D2A),
          iconBg: Color(0xFFFFF2E0),
          route: '/notifications',
        ),
        SystemMenuData(
          label: 'Keluar',
          subtitle: 'Logout dari akun staf Anda',
          icon: Icons.logout_rounded,
          iconColor: Color(0xFFC74C4C),
          iconBg: Color(0xFFFCECEC),
          isLogout: true,
        ),
      ];
}