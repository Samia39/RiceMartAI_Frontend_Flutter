import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/utils/themes.dart';
import '../../core/services/auth_service.dart';

import '../buyer/dashboard/buyer_dashboard_screen.dart';
import '../seller/dashboard/seller_dashboard_screen.dart';
import '../admin_screens/dashboard/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _obscurePassword = true;

  // =========================
  // LOGIN
  // =========================
  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    try {
      var response = await _authService.login(email, password);

      print(response);

      if (response['token'] != null) {
        final box = GetStorage();

        box.erase();
        box.write('token', response['token']);
        box.write('role', response['role']);
        box.write('user', response['user']);

        final shop = response['shop'];
        box.write('has_shop', shop != null);

        if (shop != null) {
          box.write("shop_id", shop["id"]);
          box.write("shop_name", shop["shop_name"]);
          box.write("owner_name", shop["owner_name"]);
          box.write("phone", shop["phone"]);
          box.write("address", shop["address"]);
          box.write("description", shop["description"]);
          box.write("shop_approved", true);
        }

        Get.snackbar("Success", "Login successful");

        String role = response['role'] ?? "user";

        if (role == "admin") {
          Get.offAll(() => const AdminDashboard());
          return;
        }

        if (shop != null) {
          Get.offAll(() => const SellerDashboardScreen());
          return;
        }

        Get.offAll(() => const BuyerDashboardScreen());
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
    // ─── Responsive values ───────────────────────────────
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth * 0.06;
    final verticalSpacing = screenHeight * 0.018;
    final buttonHeight = screenHeight * 0.062;
    final titleFontSize = screenWidth < 400 ? 18.0 : 20.0; // fixed, not % based
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
                    "Welcome Back to Rice Mart\nLogin to Continue!",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.darkGreen,
                      fontSize: titleFontSize,
                    ),
                  ),

                  SizedBox(height: verticalSpacing * 1.5),

                  // EMAIL
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

                  // PASSWORD
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
                      onPressed: login,
                      child: const Text("Login"),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
