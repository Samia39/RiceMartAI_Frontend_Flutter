import 'package:flutter/material.dart';
import 'package:frontend/screens/buyer/rice/all_rice_screen.dart';
import 'package:frontend/screens/buyer/shops/shops_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/utils/themes.dart';
import '../screens/buyer/cart/cart_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    final userName = box.read("name") ?? "User";

    final userEmail = box.read("email") ?? "";

    return Drawer(
      backgroundColor: AppColors.cream,

      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppColors.darkGreen),

                accountName: Text(userName),

                accountEmail: Text(userEmail),

                currentAccountPicture: const CircleAvatar(
                  backgroundColor: AppColors.cream,

                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),

              // HOME
              drawerItem(
                icon: Icons.home,
                title: "Home",

                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // RICE MARKETPLACE
              drawerItem(
                icon: Icons.rice_bowl,
                title: "Rice Marketplace",

                onTap: () {
                  Navigator.pop(context);

                  Get.to(() => const AllRiceScreen());
                },
              ),

              // SHOPS
              drawerItem(
                icon: Icons.store,
                title: "Shops",

                onTap: () {
                  Navigator.pop(context);

                  Get.to(() => const ShopsScreen());
                },
              ),
              // Add to Cart
              drawerItem(
                icon: Icons.shopping_cart,
                title: "My Cart",

                onTap: () {
                  Navigator.pop(context);

                  Get.to(() => const CartScreen());
                },
              ),

              // PROFILE
              drawerItem(icon: Icons.person, title: "Profile", onTap: () {}),

              // ORDERS
              drawerItem(
                icon: Icons.shopping_bag,
                title: "Orders",
                onTap: () {},
              ),

              // NOTIFICATIONS
              drawerItem(
                icon: Icons.notifications,
                title: "Notifications",
                onTap: () {},
              ),

              // SETTINGS
              drawerItem(icon: Icons.settings, title: "Settings", onTap: () {}),

              // FEEDBACK
              drawerItem(icon: Icons.feedback, title: "Feedback", onTap: () {}),

              const SizedBox(height: 20),

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
        ),
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
