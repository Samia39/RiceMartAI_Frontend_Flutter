import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/utils/themes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/shop_service.dart';

import '../buyer/dashboard/buyer_dashboard_screen.dart';
import '../seller/dashboard/seller_dashboard_screen.dart';
import '../admin_screens/dashboard/admin_dashboard.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();

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

        // SAVE TOKEN
        box.write('token', response['token']);

        // SAVE ROLE
        box.write('role', response['role']);

        // SHOP STATUS
        bool hasShop = response['has_shop'] ?? false;

        box.write('has_shop', hasShop);

        Get.snackbar("Success", "Login successful");

        String role = response['role'] ?? "user";

        // =========================
        // ADMIN
        // =========================
        if (role == "admin") {
          Get.offAll(() => const AdminDashboard());

          return;
        }

        // =========================
        // SELLER
        // =========================
        if (hasShop == true) {
          try {
            final shops = await ShopService().fetchApprovedShops();

            final sellerShop = shops.firstWhere(
              (shop) => shop["user_id"] == response["user"]["id"],
            );

            // SAVE SHOP DATA
            box.write("shop_id", sellerShop["id"]);

            box.write("shop_name", sellerShop["shop_name"]);
            box.write("owner_name", sellerShop["owner_name"]);
            box.write("phone", sellerShop["phone"]);
            box.write("address", sellerShop["address"]);
            box.write("description", sellerShop["description"]);

            box.write("shop_approved", true);
          } catch (e) {
            print(e);
          }

          Get.offAll(() => const SellerDashboardScreen());

          return;
        }

        // =========================
        // BUYER
        // =========================
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
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  // TITLE
                  Text(
                    "Login",
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.darkGreen,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // EMAIL
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

                  // PASSWORD
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

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      onPressed: login,

                      child: const Text("Login"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // REGISTER
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
