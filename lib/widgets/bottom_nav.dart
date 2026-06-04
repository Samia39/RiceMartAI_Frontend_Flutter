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
    final role = AuthService.getRole() ?? 'user'; // ← ?? 'user' add kiya

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
        onTap: (index) => _onTap(index, role),
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.darkGreen,
        unselectedItemColor: AppColors.darkGreen.withOpacity(0.45),
        selectedLabelStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: _getItems(role),
      ),
    );
  }

  List<BottomNavigationBarItem> _getItems(String role) {
    if (role == 'admin') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Products',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store_outlined),
          activeIcon: Icon(Icons.store),
          label: 'Shops',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else if (role == 'seller') {
      return const [
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
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.rice_bowl_outlined),
          activeIcon: Icon(Icons.rice_bowl),
          label: 'Rice',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store_outlined),
          activeIcon: Icon(Icons.store),
          label: 'Shops',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_outlined),
          activeIcon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
  }

  void _onTap(int index, String role) {
    if (role == 'admin') {
      switch (index) {
        case 0: Get.offNamed('/admin-dashboard'); break;
        case 1: Get.toNamed('/admin-products'); break;
        case 2: Get.toNamed('/admin-shops'); break;
        case 3: Get.toNamed('/profile'); break;
      }
    } else if (role == 'seller') {
      switch (index) {
        case 0: Get.offNamed('/seller-dashboard'); break;
        case 1: Get.toNamed('/my-products'); break;
        case 2: Get.toNamed('/my-orders'); break;
        case 3: Get.toNamed('/profile'); break;
      }
    } else {
      switch (index) {
        case 0: Get.offNamed('/user-dashboard'); break;
        case 1: Get.toNamed('/user-products'); break;
        case 2: Get.toNamed('/shops'); break;
        case 3: Get.toNamed('/chat'); break;
        case 4: Get.toNamed('/profile'); break;
      }
    }
  }
}