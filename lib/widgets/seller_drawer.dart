import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/utils/themes.dart';
import '../screens/seller/shop/my_shop_screen.dart';

class SellerDrawer extends StatelessWidget {
  const SellerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    final userName = box.read("name") ?? "Seller";

    final userEmail = box.read("email") ?? "";

    return Drawer(
      backgroundColor: AppColors.cream,

      child: Column(
        children: [
          // HEADER
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.darkGreen),

            accountName: Text(userName),

            accountEmail: Text(userEmail),

            currentAccountPicture: const CircleAvatar(
              backgroundColor: AppColors.cream,

              child: Icon(Icons.store, size: 40, color: AppColors.darkGreen),
            ),
          ),

          // DASHBOARD
          drawerItem(
            icon: Icons.dashboard,
            title: "Dashboard",
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // MY SHOP
          drawerItem(
            icon: Icons.store,
            title: "My Shop",

            onTap: () {
              Navigator.pop(context);

              Get.to(() => const MyShopScreen());
            },
          ),

          // MY RICE
          drawerItem(icon: Icons.rice_bowl, title: "My Rice", onTap: () {}),

          // ORDERS
          drawerItem(icon: Icons.shopping_bag, title: "Orders", onTap: () {}),

          // NOTIFICATIONS
          drawerItem(
            icon: Icons.notifications,
            title: "Notifications",
            onTap: () {},
          ),

          // SETTINGS
          drawerItem(icon: Icons.settings, title: "Settings", onTap: () {}),

          const Spacer(),

          // LOGOUT
          drawerItem(
            icon: Icons.logout,
            title: "Logout",

            color: Colors.red,

            onTap: () {
              box.erase();

              Get.offAllNamed("/login");
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
