import 'package:flutter/material.dart';

import 'home_models.dart';

class HomeSimpleTabView extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonLabel;
  final VoidCallback? onPressed;

  const HomeSimpleTabView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: Colors.black87),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onPressed ?? () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDD096),
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeProfileMenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<HomeProfileMenuItem> items;

  const HomeProfileMenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7CCAE)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE9C9),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF8E4E16)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3A2B1F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                  minLeadingWidth: 24,
                  leading: Icon(
                    item.icon,
                    size: 18,
                    color: const Color(0xFF8A5525),
                  ),
                  title: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 13.8,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF574332),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFB88D65),
                  ),
                  onTap: () {
                    if (item.route != null && item.route!.isNotEmpty) {
                      Navigator.pushNamed(context, item.route!);
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.label} akan dibuat bertahap.'),
                      ),
                    );
                  },
                ),
                if (index != items.length - 1)
                  const Divider(height: 1, color: Color(0xFFF0E1CF)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class HomeMenuDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const HomeMenuDrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFF2E2) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: active
                    ? const Color(0xFF8F4E1E)
                    : const Color(0xFFFFE8CC),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: active
                      ? const Color(0xFF8B4F1F)
                      : const Color(0xFFFFE8CC),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeProfileHeaderCard extends StatelessWidget {
  final Widget avatar;
  final bool canEditPhoto;
  final VoidCallback? onEditPhoto;
  final String userName;
  final String email;
  final String roleLabel;

  const HomeProfileHeaderCard({
    super.key,
    required this.avatar,
    required this.userName,
    required this.email,
    required this.roleLabel,
    this.canEditPhoto = true,
    this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7CCAE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE7CCAE), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(child: avatar),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: canEditPhoto ? onEditPhoto : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE2B7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color: Color(0xFF70411A),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2F2318),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A7563),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDD096),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    roleLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8E4E16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
