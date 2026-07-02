import 'package:flutter/material.dart';

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel({
    super.key,
    required this.text,
    this.isRequired = false,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.color = Colors.black87,
  });

  final String text;
  final bool isRequired;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
          fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
        ),
        children: [
          TextSpan(text: text),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
