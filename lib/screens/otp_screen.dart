// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/themes.dart';
import '../core/services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading  = false;
  bool _isResending = false;
  int  _countdown  = 600; // 10 minutes
  Timer? _timer;
  late String _email;

  @override
  void initState() {
    super.initState();
    _email = Get.arguments['email'] ?? '';
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  String get _timerText {
    final m = (_countdown ~/ 60).toString().padLeft(2, '0');
    final s = (_countdown % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get _otp =>
      _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otp.length < 6) {
      _snack('Please enter complete 6-digit OTP.');
      return;
    }

    setState(() => _isLoading = true);
    final error = await AuthService.verifyOtp(
      email: _email,
      otp:   _otp,
    );
    if (mounted) setState(() => _isLoading = false);

    if (error == null) {
      _snack('Account created successfully!');
      Get.offNamed('/login');
    } else {
      _snack(error);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);
    final error = await AuthService.resendOtp(email: _email);
    if (mounted) setState(() => _isResending = false);

    if (error == null) {
      setState(() => _countdown = 600);
      _timer?.cancel();
      _startTimer();
      _snack('OTP resent successfully!');
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.cream.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.borderGold, width: 1.5),
                    ),
                    child: Icon(Icons.mark_email_read_outlined,
                        size: 40, color: AppColors.darkGreen),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text('Verify Your Email',
                    style: AppTextStyles.heading1.copyWith(fontSize: 26),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'We sent a 6-digit OTP to\n$_email',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // OTP Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (i) {
                    return SizedBox(
                      width: 45,
                      child: Container(
                        decoration: AppDecorations.inputField,
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: AppTextStyles.heading2,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && i < 5) {
                              _focusNodes[i + 1].requestFocus();
                            } else if (val.isEmpty && i > 0) {
                              _focusNodes[i - 1].requestFocus();
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Timer
                Center(
                  child: Text(
                    'OTP expires in: $_timerText',
                    style: AppTextStyles.labelMuted,
                  ),
                ),
                const SizedBox(height: 32),

                // Verify Button
                ElevatedButton(
                  style: AppButtonStyles.primary,
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.darkGreen))
                      : Text('Verify OTP', style: AppTextStyles.button),
                ),
                const SizedBox(height: 20),

                // Resend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Didn't receive OTP? ",
                        style: AppTextStyles.bodyMedium),
                    TextButton(
                      style: AppButtonStyles.ghost,
                      onPressed: _countdown == 0 && !_isResending
                          ? _resendOtp
                          : null,
                      child: _isResending
                          ? const SizedBox(
                              height: 14, width: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2))
                          : Text(
                              'Resend OTP',
                              style: AppTextStyles.label.copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.darkGreen,
                                color: _countdown == 0
                                    ? AppColors.darkGreen
                                    : AppColors.darkGreen.withOpacity(0.4),
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}