import 'package:flutter/material.dart';

class ProfileSectionData {
  final String title;
  final List<ProfileSettingTileData> items;

  const ProfileSectionData({
    required this.title,
    required this.items,
  });
}

class ProfileSettingTileData {
  final String label;
  final String? subtitle;
  final IconData icon;
  final String? route;
  final VoidCallback? onTap;

  const ProfileSettingTileData({
    required this.label,
    required this.icon,
    this.subtitle,
    this.route,
    this.onTap,
  });
}

class ProfileSettingTile extends StatelessWidget {
  final ProfileSettingTileData item;

  const ProfileSettingTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 24,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE9C9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(item.icon, size: 18, color: const Color(0xFF8E4E16)),
      ),
      title: Text(
        item.label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF3A2B1F),
        ),
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF8A7563),
                height: 1.35,
              ),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFB88D65),
      ),
      onTap: item.onTap ?? () {
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
    );
  }
}
