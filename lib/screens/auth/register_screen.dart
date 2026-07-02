import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'utils/auth_feedback.dart';
import 'widgets/auth_field_label.dart';
import 'widgets/auth_footer_link.dart';
import 'widgets/auth_page_scaffold.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isNavigating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    debugPrint('[AUTH_DEBUG] Tombol register ditekan');
    if (mounted) {
      showAuthSnackBar(context, 'Tombol register ditekan! Memvalidasi...');
    }
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passController.text.isEmpty) {
      debugPrint('[AUTH_DEBUG] Validasi lokal gagal: ada field kosong');
      showAuthSnackBar(context, 'Semua field wajib diisi', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint('[AUTH_DEBUG] Mengirim request register ke AuthService');
      final response = await _authService.registerUser(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passController.text,
      );
      debugPrint('[AUTH_DEBUG] Response register diterima: Status Code ${response.statusCode}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[AUTH_DEBUG] Registrasi sukses');
        if (!mounted) {
          debugPrint('[AUTH_DEBUG] register_screen tidak mounted setelah register');
          return;
        }
        showAuthSnackBar(context, 'Registrasi Berhasil! Selamat datang');
        _isNavigating = true;
        debugPrint('[AUTH_DEBUG] Navigasi ke /home');
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }

      var errorMessage = 'Gagal Registrasi';

      if (data['message'] != null) {
        errorMessage = data['message'];
      }

      if (data['errors'] is Map) {
        final errors = data['errors'] as Map<String, dynamic>;
        errorMessage = errors.values.first[0];
      }

      debugPrint('[AUTH_DEBUG] Registrasi gagal dengan pesan: $errorMessage');

      if (!mounted) return;
      showAuthSnackBar(
        context,
        errorMessage,
        isError: true,
        duration: const Duration(seconds: 4),
      );
    } catch (e, stackTrace) {
      debugPrint('[AUTH_DEBUG] Catch error saat register: $e\n$stackTrace');
      if (!mounted) return;
      showAuthSnackBar(
        context,
        'Tidak dapat terhubung ke backend. Periksa koneksi atau URL API',
        isError: true,
        duration: const Duration(seconds: 4),
      );
    } finally {
      if (mounted && !_isNavigating) {
        setState(() => _isLoading = false);
        debugPrint('[AUTH_DEBUG] State loading di-reset ke false');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      headerImagePath: 'assets/images/1.jpg',
      title: 'Buat Akun Anda',
      subtitle:
          'Selamat datang! Isi data di bawah untuk mulai penjualan properti.',
      showBackButton: true,
      footer: AuthFooterLink(
        prefixText: 'Sudah punya akun? ',
        actionText: 'Masuk',
        onTap: () => Navigator.pushNamed(context, '/login'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthFieldLabel(text: 'Nama Lengkap', isRequired: true),
          const SizedBox(height: 10),
          AuthTextField(
            controller: _nameController,
            borderRadius: 30,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
          ),
          const SizedBox(height: 20),
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
          const AuthFieldLabel(text: 'Nomor HP', isRequired: true),
          const SizedBox(height: 10),
          AuthTextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
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
          const SizedBox(height: 40),
          AuthPrimaryButton(
            label: 'Daftar',
            onPressed: _register,
            isLoading: _isLoading,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}
