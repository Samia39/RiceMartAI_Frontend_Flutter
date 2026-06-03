// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/themes.dart';
import '../core/services/auth_service.dart';
import '../widgets/app_drawer.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.getCurrentUser();

    return Scaffold(
      drawer: const AppDrawer(),
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
                    // 3 lines button
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
                        Text('Admin Panel', style: AppTextStyles.bodyMedium),
                        Text(user['name'] ?? 'Admin',
                            style: AppTextStyles.heading3),
                      ],
                    ),
                    Icon(Icons.admin_panel_settings,
                        color: AppColors.golden, size: 28),
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
                      _menuCard(Icons.people, 'Manage Users', () {}),
                      _menuCard(Icons.rice_bowl, 'Manage Products', () {}),
                      _menuCard(Icons.shopping_bag, 'All Orders', () {}),
                      _menuCard(Icons.bar_chart, 'Reports', () {}),
                      _menuCard(Icons.settings, 'Settings', () {}),
                      _menuCard(Icons.notifications, 'Notifications', () {}),
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