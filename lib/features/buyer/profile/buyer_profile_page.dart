import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import 'buyer_profile_controller.dart';
import 'buyer_profile_header.dart';
import 'buyer_profile_menu.dart';
import 'buyer_profile_logout_tile.dart';

class BuyerProfilePage extends StatefulWidget {
  const BuyerProfilePage({super.key});

  @override
  State<BuyerProfilePage> createState() => _BuyerProfilePageState();
}

class _BuyerProfilePageState extends State<BuyerProfilePage> {
  final controller = BuyerProfileController();

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: judul ──
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil Saya',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2F2318),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Kelola informasi akun dan aktivitas pembelian Anda',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8A7563),
                  height: 1.4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          BuyerProfileHeader(
            controller: controller,
            onUploadSuccess: () => setState(() {}),
          ),

          const SizedBox(height: 20),

          // ── Akun & Data Diri ──
          _buildSectionTitle('Akun & Data Diri'),
          const SizedBox(height: 12),
          BuyerProfileMenu(section: controller.sections[0]),

          const SizedBox(height: 20),

          // ── Aktivitas Pembelian ──
          _buildSectionTitle('Aktivitas Pembelian'),
          const SizedBox(height: 12),
          BuyerProfileMenu(section: controller.sections[1]),

          const SizedBox(height: 20),

          // ── Keluar ──
          BuyerProfileLogoutTile(
            item: BuyerProfileController.logoutItem,
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: Color(0xFF8A6F4D),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    await AuthService().clearSession();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}

