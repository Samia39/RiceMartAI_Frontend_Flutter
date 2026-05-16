import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/themes.dart';
import '../../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _obscurePassword = true;

  void register() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    try {
      var response = await _authService.register(name, email, password);

      if (response['user'] != null) {
        Get.snackbar("Success", "Registered successfully");
        Get.offNamed('/login');
      } else {
        Get.snackbar("Error", response['message']);
      }
    } catch (e) {
      Get.snackbar("Error", "Server error");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ─── Responsive values ───────────────────────────────
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth * 0.06;
    final verticalSpacing = screenHeight * 0.018;
    final buttonHeight = screenHeight * 0.062;
    final titleFontSize = screenWidth < 400 ? 18.0 : 20.0;
    // ─────────────────────────────────────────────────────

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
                    "Create Account\nJoin Rice Mart Today!",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: titleFontSize,
                    ),
                  ),

                  SizedBox(height: verticalSpacing * 1.5),

                  // NAME
                  Container(
                    decoration: AppDecorations.inputField,
                    child: TextField(
                      controller: nameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        hintText: "Name",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ),

                  SizedBox(height: verticalSpacing),

                  // EMAIL
                  Container(
                    decoration: AppDecorations.inputField,
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                  ),

                  SizedBox(height: verticalSpacing),

                  // PASSWORD
                  Container(
                    decoration: AppDecorations.inputField,
                    child: TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: "Password",
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

                  // REGISTER BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: register,
                      child: const Text("Register"),
                    ),
                  ),

                  SizedBox(height: verticalSpacing),

                  // LOGIN LINK
                  GestureDetector(
                    onTap: () => Get.offNamed('/login'),
                    child: Text(
                      "Already have an account? Login",
                      style: AppTextStyles.bodyLarge.copyWith(
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
