import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:makan_mana/core/controllers/auth_controller.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/auth/custom_text_field.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final obscurePasswordProvider = StateProvider<bool>((ref) => true);
final obscureConfirmPasswordProvider = StateProvider<bool>((ref) => true);

class RegisterScreen extends ConsumerStatefulWidget {
  final VoidCallback onTapLogin;
  const RegisterScreen({super.key, required this.onTapLogin});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    bool hasError = false;

    if (name.isEmpty) {
      setState(() => _nameError = 'Name cannot be empty.');
      hasError = true;
    }
    if (email.isEmpty) {
      setState(() => _emailError = 'Email cannot be empty.');
      hasError = true;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password cannot be empty.');
      hasError = true;
    }
    if (confirmPassword.isEmpty) {
      setState(
        () => _confirmPasswordError = 'Ulangi kata sandi cannot be empty.',
      );
      hasError = true;
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = 'Passwords do not match.');
      hasError = true;
    }

    if (hasError) return;

    final errorMsg = await ref
        .read(authControllerProvider.notifier)
        .registerWithEmail(name: name, email: email, password: password);

    if (errorMsg != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    final errorMsg = await ref
        .read(authControllerProvider.notifier)
        .loginWithGoogle();

    if (!mounted) return;

    if (errorMsg != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = ref.watch(authControllerProvider);
    final bool isObscurePassword = ref.watch(obscurePasswordProvider);
    final bool isObscureConfirmPassword = ref.watch(
      obscureConfirmPasswordProvider,
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 80,
                  ),
                  Positioned(
                    top: 14,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Makan',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'Mana',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Daftar Akun Baru',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _nameController,
                errorText: _nameError,
                icon: Icons.person_outline,
                label: 'NAMA LENGKAP',
                hintText: 'nama lengkap Anda',
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                errorText: _emailError,
                icon: Icons.mail_outline,
                label: 'EMAIL',
                hintText: 'alamat.email@anda.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                errorText: _passwordError,
                icon: Icons.lock_outline,
                label: 'KATA SANDI',
                hintText: 'minimal 8 karakter',
                isPassword: true,
                obscureText: isObscurePassword,
                onTogglePassword: () {
                  ref.read(obscurePasswordProvider.notifier).state =
                      !isObscurePassword;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                errorText: _confirmPasswordError,
                icon: Icons.lock_outline,
                label: 'ULANGI SANDI',
                hintText: 'ulangi kata sandi',
                isPassword: true,
                obscureText: isObscureConfirmPassword,
                onTogglePassword: () {
                  ref.read(obscureConfirmPasswordProvider.notifier).state =
                      !isObscureConfirmPassword;
                },
              ),
              const SizedBox(height: 24),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Dengan mendaftar, Anda menyetujui ',
                      style: TextStyle(color: AppColors.textHint, fontSize: 12),
                    ),
                    TextSpan(
                      text: 'Syarat & Ketentuan',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: AppColors.cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text(
                                  'Syarat & Ketentuan',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                                content: Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 400,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Selamat datang di MakanMana. Dengan mendaftar dan menggunakan aplikasi ini, Anda menyatakan telah membaca, memahami, dan menyetujui seluruh syarat dan ketentuan di bawah ini:\n',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                            height: 1.5,
                                          ),
                                        ),
                                        _buildTnCSection(
                                          '1. Akun Pengguna',
                                          'Anda bertanggung jawab penuh untuk menjaga kerahasiaan kata sandi dan keamanan akun Anda. Informasi yang Anda berikan saat pendaftaran harus akurat, terkini, dan valid.',
                                        ),
                                        _buildTnCSection(
                                          '2. Konten & Ulasan Pengguna',
                                          'Semua ulasan dan foto yang Anda unggah harus berdasarkan pengalaman asli. Dilarang keras mengunggah konten yang mengandung unsur SARA, pencemaran nama baik, atau promosi spam. Kami berhak menghapus konten yang melanggar.',
                                        ),
                                        _buildTnCSection(
                                          '3. Batasan Tanggung Jawab',
                                          'Informasi restoran (harga, menu, jam buka) dapat berubah sewaktu-waktu. MakanMana tidak bertanggung jawab atas kerugian materiil atau masalah kesehatan akibat kunjungan ke restoran yang terdaftar.',
                                        ),
                                        _buildTnCSection(
                                          '4. Hak Cipta Konten',
                                          'Dengan mengunggah foto atau ulasan, Anda memberikan hak kepada MakanMana untuk menampilkannya di platform kami. Anda menjamin bahwa Anda memiliki hak penuh atas konten tersebut.',
                                        ),
                                        _buildTnCSection(
                                          '5. Penghentian Layanan',
                                          'MakanMana berhak menangguhkan atau menghapus akun Anda secara sepihak apabila ditemukan indikasi pelanggaran berat atau aktivitas yang merugikan pengguna lain.',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Saya Mengerti',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.textHint.withValues(alpha: 0.3),
                      thickness: 1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Atau',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.textHint.withValues(alpha: 0.3),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.textHint.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: (isLoading) ? null : _handleGoogleLogin,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Daftar dengan Google',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Sudah punya akun? ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: 'Masuk',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          widget.onTapLogin();
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTnCSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
