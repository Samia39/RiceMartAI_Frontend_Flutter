import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/themes.dart';
import '../core/services/auth_service.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  void register() async {
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;

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
    return Container(
      decoration: AppDecorations.gradientBackground, // 🌈 gradient

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
                  Text("Register", style: AppTextStyles.heading1),

                  const SizedBox(height: 30),

                  // 👤 Name
                  Container(
                    decoration: AppDecorations.inputField,
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(hintText: "Name"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 📧 Email
                  Container(
                    decoration: AppDecorations.inputField,
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(hintText: "Email"),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 🔒 Password
                  Container(
                    decoration: AppDecorations.inputField,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: "Password"),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🔘 Register Button (uses theme automatically)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: register,
                      child: const Text("Register"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔁 Back to Login
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Text(
                      "Already have an account? Login",
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
