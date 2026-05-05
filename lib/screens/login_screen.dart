import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/utils/themes.dart';
import '../core/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final box = GetStorage();

  void login() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    try {
      var response = await _authService.login(email, password);

      if (response['token'] != null) {
        box.write('token', response['token']);

        Get.snackbar("Success", "Login successful");

        Get.offNamed(AppRoutes.adminDashboard);
      } else {
        Get.snackbar("Error", response['message']);
      }
    } catch (e) {
      Get.snackbar("Error", "Server error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground, // 🌈 gradient applied

      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🏷️ Title
                  Text(
                    "Login",
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.darkGreen,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 📧 Email Field
                  Container(
                    decoration: AppDecorations.inputField,
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: "Enter your email",
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 🔒 Password Field
                  Container(
                    decoration: AppDecorations.inputField,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "Enter your password",
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🔘 Login Button
                  ElevatedButton(onPressed: login, child: const Text("Login")),

                  const SizedBox(height: 20),

                  // 🔁 Register Navigation
                  GestureDetector(
                    onTap: () {
                      Get.toNamed('/register');
                    },
                    child: Text(
                      "Don't have an account? Register",
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
