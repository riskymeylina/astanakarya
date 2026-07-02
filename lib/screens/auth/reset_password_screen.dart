import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'utils/auth_feedback.dart';
import 'widgets/auth_field_label.dart';
import 'widgets/auth_footer_link.dart';
import 'widgets/auth_page_scaffold.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final AuthService _authService = AuthService();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Map<String, String> _resolveArgs() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      return {
        'email': (args['email'] ?? '').toString(),
        'resetToken': (args['resetToken'] ?? '').toString(),
      };
    }

    return {'email': '', 'resetToken': ''};
  }

  Future<void> _submitResetPassword() async {
    final args = _resolveArgs();
    final email = args['email']!.trim();
    final resetToken = args['resetToken']!.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;

    if (email.isEmpty || resetToken.isEmpty) {
      showAuthSnackBar(
        context,
        'Sesi reset password tidak valid',
        isError: true,
      );
      return;
    }

    if (password.length < 8) {
      showAuthSnackBar(
        context,
        'Kata sandi baru minimal 8 karakter',
        isError: true,
      );
      return;
    }

    if (password != confirmPassword) {
      showAuthSnackBar(
        context,
        'Konfirmasi kata sandi tidak sama',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.resetPassword(
        email,
        resetToken,
        password,
      );
      final data = jsonDecode(response.body);
      final message = (data['message'] ?? 'Reset password gagal').toString();

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        showAuthSnackBar(context, message);
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        showAuthSnackBar(context, message, isError: true);
      }
    } catch (_) {
      if (!mounted) return;
      showAuthSnackBar(
        context,
        'Tidak dapat terhubung ke backend',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      headerImagePath: 'assets/images/2.jpg',
      title: 'Masukkan Kata Sandi Baru',
      subtitle:
          'Kata sandi baru harus berbeda dari kata sandi yang pernah digunakan sebelumnya.',
      showBackButton: true,
      overlayButtonColor: Colors.black.withValues(alpha: 0.3),
      panelRadius: 30,
      topImageFraction: 0.4,
      panelTopFraction: 0.38,
      footer: AuthFooterLink(
        prefixText: 'Kembali ke ',
        actionText: 'Masuk',
        onTap: () => Navigator.popUntil(context, ModalRoute.withName('/login')),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthFieldLabel(
            text: 'Kata Sandi',
            isRequired: true,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          const SizedBox(height: 8),
          AuthTextField(
            controller: _passwordController,
            isPassword: true,
            isPasswordVisible: _isPasswordVisible,
            onTogglePasswordVisibility: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
            borderRadius: 12,
            filledColor: Colors.grey.shade100,
          ),
          const SizedBox(height: 16),
          const AuthFieldLabel(
            text: 'Konfirmasi Kata Sandi',
            isRequired: true,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          const SizedBox(height: 8),
          AuthTextField(
            controller: _confirmController,
            isPassword: true,
            isPasswordVisible: _isConfirmPasswordVisible,
            onTogglePasswordVisibility: () {
              setState(
                () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
              );
            },
            borderRadius: 12,
            filledColor: Colors.grey.shade100,
          ),
          const SizedBox(height: 32),
          AuthPrimaryButton(
            label: 'Lanjutkan',
            onPressed: _submitResetPassword,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
