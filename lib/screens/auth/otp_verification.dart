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

    // Auto-focus first box when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNodes[0]);
    });
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

      // Clear all boxes and re-focus first box
      for (var c in otpControllers) {
        c.clear();
      }
      FocusScope.of(context).requestFocus(focusNodes[0]);
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

          // FIX 1: explicit style so text is always visible
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen,
          ),

          // FIX 2: fully override theme decoration — no fill conflict
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),

          // FIX 3: select all text on tap so re-typing replaces old digit
          onTap: () {
            otpControllers[index].selection = TextSelection(
              baseOffset: 0,
              extentOffset: otpControllers[index].text.length,
            );
          },

          onChanged: (value) {
            if (value.isNotEmpty) {
              // digit typed — move to next box
              if (index < 5) {
                FocusScope.of(context).requestFocus(focusNodes[index + 1]);
              } else {
                // last box — close keyboard
                FocusScope.of(context).unfocus();
              }
            } else {
              // digit deleted (backspace) — go back to previous box
              if (index > 0) {
                FocusScope.of(context).requestFocus(focusNodes[index - 1]);
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                  SizedBox(height: screenHeight * 0.06),

                  // Lock icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.cream.withOpacity(0.30),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.borderGold.withOpacity(0.50),
                      ),
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 38,
                      color: AppColors.darkGreen,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.025),

                  // Title
                  Text(
                    "Verify Your Email",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading1.copyWith(fontSize: 22),
                  ),

                  const SizedBox(height: 10),

                  // Subtitle — shows the email
                  Text(
                    "We sent a 6-digit code to",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label.copyWith(
                      color: Color.fromARGB(255, 0, 0, 12),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, buildOtpBox),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Verify button
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
                          : const Text("Verify OTP"),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.025),

                  // Resend OTP
                  secondsLeft > 0
                      ? RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTextStyles.bodyMedium,
                            children: [
                              const TextSpan(text: "Resend OTP in "),
                              TextSpan(
                                text: "$secondsLeft s",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 0, 0, 12),
                                ),
                              ),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: isResending ? null : resendOtp,
                          child: Text(
                            isResending ? "Resending..." : "Resend OTP",
                            style: AppTextStyles.bodyLarge.copyWith(
                              decoration: TextDecoration.underline,
                              color: Color.fromARGB(255, 0, 0, 12),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                  SizedBox(height: screenHeight * 0.02),

                  // Back to register
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      " Back",
                      style: AppTextStyles.bodyMedium.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
