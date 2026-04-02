// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../register_screen.dart';
import '../login screen/forgot_password.dart';
import '../login screen/terms_screen.dart';
import '../login screen/privacy_policy_screen.dart';
import '../../core/services/auth_service.dart';

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

  void _showComingSoon(String platform) {
    Get.snackbar(
      "Coming Soon",
      "$platform login is coming soon!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFFD4C9A8).withOpacity(0.95),
      colorText: Color(0xFF1A2820),
      borderRadius: 10,
      margin: EdgeInsets.all(16),
      duration: Duration(seconds: 2),
    );
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
      decoration: BoxDecoration(
        color: Color(0xFFD4C9A8).withOpacity(0.30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFFB8A97A).withOpacity(0.55)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure && _obscurePassword,
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
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
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
    required String platform,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () => _showComingSoon(platform),
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
                SizedBox(height: 32),

                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2820),
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF1A2820).withOpacity(0.75),
                  ),
                ),
                SizedBox(height: 30),

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
                  obscure: true,
                ),
                SizedBox(height: 14),

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
                        activeColor: Color(0xFF9D7E3F),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(
                          color: Color(0xFF1A2820).withOpacity(0.7),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Color(0xFF1A2820).withOpacity(0.85),
                              fontSize: 13,
                              height: 1.5,
                            ),
                            children: [
                              TextSpan(text: 'I accept the '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TermsScreen(),
                                    ),
                                  ),
                                  child: Text(
                                    'Terms & Conditions',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A2820),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              TextSpan(text: ' and\n'),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PrivacyPolicyScreen(),
                                    ),
                                  ),
                                  child: Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A2820),
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
                SizedBox(height: 6),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF1A2820),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF1A2820),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18),

                // Sign In button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
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
                            'Sign In',
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
                  platform: 'Google',
                ),
                SizedBox(height: 10),
                _buildSocialButton(
                  icon: Icons.facebook,
                  label: 'Continue with Facebook',
                  platform: 'Facebook',
                ),
                SizedBox(height: 10),
                _buildSocialButton(
                  icon: Icons.flutter_dash,
                  label: 'Continue with Twitter',
                  platform: 'Twitter',
                ),
                SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Color(0xFF1A2820).withOpacity(0.85),
                        fontSize: 13.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
