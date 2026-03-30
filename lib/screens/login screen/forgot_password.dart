import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _sendResetLink() async {
    if (_emailController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your email address",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFFD4C9A8).withOpacity(0.95),
        colorText: Color(0xFF1A2820),
        borderRadius: 10,
        margin: EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(Duration(seconds: 2)); // Simulate API call
    setState(() {
      _isLoading = false;
      _emailSent = true;
    });
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
          child: Column(
            children: [
              // Back button row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFFD4C9A8).withOpacity(0.30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Color(0xFFB8A97A).withOpacity(0.5),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF1A2820),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30),

                      // Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFFD4C9A8).withOpacity(0.30),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: Color(0xFFB8A97A).withOpacity(0.55),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          color: Color(0xFF1A2820),
                          size: 36,
                        ),
                      ),
                      SizedBox(height: 24),

                      Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2820),
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _emailSent
                            ? 'Reset link has been sent!\nCheck your email inbox.'
                            : 'No worries! Enter your email and\nwe\'ll send you a reset link.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF1A2820).withOpacity(0.75),
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 36),

                      if (!_emailSent) ...[
                        // Email field
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFD4C9A8).withOpacity(0.30),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Color(0xFFB8A97A).withOpacity(0.55),
                            ),
                          ),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: Color(0xFF1A2820),
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your email address',
                              hintStyle: TextStyle(
                                color: Color(0xFF1A2820).withOpacity(0.6),
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Color(0xFF1A2820).withOpacity(0.75),
                                size: 19,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Send Reset Link button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendResetLink,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(
                                0xFFD4C9A8,
                              ).withOpacity(0.35),
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
                                    'Send Reset Link',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A2820),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                      ] else ...[
                        // Success state
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xFFD4C9A8).withOpacity(0.30),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFFB8A97A).withOpacity(0.55),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.mark_email_read_outlined,
                                color: Color(0xFF1A2820),
                                size: 28,
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'A password reset link has been sent to ${_emailController.text}',
                                  style: TextStyle(
                                    color: Color(0xFF1A2820),
                                    fontSize: 13.5,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Resend button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => setState(() => _emailSent = false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(
                                0xFFD4C9A8,
                              ).withOpacity(0.35),
                              foregroundColor: Color(0xFF1A2820),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: Color(0xFFB8A97A).withOpacity(0.7),
                                ),
                              ),
                            ),
                            child: Text(
                              'Resend Email',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A2820),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 24),

                      // Back to login
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back_rounded,
                              size: 15,
                              color: Color(0xFF1A2820),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Back to Sign In',
                              style: TextStyle(
                                color: Color(0xFF1A2820),
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF1A2820),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
