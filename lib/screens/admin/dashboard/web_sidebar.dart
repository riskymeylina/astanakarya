import 'package:flutter/material.dart';

class WebSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onMenuTap;
  final String userName;
  final String userRole;
  final VoidCallback onLogout;

  const WebSidebar({
    super.key,
    required this.selectedIndex,
    required this.onMenuTap,
    required this.userName,
    required this.userRole,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF6F3212), Color(0xFF5A2A0D), Color(0xFF421C06)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'PT.ASTANA KARYA BANDAWASA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Menu Label
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'MENU',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role-based menu items
                  ..._buildMenuItems(),

                  const SizedBox(height: 16),
                  
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
                    title: const Text('Logout', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                    onTap: onLogout,
                    hoverColor: Colors.white.withOpacity(0.05),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom profile
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userRole,
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title, {int? badgeCount}) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF6EC) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF8B3E0F) : Colors.white70,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF8B3E0F) : Colors.white70,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        trailing: badgeCount != null
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFCC7A2E),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => onMenuTap(index),
        hoverColor: isSelected ? Colors.transparent : Colors.white.withOpacity(0.05),
      ),
    );
  }

  // Build role‑based menu items based on user role
  List<Widget> _buildMenuItems() {
    if (userRole.toLowerCase().contains('staf')) {
      return [
        _buildMenuItem(0, Icons.home_rounded, 'Dashboard'),
        _buildMenuItem(1, Icons.schedule_rounded, 'Jadwal Survei'),
        _buildMenuItem(2, Icons.chat_rounded, 'Konsultasi'),
        _buildMenuItem(3, Icons.analytics_rounded, 'Ketersediaan Properti'),
        _buildMenuItem(4, Icons.receipt_long_rounded, 'Rekap Data'),
      ];
    }
    // Admin/Marketing default menu
    return [
      _buildMenuItem(0, Icons.home_rounded, 'Dashboard'),
      _buildMenuItem(1, Icons.domain_rounded, 'Kelola Properti'),
      _buildMenuItem(2, Icons.trending_up_rounded, 'Laporan Penjualan'),
      _buildMenuItem(3, Icons.people_alt_rounded, 'Kelola Pembeli'),
      _buildMenuItem(4, Icons.badge_rounded, 'Kelola Staf'),
    ];
  }
}
