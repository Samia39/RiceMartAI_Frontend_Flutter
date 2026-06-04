// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/themes.dart';
import '../core/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.getCurrentUser();
    final role = AuthService.getRole() ?? 'user'; // ← FIX: ?? 'user' add kiya

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        color: AppColors.cream,
        child: SafeArea(
          child: Column(
            children: [
              // ── User Header ──────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: AppColors.darkGreen,
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.cream.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.borderGold, width: 2),
                      ),
                      child: Icon(Icons.person,
                          color: AppColors.cream, size: 40),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user['name'] ?? 'User',
                      style: AppTextStyles.heading4
                          .copyWith(color: AppColors.cream),
                    ),
                    Text(
                      role.toUpperCase(), // ← Ab error nahi aaye ga
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.cream.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Menu Items — Role k hisab se ─────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _drawerItem(Icons.home_outlined, 'Home', () {
                      Get.back();
                      if (role == 'admin') {
                        Get.offNamed('/admin-dashboard');
                      } else if (role == 'seller') {
                        Get.offNamed('/seller-dashboard');
                      } else {
                        Get.offNamed('/user-dashboard');
                      }
                    }),

                    if (role == 'user') ...[
                      _drawerItem(Icons.storefront_outlined,
                          'Rice Marketplace', () {
                        Get.back();
                        Get.toNamed('/user-products');
                      }),
                      _drawerItem(Icons.store_outlined, 'Shops', () {
                        Get.back();
                        Get.toNamed('/shops');
                      }),
                      _drawerItem(
                          Icons.shopping_cart_outlined, 'My Cart', () {
                        Get.back();
                      }),
                      _drawerItem(Icons.person_outline, 'Profile', () {
                        Get.back();
                      }),
                      _drawerItem(
                          Icons.shopping_bag_outlined, 'My Orders', () {
                        Get.back();
                      }),
                      _drawerItem(
                          Icons.notifications_outlined, 'Notifications', () {
                        Get.back();
                      }),
                      _drawerItem(Icons.settings_outlined, 'Settings', () {
                        Get.back();
                      }),
                      _drawerItem(Icons.feedback_outlined, 'Feedback', () {
                        Get.back();
                      }),
                    ],

                    if (role == 'seller') ...[
                      _drawerItem(Icons.rice_bowl_outlined, 'My Products',
                          () {
                        Get.back();
                        Get.toNamed('/my-products');
                      }),
                      _drawerItem(Icons.add_box_outlined, 'Add Product', () {
                        Get.back();
                        Get.toNamed('/add-product');
                      }),
                      _drawerItem(
                          Icons.shopping_bag_outlined, 'My Orders', () {
                        Get.back();
                      }),
                      _drawerItem(Icons.person_outline, 'Profile', () {
                        Get.back();
                      }),
                      _drawerItem(Icons.settings_outlined, 'Settings', () {
                        Get.back();
                      }),
                    ],

                    if (role == 'admin') ...[
                      _drawerItem(Icons.inventory_2_outlined, 'All Products',
                          () {
                        Get.back();
                        Get.toNamed('/admin-products');
                      }),
                      _drawerItem(Icons.store_outlined, 'All Shops', () {
                        Get.back();
                      }),
                      _drawerItem(Icons.people_outline, 'Users', () {
                        Get.back();
                      }),
                      _drawerItem(Icons.settings_outlined, 'Settings', () {
                        Get.back();
                      }),
                    ],
                  ],
                ),
              ),

              // ── Logout ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () async {
                    await AuthService.logout();
                    Get.offAllNamed('/login');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.logout,
                            color: AppColors.error, size: 22),
                        const SizedBox(width: 12),
                        Text('Logout',
                            style: AppTextStyles.heading4
                                .copyWith(color: AppColors.error)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkGreen, size: 22),
      title: Text(label, style: AppTextStyles.bodyLarge),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}