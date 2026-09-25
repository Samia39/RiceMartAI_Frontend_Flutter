import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/utils/themes.dart';
import '../routes/app_routes.dart';

class AppDrawer extends StatefulWidget {
  final Function(int) onTabSelected;

  const AppDrawer({super.key, required this.onTabSelected});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _box = GetStorage();
  VoidCallback? _storageUnsub;

  @override
  void initState() {
    super.initState();
    _storageUnsub = _box.listen(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _storageUnsub?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = _box.read("name") ?? "User";
    final userEmail = _box.read("email") ?? "";

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
                  widget.onTabSelected(0);
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
                  widget.onTabSelected(1);
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
                  widget.onTabSelected(2);
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
                  widget.onTabSelected(5);
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
                  widget.onTabSelected(3);
                },
              ),

              // =========================
              // COMPLAINTS PAGE
              // Converted from Get.to(() => ...) to a named route so
              // AuthMiddleware actually runs for it.
              // =========================
              drawerItem(
                icon: Icons.report_problem,
                title: "Complaints",
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.customerComplaints);
                },
              ),

              // =========================
              // NOTIFICATIONS
              // Converted from Get.to(() => ...) to a named route so
              // AuthMiddleware actually runs for it.
              // =========================
              drawerItem(
                icon: Icons.notifications,
                title: "Notifications",
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.notifications);
                },
              ),

              // =========================
              // LOGOUT
              // =========================
              drawerItem(
                icon: Icons.logout,
                title: "Logout",
                color: Colors.red,
                onTap: () {
                  _box.erase();
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
