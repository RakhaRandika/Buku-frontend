import 'package:flutter/material.dart';

import '../main.dart';
import '../service/api_service.dart';
import '../service/auth_service.dart';
import '../widgets/auth_field.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (nama.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Semua kolom wajib diisi');
      return;
    }
    if (password.length < 6) {
      _showError('Kata sandi minimal 6 karakter');
      return;
    }
    if (password != _konfirmasiController.text) {
      _showError('Konfirmasi kata sandi tidak sama');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.register(nama, email, password);
      if (!mounted) return;
      // Hapus layar login & daftar dari tumpukan supaya back tidak kembali ke sana
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.red),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    // Landscape: panel judul di kiri, form di kanan supaya tidak sempit
    if (isLandscape) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 12, 24, 24),
                    child: _buildHeader(),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(24),
                    ),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                      child: _buildForm(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.navy,
              padding: const EdgeInsets.fromLTRB(12, 12, 24, 56),
              child: _buildHeader(),
            ),

            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(child: _buildForm()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(
                      text: 'Buat ',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'akun',
                      style: TextStyle(
                        color: Color(0xFFFDBA74),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: '\nbaru.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Simpan buku favorit bacamu sendiri',
                style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    final toggleIcon = IconButton(
      icon: Icon(
        _hidePassword
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        color: Colors.grey,
        size: 20,
      ),
      onPressed: () => setState(() => _hidePassword = !_hidePassword),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthField(
          label: 'NAMA',
          hint: 'Nama lengkap',
          controller: _namaController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        AuthField(
          label: 'EMAIL',
          hint: 'nama@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        AuthField(
          label: 'KATA SANDI',
          hint: 'Minimal 6 karakter',
          controller: _passwordController,
          obscureText: _hidePassword,
          textInputAction: TextInputAction.next,
          suffixIcon: toggleIcon,
        ),
        const SizedBox(height: 16),
        AuthField(
          label: 'ULANGI KATA SANDI',
          hint: '••••••••',
          controller: _konfirmasiController,
          obscureText: _hidePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _loading ? null : _register(),
        ),
        const SizedBox(height: 28),

        ElevatedButton(
          onPressed: _loading ? null : _register,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.navy.withValues(alpha: 0.6),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Daftar',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
        ),
        const SizedBox(height: 16),
        // Wrap supaya pindah baris kalau lebarnya tidak cukup
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Sudah punya akun?',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            TextButton(
              onPressed: _loading ? null : () => Navigator.of(context).pop(),
              child: const Text(
                'Masuk',
                style: TextStyle(
                  color: AppColors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
