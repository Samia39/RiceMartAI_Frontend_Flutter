import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/utils/themes.dart';
import '../routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  // =========================
  // TAB SWITCH CALLBACK
  // =========================
  final Function(int) onTabSelected;

  const AppDrawer({super.key, required this.onTabSelected});

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
              // =========================
              // HEADER
              // =========================
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

              // =========================
              // HOME TAB
              // =========================
              drawerItem(
                icon: Icons.home,
                title: "Home",

                onTap: () {
                  Navigator.pop(context);

                  // SWITCH TO HOME TAB
                  onTabSelected(0);
                },
              ),

              // =========================
              // RICE TAB
              // =========================
              drawerItem(
                icon: Icons.rice_bowl,
                title: "Rice Marketplace",

                onTap: () {
                  Navigator.pop(context);

                  // SWITCH TO RICE TAB
                  onTabSelected(1);
                },
              ),

              // =========================
              // SHOPS TAB
              // =========================
              drawerItem(
                icon: Icons.store,
                title: "Shops",

                onTap: () {
                  Navigator.pop(context);

                  // SWITCH TO SHOPS TAB
                  onTabSelected(2);
                },
              ),

              // =========================
              // CART PAGE
              // =========================
              drawerItem(
                icon: Icons.shopping_cart,
                title: "My Cart",

                onTap: () {
                  Navigator.pop(context);

                  // OPEN NEW PAGE
                  Get.toNamed(AppRoutes.cart);
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

                  // SWITCH TO PROFILE TAB
                  onTabSelected(4);
                },
              ),

              // =========================
              // ORDERS PAGE
              // =========================
              drawerItem(
                icon: Icons.shopping_bag,
                title: "My Orders",

                onTap: () {
                  Navigator.pop(context);

                  // OPEN NEW PAGE
                  Get.toNamed(AppRoutes.myOrders);
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

              // =========================
              // SETTINGS
              // =========================
              drawerItem(icon: Icons.settings, title: "Settings", onTap: () {}),

              // =========================
              // FEEDBACK
              // =========================
              drawerItem(icon: Icons.feedback, title: "Feedback", onTap: () {}),

              const SizedBox(height: 20),

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
        ),
      ),
    );
  }

  // =========================
  // DRAWER ITEM WIDGET
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
