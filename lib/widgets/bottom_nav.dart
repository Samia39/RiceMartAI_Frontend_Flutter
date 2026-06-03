// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/themes.dart';
import '../core/services/auth_service.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream.withOpacity(0.95),
        border: Border(
          top: BorderSide(
              color: AppColors.borderGold.withOpacity(0.4), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.darkGreen,
        unselectedItemColor: AppColors.darkGreen.withOpacity(0.45),
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rice_bowl_outlined),
            activeIcon: Icon(Icons.rice_bowl),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _onTap(int index) {
    final role = AuthService.getRole();
    switch (index) {
      case 0:
        if (role == 'admin') {
          Get.offNamed('/admin-dashboard');
        } else if (role == 'seller') {
          Get.offNamed('/seller-dashboard');
        } else {
          Get.offNamed('/user-dashboard');
        }
        break;
      case 1:
        Get.toNamed('/products');
        break;
      case 2:
        Get.toNamed('/orders');
        break;
      case 3:
        Get.toNamed('/profile');
        break;
      case 4:
        Get.toNamed('/settings');
        break;
    }
  }
}