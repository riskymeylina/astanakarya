// ===============================
// STAFF PROFILE PAGE
// ===============================

import 'package:flutter/material.dart';

import 'staff_profile_controller.dart';
import 'staff_profile_header.dart';

class StaffProfilePage extends StatefulWidget {
  const StaffProfilePage({super.key});

  @override
  State<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends State<StaffProfilePage> {
  final controller = StaffProfileController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F4EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page title
              _PageTitle(),

              const SizedBox(height: 20),

              // ── Profile header card
              StaffProfileHeader(
                controller: controller,
                onEditProfile: () => _showEditSheet(context, controller),
                onUploadSuccess: () => setState(() {}),
              ),

              const SizedBox(height: 20),

              // ── 4 Operational menu cards
              _OperationalMenuRow(controller: controller),

              const SizedBox(height: 24),

              // ── Akses Fitur section
              _AksesFiturCard(controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext ctx, StaffProfileController c) {
    final nameCtrl  = TextEditingController(text: c.userName);
    final phoneCtrl = TextEditingController(text: c.phone);
    final emailCtrl = TextEditingController(text: c.email);

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(
        nameCtrl:  nameCtrl,
        phoneCtrl: phoneCtrl,
        emailCtrl: emailCtrl,
      ),
    );
  }
}

// ================================================================
// PAGE TITLE
// ================================================================

class _PageTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Profil Staf',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2F2318),
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Kelola informasi akun, kontak kerja, dan akses fitur penjualan.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF8A7563),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// OPERATIONAL MENU ROW  (4 cards: Jadwal, Rekap, Konsultasi, Ketersediaan)
// ================================================================

class _OperationalMenuRow extends StatelessWidget {
  final StaffProfileController controller;

  const _OperationalMenuRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuCardData(
        title: 'Jadwal Survei',
        subtitle: 'Kelola jadwal survei properti yang akan datang.',
        icon: Icons.calendar_month_outlined,
        watermarkIcon: Icons.calendar_month_rounded,
        iconColor: const Color(0xFFCB7D2A),
        iconBg: const Color(0xFFFFF0DD),
        route: '/marketing-survey-requests',
      ),
      _MenuCardData(
        title: 'Rekap Data',
        subtitle: 'Lihat ringkasan data pemesanan properti.',
        icon: Icons.bar_chart_rounded,
        watermarkIcon: Icons.pie_chart_rounded,
        iconColor: const Color(0xFF3DAA6E),
        iconBg: const Color(0xFFE8F7EF),
        route: '/marketing-transaction-recap',
      ),
      _MenuCardData(
        title: 'Konsultasi Konsumen',
        subtitle: 'Lihat dan balas chat konsumen terbaru.',
        icon: Icons.chat_bubble_outline_rounded,
        watermarkIcon: Icons.chat_rounded,
        iconColor: const Color(0xFF6B4FD8),
        iconBg: const Color(0xFFF0EEFC),
        route: '/staff/konsultasi',
      ),
      _MenuCardData(
        title: 'Ketersediaan Properti',
        subtitle: 'Kelola ketersediaan unit properti terbaru.',
        icon: Icons.home_outlined,
        watermarkIcon: Icons.home_rounded,
        iconColor: const Color(0xFF4A90D9),
        iconBg: const Color(0xFFE8F2FC),
        route: '/staff/ketersediaan-properti',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        if (isMobile) {
          return Column(
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MenuCard(data: item),
            )).toList(),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 12),
                child: _MenuCard(data: entry.value),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _MenuCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final IconData watermarkIcon;
  final Color iconColor;
  final Color iconBg;
  final String route;

  const _MenuCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.watermarkIcon,
    required this.iconColor,
    required this.iconBg,
    required this.route,
  });
}

class _MenuCard extends StatelessWidget {
  final _MenuCardData data;

  const _MenuCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, data.route),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEDE0D4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCB7D2A).withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Watermark icon – bottom right
            Positioned(
              bottom: -12,
              right: -10,
              child: Icon(
                data.watermarkIcon,
                size: 110,
                color: data.iconColor.withOpacity(0.08),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + chevron row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: data.iconBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          data.icon,
                          size: 24,
                          color: data.iconColor,
                        ),
                      ),

                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: data.iconBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: data.iconColor,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Title
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2F2318),
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Subtitle
                  Text(
                    data.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A7563),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// AKSES FITUR CARD
// ================================================================

class _AksesFiturCard extends StatelessWidget {
  final StaffProfileController controller;

  const _AksesFiturCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE0D4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Akses Fitur',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2F2318),
            ),
          ),

          const SizedBox(height: 2),

          const Text(
            'Akses cepat ke fitur pendukung akun dan sistem.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8A7563),
            ),
          ),

          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final menus = controller.systemMenus;

              if (isMobile) {
                return Column(
                  children: menus.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AksesTile(
                      menu: m,
                      onTap: () => _handleMenuTap(context, m),
                    ),
                  )).toList(),
                );
              }

              return Row(
                children: menus.asMap().entries.map((entry) {
                  final isLast = entry.key == menus.length - 1;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 10),
                      child: _AksesTile(
                        menu: entry.value,
                        onTap: () => _handleMenuTap(context, entry.value),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleMenuTap(BuildContext context, SystemMenuData menu) async {
    if (menu.isLogout) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Keluar',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Apakah Anda yakin ingin logout dari akun ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC74C4C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Keluar'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await controller.logout();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (_) => false,
          );
        }
      }
      return;
    }

    if (menu.route != null) {
      Navigator.pushNamed(context, menu.route!);
    }
  }
}

class _AksesTile extends StatelessWidget {
  final SystemMenuData menu;
  final VoidCallback onTap;

  const _AksesTile({required this.menu, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: menu.isLogout
              ? const Color(0xFFFFF5F5)
              : const Color(0xFFFFF8F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: menu.isLogout
                ? const Color(0xFFF5CECE)
                : const Color(0xFFEDE0D4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: menu.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                menu.icon,
                size: 20,
                color: menu.iconColor,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: menu.isLogout
                          ? const Color(0xFFC74C4C)
                          : const Color(0xFF2F2318),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    menu.subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8A7563),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: menu.isLogout
                  ? const Color(0xFFC74C4C)
                  : const Color(0xFFCB7D2A),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// EDIT PROFILE BOTTOM SHEET
// ================================================================

class _EditProfileSheet extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;

  const _EditProfileSheet({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0D0C0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Edit Profil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2F2318),
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Perbarui informasi profil Anda.',
              style: TextStyle(fontSize: 13, color: Color(0xFF8A7563)),
            ),

            const SizedBox(height: 22),

            _EditField(
              label: 'Nama Lengkap',
              controller: nameCtrl,
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 14),

            _EditField(
              label: 'Nomor Telepon',
              controller: phoneCtrl,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 14),

            _EditField(
              label: 'Email',
              controller: emailCtrl,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFCB7D2A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        color: Color(0xFFCB7D2A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil berhasil diperbarui.'),
                          backgroundColor: Color(0xFFCB7D2A),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCB7D2A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;

  const _EditField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B5742),
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFFCB7D2A)),
            filled: true,
            fillColor: const Color(0xFFFFF8F2),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE7CCAE)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE7CCAE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFCB7D2A),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}