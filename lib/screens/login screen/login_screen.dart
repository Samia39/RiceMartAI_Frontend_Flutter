// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/themes.dart';
import '../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure   = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final username = _usernameCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _snack('Please fill in all fields.');
      return;
    }

    setState(() => _isLoading = true);
    final error = await AuthService.login(
      username: username,
      email:    email,
      password: password,
    );
    if (mounted) setState(() => _isLoading = false);

    if (error == null) {
      if (AuthService.isAdmin()) {
        Get.offNamed('/admin-dashboard');
      } else if (AuthService.getRole() == 'seller') {
        Get.offNamed('/seller-dashboard');
      } else {
        Get.offNamed('/user-dashboard');
      }
    } else {
      _snack(error);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 12, right: 16,
                child: Container(
                  decoration: AppDecorations.pill,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language,
                          size: 16, color: AppColors.darkGreen),
                      const SizedBox(width: 6),
                      Text('اردو', style: AppTextStyles.label),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 80),
                    Text('Welcome Back',
                        style: AppTextStyles.heading1.copyWith(fontSize: 28),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    Text('Sign in to continue',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 36),
                    _inputField(
                      ctrl: _usernameCtrl,
                      hint: 'Username',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),
                    _inputField(
                      ctrl: _emailCtrl,
                      hint: 'Email or Phone Number',
                      icon: Icons.mail_outline,
                      keyboard: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    _passwordField(
                      ctrl: _passwordCtrl,
                      hint: 'Password',
                      obscure: _obscure,
                      onToggle: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: AppButtonStyles.ghost,
                        onPressed: () => Get.toNamed('/forgot-password'),
                        child: Text('Forgot Password?',
                            style: AppTextStyles.label.copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.darkGreen,
                            )),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: AppButtonStyles.primary,
                      onPressed: _isLoading ? null : _handleSignIn,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.darkGreen))
                          : Text('Sign In', style: AppTextStyles.button),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: AppTextStyles.bodyMedium),
                        TextButton(
                          style: AppButtonStyles.ghost,
                          onPressed: () => Get.toNamed('/register'),
                          child: Text('Sign Up',
                              style: AppTextStyles.label.copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.darkGreen,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      decoration: AppDecorations.inputField,
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.hint,
          prefixIcon: Icon(icon, color: AppColors.iconMuted, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController ctrl,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: AppDecorations.inputField,
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.hint,
          prefixIcon: Icon(Icons.lock_outline,
              color: AppColors.iconMuted, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.iconMuted, size: 20,
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}