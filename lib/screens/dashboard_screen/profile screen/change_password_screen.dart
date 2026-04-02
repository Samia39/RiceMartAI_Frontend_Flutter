// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // ── Colours (same as SplashScreen) ────────────────────────────
  static const Color _darkGreen = Color(0xFF1A2820);
  static const Color _lightGreen = Color(0xFF5A8A6E);
  static const Color _golden = Color(0xFF9D7E3F);

  // ── Controllers ───────────────────────────────────────────────
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _loading = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _loading = false);
    Get.back();
    Get.snackbar(
      'Password Changed',
      'Your password has been updated successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white.withOpacity(0.90),
      colorText: _darkGreen,
      icon: const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32)),
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  // ── Input field builder ────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: _darkGreen.withOpacity(0.85),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: TextStyle(
            fontSize: 14,
            color: _darkGreen,
            fontFamily: 'Poppins',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13.5,
              color: _darkGreen.withOpacity(0.40),
              fontFamily: 'Poppins',
            ),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              size: 18,
              color: _darkGreen.withOpacity(0.55),
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 19,
                color: _darkGreen.withOpacity(0.55),
              ),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.30),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.45),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.45),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _darkGreen.withOpacity(0.55),
                width: 1.6,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.6),
            ),
            errorStyle: TextStyle(
              color: Colors.red.shade800,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 5),
          Text(
            helperText,
            style: TextStyle(
              fontSize: 11.5,
              color: _darkGreen.withOpacity(0.65),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Same gradient as SplashScreen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_lightGreen, _golden],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back row ──────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 18, 0),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.arrow_back, size: 18, color: _darkGreen),
                      label: Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _darkGreen,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Screen title ──────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 22,
                      color: _darkGreen,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _darkGreen,
                        fontFamily: 'Poppins',
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Form card ─────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.40),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _darkGreen.withOpacity(0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Password
                        _buildField(
                          controller: _currentCtrl,
                          label: 'Current Password',
                          hint: 'Enter current password',
                          obscure: !_showCurrent,
                          onToggle: () =>
                              setState(() => _showCurrent = !_showCurrent),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your current password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // New Password
                        _buildField(
                          controller: _newCtrl,
                          label: 'New Password',
                          hint: 'Enter new password',
                          obscure: !_showNew,
                          onToggle: () => setState(() => _showNew = !_showNew),
                          helperText:
                              'Password must be at least 8 characters long',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter a new password';
                            }
                            if (v.trim().length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            if (v.trim() == _currentCtrl.text.trim()) {
                              return 'New password must differ from current';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Confirm New Password
                        _buildField(
                          controller: _confirmCtrl,
                          label: 'Confirm New Password',
                          hint: 'Confirm new password',
                          obscure: !_showConfirm,
                          onToggle: () =>
                              setState(() => _showConfirm = !_showConfirm),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please confirm your new password';
                            }
                            if (v.trim() != _newCtrl.text.trim()) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 26),

                        // ── Buttons row ────────────────────
                        Row(
                          children: [
                            // Cancel
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _loading ? null : () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _darkGreen,
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.55),
                                    width: 1.2,
                                  ),
                                  backgroundColor: Colors.white.withOpacity(
                                    0.18,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _darkGreen,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Change Password
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _loading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _darkGreen.withOpacity(0.80),
                                  disabledBackgroundColor: _darkGreen
                                      .withOpacity(0.30),
                                  foregroundColor: const Color(0xFFD4C9A8),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                child: _loading
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: const Color(
                                                0xFFD4C9A8,
                                              ).withOpacity(0.8),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Saving...',
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.save_outlined,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 7),
                                          const Text(
                                            'Change Password',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
