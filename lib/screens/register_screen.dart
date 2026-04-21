// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/services/auth_service.dart';
import './login screen/terms_screen.dart';
import './login screen/privacy_policy_screen.dart';
import '/core/utils/themes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  GetStorage box = GetStorage();

  Future<void> _register() async {
    if (_fullNameController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Full Name is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_usernameController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Username is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Email or Phone Number is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Password is required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      Get.snackbar(
        "Error",
        "Passwords do not match",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (!_acceptedTerms) {
      Get.snackbar(
        "Error",
        "Please accept Terms & Conditions and Privacy Policy",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      _fullNameController.text.trim(),
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _confirmPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      Get.snackbar(
        "Success",
        "Account created! Please verify your email.",
        snackPosition: SnackPosition.BOTTOM,
      );
      Navigator.pop(context);
    } else {
      Get.snackbar(
        "Error",
        result['message'] ?? "Registration failed",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool showEye = false,
    bool isConfirm = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: AppDecorations.inputField,
      child: TextField(
        controller: controller,
        obscureText: showEye
            ? (isConfirm ? _obscureConfirmPassword : _obscurePassword)
            : false,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.hint,
          prefixIcon: Icon(icon, color: AppColors.iconMuted, size: 19),
          suffixIcon: showEye
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isConfirm) {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      } else {
                        _obscurePassword = !_obscurePassword;
                      }
                    });
                  },
                  child: Icon(
                    (isConfirm ? _obscureConfirmPassword : _obscurePassword)
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.iconMuted,
                    size: 19,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Wrap(
              children: [
                Text(
                  'I accept the ',
                  style: TextStyle(
                    color: AppColors.darkGreen.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(
                    () => TermsScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                  ),
                  child: Text(
                    'Terms & Conditions',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 13,
                      height: 1.6,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.darkGreen,
                    ),
                  ),
                ),
                Text(
                  ' and ',
                  style: TextStyle(
                    color: AppColors.darkGreen.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(
                    () => PrivacyPolicyScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                  ),
                  child: Text(
                    'Privacy Policy',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 13,
                      height: 1.6,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.darkGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Language toggle button ──────────────────
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton.icon(
                    onPressed: () {
                      // TODO: implement language switching
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.overlayLight,
                      foregroundColor: AppColors.darkGreen,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: AppColors.borderGold.withOpacity(0.50),
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.language,
                      size: 15,
                      color: AppColors.darkGreen,
                    ),
                    label: Text(
                      'اردو',
                      style: AppTextStyles.label.copyWith(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                const Text('Create Account', style: AppTextStyles.heading1),
                const SizedBox(height: 6),
                Text('Join Rice Mart today', style: AppTextStyles.labelMuted),
                const SizedBox(height: 28),

                _buildInputField(
                  controller: _fullNameController,
                  hint: 'Full Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 10),

                _buildInputField(
                  controller: _usernameController,
                  hint: 'Username',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 10),

                _buildInputField(
                  controller: _emailController,
                  hint: 'Email or Phone Number',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),

                _buildInputField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  showEye: true,
                ),
                const SizedBox(height: 10),

                _buildInputField(
                  controller: _confirmPasswordController,
                  hint: 'Confirm Password',
                  icon: Icons.lock_outline,
                  showEye: true,
                  isConfirm: true,
                ),
                const SizedBox(height: 14),

                _buildTermsRow(),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: AppButtonStyles.primary,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: AppColors.darkGreen,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text('Sign Up', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.label.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}