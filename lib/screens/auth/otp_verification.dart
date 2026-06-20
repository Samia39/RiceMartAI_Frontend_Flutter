import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/themes.dart';
import '../../core/services/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final String email;

  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  bool isLoading = false;
  bool isResending = false;
  int secondsLeft = 30;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    email = args?['email'] ?? '';
    startTimer();
  }

  void startTimer() {
    secondsLeft = 30;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get enteredOtp => otpControllers.map((c) => c.text).join();

  void verifyOtp() async {
    if (enteredOtp.length != 6) {
      Get.snackbar("Error", "Please enter the complete 6-digit OTP");
      return;
    }

    setState(() => isLoading = true);

    try {
      var response = await AuthService.verifyOtp(email, enteredOtp);
      Get.snackbar("Success", response['message'] ?? "Registered successfully");
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar("Error", e.toString().replaceAll("Exception: ", ""));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void resendOtp() async {
    setState(() => isResending = true);
    try {
      var response = await AuthService.resendOtp(email);
      Get.snackbar("Success", response['message'] ?? "OTP resent");
      startTimer();
    } catch (e) {
      Get.snackbar("Error", e.toString().replaceAll("Exception: ", ""));
    } finally {
      setState(() => isResending = false);
    }
  }

  Widget buildOtpBox(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: Container(
        decoration: AppDecorations.inputField,
        child: TextField(
          controller: otpControllers[index],
          focusNode: focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: AppTextStyles.heading2,
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              FocusScope.of(context).requestFocus(focusNodes[index + 1]);
            } else if (value.isEmpty && index > 0) {
              FocusScope.of(context).requestFocus(focusNodes[index - 1]);
            }
            if (index == 5 && value.isNotEmpty) {
              FocusScope.of(context).unfocus();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "Verify Your Email",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading1.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "We sent a 6-digit code to\n$email",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, buildOtpBox),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : verifyOtp,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Verify"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  secondsLeft > 0
                      ? Text(
                          "Resend OTP in $secondsLeft s",
                          style: AppTextStyles.bodyMedium,
                        )
                      : GestureDetector(
                          onTap: isResending ? null : resendOtp,
                          child: Text(
                            isResending ? "Resending..." : "Resend OTP",
                            style: AppTextStyles.bodyLarge.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
