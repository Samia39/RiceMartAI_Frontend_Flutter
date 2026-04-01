import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/services/auth_service.dart';
import './login screen/terms_screen.dart';
import './login screen/privacy_policy_screen.dart';

class RegisterScreen extends StatefulWidget {
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
      decoration: BoxDecoration(
        color: Color(0xFFD4C9A8).withOpacity(0.30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFFB8A97A).withOpacity(0.55)),
      ),
      child: TextField(
        controller: controller,
        obscureText: showEye
            ? (isConfirm ? _obscureConfirmPassword : _obscurePassword)
            : false,
        keyboardType: keyboardType,
        style: TextStyle(color: Color(0xFF1A2820), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Color(0xFF1A2820).withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: Color(0xFF1A2820).withOpacity(0.75),
            size: 19,
          ),
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
                    color: Color(0xFF1A2820).withOpacity(0.75),
                    size: 19,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Color(0xFF1A2820), size: 19),
        label: Text(
          label,
          style: TextStyle(
            color: Color(0xFF1A2820),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Color(0xFFB8A97A).withOpacity(0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Color(0xFFD4C9A8).withOpacity(0.25),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }

  // ── Terms & Privacy tappable row ─────────────────────────────
  Widget _buildTermsRow() {
    const darkGreen = Color(0xFF1A2820);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkbox
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
            activeColor: Color(0xFF9D7E3F),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            side: BorderSide(color: darkGreen.withOpacity(0.7), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        SizedBox(width: 8),
        // Rich text with tappable links
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 2),
            child: Wrap(
              children: [
                Text(
                  'I accept the ',
                  style: TextStyle(
                    color: darkGreen.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                // ── Terms & Conditions link ──────────────
                GestureDetector(
                  onTap: () => Get.to(
                    () => TermsScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                  ),
                  child: Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 13,
                      height: 1.6,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: darkGreen,
                    ),
                  ),
                ),
                Text(
                  ' and ',
                  style: TextStyle(
                    color: darkGreen.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                // ── Privacy Policy link ──────────────────
                GestureDetector(
                  onTap: () => Get.to(
                    () => PrivacyPolicyScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                  ),
                  child: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 13,
                      height: 1.6,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: darkGreen,
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5A8A6E), Color(0xFF9D7E3F)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Language toggle
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Color(0xFFD4C9A8).withOpacity(0.30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(0xFFB8A97A).withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.language,
                          size: 15,
                          color: Color(0xFF1A2820),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'اردو',
                          style: TextStyle(
                            color: Color(0xFF1A2820),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 28),

                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2820),
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Join Rice Mart today',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF1A2820).withOpacity(0.75),
                  ),
                ),
                SizedBox(height: 28),

                _buildInputField(
                  controller: _fullNameController,
                  hint: 'Full Name',
                  icon: Icons.person_outline,
                ),
                SizedBox(height: 10),

                _buildInputField(
                  controller: _usernameController,
                  hint: 'Username',
                  icon: Icons.person_outline,
                ),
                SizedBox(height: 10),

                _buildInputField(
                  controller: _emailController,
                  hint: 'Email or Phone Number',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10),

                _buildInputField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  showEye: true,
                  isConfirm: false,
                ),
                SizedBox(height: 10),

                _buildInputField(
                  controller: _confirmPasswordController,
                  hint: 'Confirm Password',
                  icon: Icons.lock_outline,
                  showEye: true,
                  isConfirm: true,
                ),
                SizedBox(height: 14),

                // ── Tappable Terms & Privacy row ──────────
                _buildTermsRow(),
                SizedBox(height: 20),

                // Sign Up button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD4C9A8).withOpacity(0.35),
                      foregroundColor: Color(0xFF1A2820),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Color(0xFFB8A97A).withOpacity(0.7),
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Color(0xFF1A2820),
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A2820),
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 18),

                // OR divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Color(0xFF1A2820).withOpacity(0.35),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Color(0xFF1A2820).withOpacity(0.6),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Color(0xFF1A2820).withOpacity(0.35),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),

                _buildSocialButton(
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Continue with Google',
                  onTap: () => Get.snackbar(
                    "Google",
                    "Google sign-up coming soon",
                    snackPosition: SnackPosition.BOTTOM,
                  ),
                ),
                SizedBox(height: 10),
                _buildSocialButton(
                  icon: Icons.facebook,
                  label: 'Continue with Facebook',
                  onTap: () => Get.snackbar(
                    "Facebook",
                    "Facebook sign-up coming soon",
                    snackPosition: SnackPosition.BOTTOM,
                  ),
                ),
                SizedBox(height: 10),
                _buildSocialButton(
                  icon: Icons.flutter_dash,
                  label: 'Continue with Twitter',
                  onTap: () => Get.snackbar(
                    "Twitter",
                    "Twitter sign-up coming soon",
                    snackPosition: SnackPosition.BOTTOM,
                  ),
                ),
                SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Color(0xFF1A2820).withOpacity(0.85),
                        fontSize: 13.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Color(0xFF1A2820),
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF1A2820),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
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
