import 'package:flutter/material.dart';
import '../../../features/shared/profile/profile_section_title.dart';
import '../../../features/shared/profile/profile_setting_tile.dart';

class StaffProfileMenu extends StatelessWidget {
  // Menggunakan tipe data bawaan dari shared component profile_setting_tile.dart
  final ProfileSectionData section;

  const StaffProfileMenu({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7CCAE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSectionTitle(title: section.title),
          const SizedBox(height: 6),
          ...section.items.map(
            (item) => Column(
              children: [
                ProfileSettingTile(item: item),
                if (item != section.items.last)
                  const Divider(
                    height: 1,
                    color: Color(0xFFF0E1CF),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}