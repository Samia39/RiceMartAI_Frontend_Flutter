// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/themes.dart';
import '../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameCtrl    = TextEditingController();
  final _usernameCtrl    = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final fullName = _fullNameCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm  = _confirmPassCtrl.text;

    if (fullName.isEmpty || username.isEmpty ||
        email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _snack('Please fill in all fields.');
      return;
    }
    if (password != confirm) {
      _snack('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);
    final error = await AuthService.register(
      fullName:        fullName,
      username:        username,
      email:           email,
      password:        password,
      confirmPassword: confirm,
    );
    if (mounted) setState(() => _isLoading = false);

    if (error == null) {
      _snack('Account created! Please sign in.');
      Get.offNamed('/login');
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Text('Create Account',
                    style: AppTextStyles.heading1.copyWith(fontSize: 28),
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text('Join Rice Mart today',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 36),
                _inputField(
                    ctrl: _fullNameCtrl,
                    hint: 'Full Name',
                    icon: Icons.person_outline),
                const SizedBox(height: 14),
                _inputField(
                    ctrl: _usernameCtrl,
                    hint: 'Username',
                    icon: Icons.person_outline),
                const SizedBox(height: 14),
                _inputField(
                    ctrl: _emailCtrl,
                    hint: 'Email or Phone Number',
                    icon: Icons.mail_outline,
                    keyboard: TextInputType.emailAddress),
                const SizedBox(height: 14),
                _passwordField(
                    ctrl: _passwordCtrl,
                    hint: 'Password',
                    obscure: _obscurePass,
                    onToggle: () =>
                        setState(() => _obscurePass = !_obscurePass)),
                const SizedBox(height: 14),
                _passwordField(
                    ctrl: _confirmPassCtrl,
                    hint: 'Confirm Password',
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm)),
                const SizedBox(height: 28),
                ElevatedButton(
                  style: AppButtonStyles.primary,
                  onPressed: _isLoading ? null : _handleSignUp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.darkGreen))
                      : Text('Sign Up', style: AppTextStyles.button),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style: AppTextStyles.bodyMedium),
                    TextButton(
                      style: AppButtonStyles.ghost,
                      onPressed: () => Get.offNamed('/login'),
                      child: Text('Sign In',
                          style: AppTextStyles.label.copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.darkGreen,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
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