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

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // ── User Info Header ──────────────────────────
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card,
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.cream.withOpacity(0.35),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.borderGold, width: 1.5),
                      ),
                      child: Icon(Icons.person,
                          color: AppColors.darkGreen, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'] ?? 'User',
                          style: AppTextStyles.heading4,
                        ),
                        Text(
                          user['role'] ?? 'user',
                          style: AppTextStyles.labelMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Menu Items ────────────────────────────────
              _drawerItem(
                icon: Icons.home_outlined,
                label: 'Home',
                onTap: () {
                  Get.back();
                  final role = AuthService.getRole();
                  if (role == 'admin') {
                    Get.offNamed('/admin-dashboard');
                  } else if (role == 'seller') {
                    Get.offNamed('/seller-dashboard');
                  } else {
                    Get.offNamed('/user-dashboard');
                  }
                },
              ),
              _drawerItem(
                icon: Icons.rice_bowl_outlined,
                label: 'Products',
                onTap: () {
                  Get.back();
                },
              ),
              _drawerItem(
                icon: Icons.shopping_cart_outlined,
                label: 'Orders',
                onTap: () {
                  Get.back();
                },
              ),
              _drawerItem(
                icon: Icons.favorite_outline,
                label: 'Wishlist',
                onTap: () {
                  Get.back();
                },
              ),
              _drawerItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () {
                  Get.back();
                },
              ),
              _drawerItem(
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: () {
                  Get.back();
                },
              ),
              _drawerItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () {
                  Get.back();
                },
              ),

              const Spacer(),

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
                    decoration: AppDecorations.card,
                    child: Row(
                      children: [
                        Icon(Icons.logout,
                            color: AppColors.darkGreen, size: 22),
                        const SizedBox(width: 12),
                        Text('Logout', style: AppTextStyles.heading4),
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

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: AppDecorations.card,
          child: Row(
            children: [
              Icon(icon, color: AppColors.darkGreen, size: 22),
              const SizedBox(width: 14),
              Text(label, style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}