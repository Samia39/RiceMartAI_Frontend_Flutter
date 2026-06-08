// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/themes.dart';
import '../core/services/auth_service.dart';
import '../widgets/app_drawer.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = AuthService.getCurrentUser();

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      bottomNavigationBar: _buildBottomNav(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
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

              // ── Welcome ──────────────────────────────────
              const Expanded(
                child: Center(
                  child: Text('Welcome',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                        letterSpacing: 1.0,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded,        'label': 'Home'},
      {'icon': Icons.store_rounded,       'label': 'Shops'},
      {'icon': Icons.inventory_2_rounded, 'label': 'Products'},
      {'icon': Icons.person_rounded,      'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.golden.withOpacity(0.88),
        border: Border(
          top: BorderSide(
              color: AppColors.borderGold.withOpacity(0.50), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _currentIndex == i;
              return GestureDetector(
                onTap: () {
                  setState(() => _currentIndex = i);
                  if (i == 0) Get.offNamed('/admin-dashboard');
                  if (i == 1) Get.toNamed('/admin-shops');
                  if (i == 2) Get.toNamed('/admin-products');
                  if (i == 3) {}
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 66,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 40,
                        height: 36,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.darkGreen.withOpacity(0.20)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          items[i]['icon'] as IconData,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.5,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}