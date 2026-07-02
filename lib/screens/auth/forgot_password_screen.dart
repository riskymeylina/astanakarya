import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'utils/auth_feedback.dart';
import 'widgets/auth_field_label.dart';
import 'widgets/auth_footer_link.dart';
import 'widgets/auth_page_scaffold.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showAuthSnackBar(context, 'Email wajib diisi', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.forgotPassword(email);
      final data = jsonDecode(response.body);
      final message = (data['message'] ?? 'Permintaan reset password diproses')
          .toString();

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        showAuthSnackBar(context, message);
        Navigator.pushNamed(context, '/verify', arguments: {'email': email});
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
      title: 'Lupa Kata Sandi',
      subtitle:
          'Masukkan email yang terdaftar pada akun penjualan properti Anda, lalu kami akan kirim email untuk atur ulang kata sandi.',
      showBackButton: true,
      overlayButtonColor: Colors.black.withValues(alpha: 0.3),
      panelRadius: 25,
      topImageFraction: 0.46,
      panelTopFraction: 0.42,
      footer: AuthFooterLink(
        prefixText: 'Kembali ke ',
        actionText: 'Masuk',
        onTap: () => Navigator.pop(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthFieldLabel(text: 'Alamat Email', isRequired: true),
          const SizedBox(height: 8),
          AuthTextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            borderRadius: 16,
          ),
          const SizedBox(height: 25),
          AuthPrimaryButton(
            label: 'Kirim Email',
            onPressed: _submitForgotPassword,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
