import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'utils/auth_feedback.dart';
import 'widgets/auth_field_label.dart';
import 'widgets/auth_footer_link.dart';
import 'widgets/auth_page_scaffold.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/login_social_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isNavigating = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    debugPrint('[AUTH_DEBUG] Tombol login ditekan');
    if (mounted) {
      showAuthSnackBar(context, 'Tombol login ditekan! Memvalidasi...');
    }
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      debugPrint('[AUTH_DEBUG] Validasi lokal gagal: email atau password kosong');
      showAuthSnackBar(
        context,
        'Email dan Password wajib diisi',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint('[AUTH_DEBUG] Mengirim request login ke AuthService');
      final response = await _authService.loginUser(
        _emailController.text.trim(),
        _passController.text,
      );
      debugPrint('[AUTH_DEBUG] Response login diterima: Status Code ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final userName = data['user']?['name'] ?? 'Pengguna';
        debugPrint('[AUTH_DEBUG] Login sukses untuk user: $userName');

        if (!mounted) {
          debugPrint('[AUTH_DEBUG] login_screen tidak mounted setelah login');
          return;
        }
        showAuthSnackBar(context, 'Selamat Datang, $userName!');
        _isNavigating = true;
        debugPrint('[AUTH_DEBUG] Navigasi ke /home');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        debugPrint('[AUTH_DEBUG] Login gagal dengan pesan: ${data['message']}');
        if (!mounted) return;
        showAuthSnackBar(
          context,
          data['message'] ?? 'Email atau Password salah',
          isError: true,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[AUTH_DEBUG] Catch error saat login: $e\n$stackTrace');
      if (!mounted) return;
      showAuthSnackBar(
        context,
        'Koneksi gagal. Pastikan backend Express berjalan',
        isError: true,
      );
    } finally {
      if (mounted && !_isNavigating) {
        setState(() => _isLoading = false);
        debugPrint('[AUTH_DEBUG] State loading di-reset ke false');
      }
    }
  }

  void _showSocialLoginUnavailable(String provider) {
    showAuthSnackBar(
      context,
      'Login $provider belum tersedia saat ini.',
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      headerImagePath: 'assets/images/3.jpg',
      title: 'Masuk ke Akun Penjualan Properti',
      subtitle:
          'Selamat datang kembali! Kelola penjualan properti Anda dengan mudah.',
      footer: AuthFooterLink(
        prefixText: 'Belum punya akun? ',
        actionText: 'Daftar sekarang',
        onTap: () => Navigator.pushNamed(context, '/register'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthFieldLabel(text: 'Alamat Email', isRequired: true),
          const SizedBox(height: 10),
          AuthTextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            borderRadius: 30,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
          ),
          const SizedBox(height: 20),
          const AuthFieldLabel(text: 'Kata Sandi', isRequired: true),
          const SizedBox(height: 10),
          AuthTextField(
            controller: _passController,
            isPassword: true,
            isPasswordVisible: _isPasswordVisible,
            onTogglePasswordVisibility: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
            borderRadius: 30,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot'),
              child: const Text(
                'Lupa Kata Sandi?',
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AuthPrimaryButton(
            label: 'Masuk',
            onPressed: _login,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              LoginSocialButton(
                assetPath: 'assets/images/google.png',
                label: 'Google',
                onTap: () => _showSocialLoginUnavailable('Google'),
              ),
              const SizedBox(width: 12),
              LoginSocialButton(
                assetPath: 'assets/images/facebook.png',
                label: 'Facebook',
                onTap: () => _showSocialLoginUnavailable('Facebook'),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}
