import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../core/utils/themes.dart';
import '../../routes/app_routes.dart'; // adjust path to wherever AppRoutes lives

// ...
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final AuthController authController = Get.put(AuthController());

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    // Responsive values
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

        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  SizedBox(height: verticalSpacing * 2),

                  // TITLE
                  Text(
                    "Welcome  to Rice Mart\nLogin to Continue!",

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

                      keyboardType: TextInputType.emailAddress,

                      decoration: const InputDecoration(
                        hintText: "Enter your email",

                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                  ),

                  SizedBox(height: verticalSpacing),

                  // PASSWORD FIELD
                  Container(
                    decoration: AppDecorations.inputField,

                    child: TextField(
                      controller: passwordController,

                      obscureText: _obscurePassword,

                      decoration: InputDecoration(
                        hintText: "Enter your password",

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

                  SizedBox(height: verticalSpacing * 1.5),

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,

                    child: ElevatedButton(
                      onPressed: () {
                        authController.login(
                          emailController.text.trim(),

                          passwordController.text.trim(),
                        );
                      },

                      child: Obx(() {
                        return authController.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Login");
                      }),
                    ),
                  ),

                  SizedBox(height: verticalSpacing),

                  // REGISTER LINK
                  GestureDetector(
                    onTap: () => Get.toNamed('/register'),

                    child: Text(
                      "Don't have an account? Register",

                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.darkGreen,

                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  SizedBox(height: verticalSpacing),
                  SizedBox(height: verticalSpacing),

                  // FORGOT PASSWORD LINK
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.forgotpassword),
                    child: Text(
                      "Forgot Password?",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.darkGreen,
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
