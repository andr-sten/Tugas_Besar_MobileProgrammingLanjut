// lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:q_campus_antrian_mahasiswa/services/api_service.dart';
import 'package:q_campus_antrian_mahasiswa/utils/constants.dart';
import 'package:q_campus_antrian_mahasiswa/widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final String _selectedRole = 'mahasiswa';
  String _selectedProdi = 'ti';
  bool _isLoading = false;

  final Map<String, String> _prodiOptions = {
    'ti': 'Informatika',
    'si': 'Sistem Informasi',
    'dkv': 'DKV',
    'akuntansi': 'Akuntansi',
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.register(
        name: _nameCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
        passwordConfirmation: _confirmCtrl.text,
        role: _selectedRole,
        prodi: _prodiOptions[_selectedProdi],
      );

      if (!mounted) return;

      if (result.status) {
        _showSnackBar(result.message);
        Navigator.pushReplacementNamed(context, '/mahasiswa/home');
      } else {
        _showSnackBar(result.message, isError: true);
      }
    } on ApiException catch (e) {
      if (mounted) _showSnackBar(e.message, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? AppConstants.errorColor : AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          // ── Decorative Background ───────────────────────────────
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFC9E8BF).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Mulai Perjalanan Digital Anda.',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.onSurfaceColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gabung dalam ekosistem antrian cerdas yang transparan dan efisien.',
                      style: TextStyle(
                          fontSize: 14, color: AppConstants.secondaryColor),
                    ),
                    const SizedBox(height: 32),

                    // ── Registration Card ───────────────────────────
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                            color: const Color(0xFFE8EEE7).withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.08),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Registrasi Mahasiswa',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          _buildInputLabel('Nama Lengkap'),
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan nama lengkap',
                              prefixIcon:
                                  Icon(Icons.person_outline_rounded, size: 20),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Nama tidak boleh kosong'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _buildInputLabel('Username'),
                          TextFormField(
                            controller: _usernameCtrl,
                            decoration: const InputDecoration(
                              hintText: 'username_kamu',
                              prefixIcon:
                                  Icon(Icons.alternate_email_rounded, size: 20),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Username tidak boleh kosong'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _buildInputLabel('Program Studi'),
                          DropdownButtonFormField<String>(
                            value: _selectedProdi,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.school_outlined, size: 20),
                            ),
                            items: _prodiOptions.entries
                                .map((e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value,
                                          style: const TextStyle(fontSize: 14)),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedProdi = v ?? 'ti'),
                          ),
                          const SizedBox(height: 20),
                          _buildInputLabel('Password'),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: '••••••••',
                              prefixIcon:
                                  Icon(Icons.lock_outline_rounded, size: 20),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Password tidak boleh kosong';
                              if (v.length < 6) return 'Minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildInputLabel('Konfirmasi Password'),
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Ulangi password',
                              prefixIcon:
                                  Icon(Icons.lock_reset_rounded, size: 20),
                            ),
                            validator: (v) {
                              if (v != _passwordCtrl.text)
                                return 'Password tidak cocok';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          CustomButton(
                            label: 'Daftar Sekarang',
                            onPressed: _handleRegister,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text.rich(
                          TextSpan(
                            text: 'Sudah punya akun? ',
                            style: TextStyle(color: Colors.grey[600]),
                            children: const [
                              TextSpan(
                                text: 'Masuk di sini',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppConstants.onSurfaceVariant),
      ),
    );
  }
}
