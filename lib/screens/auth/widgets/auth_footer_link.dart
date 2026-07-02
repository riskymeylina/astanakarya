import 'package:flutter/material.dart';

const Color _kBrown = Color(0xFF8B3E0F);

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prefixText,
    required this.actionText,
    required this.onTap,
    this.center = true,
  });

  final String prefixText;
  final String actionText;
  final VoidCallback onTap;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final fontFamily =
        Theme.of(context).textTheme.bodyMedium?.fontFamily;

    final link = RichText(
      textAlign: center ? TextAlign.center : TextAlign.start,
      text: TextSpan(
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
        ),
        children: [
          TextSpan(
            text: prefixText,
            style: const TextStyle(color: Color(0xFF666666)),
          ),
          TextSpan(
            text: actionText,
            style: const TextStyle(
              color: _kBrown,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    final button = TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: _kBrown.withOpacity(0.08),
      ),
      child: link,
    );

    return center ? Center(child: button) : button;
  }
}
