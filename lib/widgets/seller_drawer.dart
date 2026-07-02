import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/utils/themes.dart';
import '../routes/app_routes.dart';

class SellerDrawer extends StatelessWidget {
  // =========================
  // TAB SWITCH CALLBACK
  // =========================
  final Function(int) onTabSelected;

  const SellerDrawer({super.key, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    final userName = box.read("name") ?? "Seller";
    final userEmail = box.read("email") ?? "";

    return Drawer(
      backgroundColor: AppColors.cream,

      child: Column(
        children: [
          // =========================
          // HEADER
          // =========================
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.darkGreen),

            accountName: Text(userName),

            accountEmail: Text(userEmail),

            currentAccountPicture: const CircleAvatar(
              backgroundColor: AppColors.cream,

              child: Icon(Icons.store, size: 40, color: AppColors.darkGreen),
            ),
          ),

          // =========================
          // DASHBOARD TAB
          // =========================
          drawerItem(
            icon: Icons.dashboard,
            title: "Dashboard",

            onTap: () {
              Navigator.pop(context);

              // HOME TAB
              onTabSelected(0);
            },
          ),

          // =========================
          // MY RICE TAB
          // =========================
          drawerItem(
            icon: Icons.rice_bowl,
            title: "My Rice",

            onTap: () {
              Navigator.pop(context);

              // RICE TAB
              onTabSelected(1);
            },
          ),

          // =========================
          // MY SHOP TAB
          // =========================
          drawerItem(
            icon: Icons.store,
            title: "My Shop",

            onTap: () {
              Navigator.pop(context);

              // SHOP TAB
              onTabSelected(2);
            },
          ),

          // =========================
          // ORDERS TAB
          // =========================
          drawerItem(
            icon: Icons.shopping_bag,
            title: "Orders",

            onTap: () {
              Navigator.pop(context);

              // ORDERS TAB
              onTabSelected(4);
            },
          ),

          // =========================
          // PROFILE TAB
          // =========================
          drawerItem(
            icon: Icons.person,
            title: "Profile",

            onTap: () {
              Navigator.pop(context);

              // PROFILE TAB
              onTabSelected(5);
            },
          ),

          // =========================
          // NOTIFICATIONS
          // =========================
          drawerItem(
            icon: Icons.notifications,
            title: "Notifications",
            onTap: () {},
          ),

          const Spacer(),

          // =========================
          // LOGOUT
          // =========================
          drawerItem(
            icon: Icons.logout,
            title: "Logout",

            color: Colors.red,

            onTap: () {
              box.erase();

              Get.offAllNamed(AppRoutes.login);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // =========================
  // DRAWER ITEM
  // =========================
  Widget drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AppColors.darkGreen,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),

      title: Text(
        title,

        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),

      onTap: onTap,
    );
  }
}
