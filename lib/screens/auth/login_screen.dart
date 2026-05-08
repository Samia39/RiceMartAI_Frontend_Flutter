import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/utils/themes.dart';
import '../../core/services/auth_service.dart';

import '../buyer/dashboard/buyer_dashboard_screen.dart';
import '../seller/dashboard/seller_dashboard_screen.dart';
import '../admin_screens/dashboard/admin_dashboard.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final box = GetStorage();

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    try {
      var response = await _authService.login(email, password);

      if (response['token'] != null) {
        // SAVE TOKEN
        box.write('token', response['token']);

        // SAVE ROLE
        box.write('role', response['role']);

        // SAVE SHOP STATUS
        box.write('has_shop', response['has_shop']);

        Get.snackbar("Success", "Login successful");

        String role = response['role'] ?? "user";

        bool hasShop = response['has_shop'] ?? false;

        // =========================
        // ADMIN
        // =========================
        if (role == "admin") {
          Get.offAll(() => const AdminDashboard());
        }
        // =========================
        // SELLER
        // =========================
        else if (hasShop == true) {
          Get.offAll(() => const SellerDashboardScreen());
        }
        // =========================
        // BUYER
        // =========================
        else {
          Get.offAll(() => const BuyerDashboardScreen());
        }
      } else {
        Get.snackbar("Error", response['message'] ?? "Login failed");
      }
    } catch (e) {
      print(e);

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
