import 'package:flutter/material.dart';

void showAuthSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
}) {
  try {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  } catch (e) {
    debugPrint('[AUTH_DEBUG] Error showing SnackBar: $e');
  }
}
