// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../register_screen.dart';
import '../login screen/forgot_password.dart';
import '../login screen/terms_screen.dart';
import '../login screen/privacy_policy_screen.dart';
import '../../core/services/auth_service.dart';
import '/core/utils/themes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  GetStorage box = GetStorage();

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar("Error", "Email and Password are required");
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.login(
      _emailController.text,
      _passwordController.text,
    );
    if (!_acceptedTerms) {
      Get.snackbar(
        "Error",
        "Please accept the Terms & Conditions and Privacy Policy",
      );
      return;
    }
    setState(() => _isLoading = false);

    if (result['success']) {
      final userName = result['data']['user']['name'];
      print(result['data']['token']);
      box.write('isLoggedIn', true);
      box.write('userName', userName);
      box.write('token', result['data']['token']);
      Get.offAllNamed('/dashboard', arguments: {'userName': userName});
    } else {
      Get.snackbar("Error", result['message']);
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool showEye = false,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: AppDecorations.inputField,
      child: TextField(
        controller: controller,
        obscureText: obscure && _obscurePassword,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.hint,
          prefixIcon: Icon(icon, color: AppColors.iconMuted, size: 19),
          suffixIcon: showEye
              ? GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
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
                const SizedBox(height: 32),

                const Text('Welcome Back', style: AppTextStyles.heading1),
                const SizedBox(height: 6),
                Text('Sign in to continue', style: AppTextStyles.labelMuted),
                const SizedBox(height: 30),

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
                  obscure: true,
                ),
                const SizedBox(height: 14),

                // Terms and conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _acceptedTerms,
                        onChanged: (v) =>
                            setState(() => _acceptedTerms = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: AppColors.darkGreen.withOpacity(0.85),
                              fontSize: 13,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(text: 'I accept the '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TermsScreen(),
                                    ),
                                  ),
                                  child: Text(
                                    'Terms & Conditions',
                                    style: AppTextStyles.label.copyWith(
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.darkGreen,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' and\n'),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PrivacyPolicyScreen(),
                                    ),
                                  ),
                                  child: Text(
                                    'Privacy Policy',
                                    style: AppTextStyles.label.copyWith(
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.darkGreen,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.darkGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
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
                        : const Text('Sign In', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      ),
                      child: Text(
                        'Sign Up',
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
