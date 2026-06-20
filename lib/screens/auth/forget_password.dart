import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/themes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool _obscurePassword = true;
  bool _otpSent = false;
  bool _isLoading = false;

  // STEP 1: send OTP to email
  Future<void> _sendOtp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please enter email and new password');
      return;
    }
    if (password.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.forgotPassword(email);
      setState(() => _otpSent = true);
      Get.snackbar('OTP Sent', 'Check your email for the OTP code');
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // STEP 2: verify OTP and reset password
  Future<void> _resetPassword() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      Get.snackbar('Error', 'Please enter the OTP');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.resetPassword(email, otp, password);
      Get.snackbar('Success', 'Password reset successful. Please login.');
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth * 0.06;
    final verticalSpacing = screenHeight * 0.018;
    final buttonHeight = screenHeight * 0.062;
    final titleFontSize = screenWidth < 400 ? 18.0 : 20.0;

    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkGreen),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: verticalSpacing),

                  Text(
                    _otpSent
                        ? "Enter OTP to Reset Password"
                        : "Forgot Password?\nEnter your email and new password",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.darkGreen,
                      fontSize: titleFontSize,
                    ),
                  ),

                  SizedBox(height: verticalSpacing * 1.5),

                  // EMAIL FIELD
                  Container(
                    decoration: AppDecorations.inputField,
                    child: TextField(
                      controller: emailController,
                      enabled: !_otpSent, // lock email after OTP sent
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "Enter your email",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                  ),

                  SizedBox(height: verticalSpacing),

                  // NEW PASSWORD FIELD
                  Container(
                    decoration: AppDecorations.inputField,
                    child: TextField(
                      controller: passwordController,
                      enabled: !_otpSent,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Enter new password",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  // OTP FIELD - only shows after OTP sent
                  if (_otpSent) ...[
                    SizedBox(height: verticalSpacing),
                    Container(
                      decoration: AppDecorations.inputField,
                      child: TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Enter 6-digit OTP",
                          prefixIcon: Icon(Icons.sms_outlined),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: verticalSpacing * 1.5),

                  // ACTION BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_otpSent ? _resetPassword : _sendOtp),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_otpSent ? "Reset Password" : "Send OTP"),
                    ),
                  ),

                  SizedBox(height: verticalSpacing),

                  // RESEND OTP link (only when OTP step is active)
                  if (_otpSent)
                    GestureDetector(
                      onTap: _isLoading ? null : _sendOtp,
                      child: Text(
                        "Didn't get the code? Resend OTP",
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.darkGreen,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                  SizedBox(height: verticalSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
