import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/utils/themes.dart';

import '../../auth/login_screen.dart';

import '../../seller/shop/create_shop_screen.dart';
import '../../seller/dashboard/seller_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    String role = box.read("role") ?? "user";

    bool hasShop = box.read("has_shop") ?? false;

    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Profile")),

        body: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              // PROFILE CARD
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(20),

                decoration: AppDecorations.card,

                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    ),

                    const SizedBox(height: 16),

                    Text("Marketplace User", style: AppTextStyles.heading3),

                    const SizedBox(height: 8),

                    Text(role.toUpperCase(), style: AppTextStyles.bodyLarge),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // BECOME SELLER
              if (!hasShop)
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => const CreateShopScreen());
                    },

                    icon: const Icon(Icons.store),

                    label: const Text("Become Seller"),
                  ),
                ),

              // GO TO SELLER DASHBOARD
              if (hasShop)
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => const SellerDashboardScreen());
                    },

                    icon: const Icon(Icons.dashboard),

                    label: const Text("Seller Dashboard"),
                  ),
                ),

              const SizedBox(height: 14),

              // LOGOUT
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                  onPressed: () {
                    box.erase();

                    Get.offAll(() => LoginScreen());
                  },

                  icon: const Icon(Icons.logout),

                  label: const Text("Logout"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
