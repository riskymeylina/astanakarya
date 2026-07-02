import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'utils/auth_feedback.dart';
import 'widgets/auth_footer_link.dart';
import 'widgets/auth_otp_input.dart';
import 'widgets/auth_page_scaffold.dart';
import 'widgets/auth_primary_button.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final AuthService _authService = AuthService();
  final List<TextEditingController> _digitControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _digitFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (final controller in _digitControllers) {
      controller.dispose();
    }
    for (final focusNode in _digitFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String _codeValue() {
    return _digitControllers.map((controller) => controller.text).join();
  }

  void _onDigitChanged(String value, int index) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < _digitControllers.length; i++) {
        _digitControllers[i].text = i < digits.length ? digits[i] : '';
      }
      final targetIndex = digits.length >= _digitControllers.length
          ? _digitControllers.length - 1
          : digits.length;
      _digitFocusNodes[targetIndex].requestFocus();
      return;
    }

    if (value.isNotEmpty && index < _digitFocusNodes.length - 1) {
      _digitFocusNodes[index + 1].requestFocus();
    }
  }

  String _resolveEmail() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['email'] is String) {
      return (args['email'] as String).trim();
    }
    return '';
  }

  Future<void> _verifyCode() async {
    final email = _resolveEmail();
    final code = _codeValue().trim();

    if (email.isEmpty) {
      showAuthSnackBar(
        context,
        'Email reset password tidak ditemukan',
        isError: true,
      );
      return;
    }

    if (code.length != 6) {
      showAuthSnackBar(context, 'Kode verifikasi harus 6 digit', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.verifyResetCode(email, code);
      final data = jsonDecode(response.body);
      final message = (data['message'] ?? 'Verifikasi gagal').toString();

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Navigator.pushReplacementNamed(
          context,
          '/reset-password',
          arguments: {
            'email': email,
            'resetToken': (data['resetToken'] ?? '').toString(),
          },
        );
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

  Future<void> _resendCode() async {
    final email = _resolveEmail();
    if (email.isEmpty) {
      showAuthSnackBar(
        context,
        'Email reset password tidak ditemukan',
        isError: true,
      );
      return;
    }

    setState(() => _isResending = true);

    try {
      final response = await _authService.forgotPassword(email);
      final data = jsonDecode(response.body);
      if (!mounted) return;
      showAuthSnackBar(
        context,
        (data['message'] ?? 'Kode verifikasi telah dikirim ulang').toString(),
      );
    } catch (_) {
      if (!mounted) return;
      showAuthSnackBar(
        context,
        'Tidak dapat terhubung ke backend',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _resolveEmail();

    return AuthPageScaffold(
      headerImagePath: 'assets/images/2.jpg',
      title: 'Masukkan Kode',
      subtitle: email.isEmpty
          ? 'Masukkan kode verifikasi yang dikirim ke email Anda'
          : 'Kode verifikasi telah dikirim ke $email',
      showBackButton: true,
      overlayButtonColor: Colors.black.withValues(alpha: 0.3),
      panelRadius: 25,
      topImageFraction: 0.44,
      panelTopFraction: 0.38,
      titleAlignment: CrossAxisAlignment.center,
      titleTextAlign: TextAlign.center,
      footer: AuthFooterLink(
        prefixText: 'Kembali ke ',
        actionText: 'Masuk',
        onTap: () => Navigator.popUntil(context, ModalRoute.withName('/login')),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: AuthOtpInput(
              controllers: _digitControllers,
              focusNodes: _digitFocusNodes,
              onChanged: _onDigitChanged,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isResending ? null : _resendCode,
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: Text(
              _isResending
                  ? 'Mengirim ulang...'
                  : 'Belum menerima kode? Kirim ulang',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          AuthPrimaryButton(
            label: 'Verifikasi dan Lanjutkan',
            onPressed: _verifyCode,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
