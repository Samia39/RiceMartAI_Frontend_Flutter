// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/themes.dart';
import '../core/services/auth_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/bottom_nav.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.getCurrentUser();

    return Scaffold(
      drawer: const AppDrawer(),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: AppDecorations.iconButton,
                          child: Icon(Icons.menu,
                              color: AppColors.darkGreen, size: 24),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text('Welcome,', style: AppTextStyles.bodyMedium),
                        Text(user['name'] ?? 'User',
                            style: AppTextStyles.heading3),
                      ],
                    ),
                    Icon(Icons.person,
                        color: AppColors.darkGreen, size: 28),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    children: [
                      _menuCard(Icons.rice_bowl, 'Products', () {}),
                      _menuCard(Icons.shopping_cart, 'My Orders', () {}),
                      _menuCard(Icons.favorite, 'Wishlist', () {}),
                      _menuCard(Icons.person, 'My Profile', () {}),
                      _menuCard(Icons.star, 'Reviews', () {}),
                      _menuCard(Icons.help, 'Support', () {}),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppDecorations.card,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.darkGreen),
            const SizedBox(height: 12),
            Text(label, style: AppTextStyles.heading4),
          ],
        ),
      ),
    );
  }
}