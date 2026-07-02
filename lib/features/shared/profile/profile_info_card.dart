import 'package:flutter/material.dart';

import 'profile_avatar.dart';

class ProfileInfoCard extends StatelessWidget {
  final String? avatarUrl;
  final String initials;
  final String userName;
  final String email;
  final String roleLabel;
  final String statusLabel;
  final bool isEditable;
  final VoidCallback? onUploadSuccess;

  const ProfileInfoCard({
    super.key,
    this.avatarUrl,
    required this.initials,
    required this.userName,
    required this.email,
    required this.roleLabel,
    required this.statusLabel,
    this.isEditable = false,
    this.onUploadSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7CCAE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ProfileAvatar(
            imageUrl: avatarUrl,
            initials: initials,
            size: 78,
            isEditable: isEditable,
            onUploadSuccess: onUploadSuccess,
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
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A7563),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildBadge(roleLabel, const Color(0xFFFBE6C9)),
                    _buildBadge(statusLabel, const Color(0xFFF4F0E4)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color background) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5E412C),
        ),
      ),
    );
  }
}
