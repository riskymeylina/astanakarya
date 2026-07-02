import 'package:flutter/material.dart';

class HomeCategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const HomeCategoryItem({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent, Color.lerp(accent, Colors.black, 0.08)!],
                )
              : null,
          color: selected ? null : const Color(0xFFFFF4E5),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFE0C59D),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? accent.withValues(alpha: 0.28)
                  : const Color(0x14000000),
              blurRadius: selected ? 16 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? Colors.white.withValues(alpha: 0.22)
                    : Colors.white,
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : accent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : const Color(0xFF3A2B1F),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.4,
                height: 1.15,
                color: selected
                    ? const Color(0xFFF9E3C0)
                    : const Color(0xFF81624A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
