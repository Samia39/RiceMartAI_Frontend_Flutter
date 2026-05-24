import 'package:flutter/material.dart';
import 'package:frontend/screens/admin_screens/user_management/users_screen.dart';
import 'package:frontend/screens/admin_screens/user_management/roles_screen.dart';
import 'package:frontend/screens/admin_screens/user_management/assign_permissions_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../controllers/admin/user_management/permissions_controller.dart';
import '../core/utils/themes.dart';
import '../screens/admin_screens/shops/shop_approvals_screen.dart';
import '../screens/admin_screens/shops/approved_shops_screen.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    final userName = box.read("name") ?? "Admin";

    final userEmail = box.read("email") ?? "";

    return Drawer(
      backgroundColor: AppColors.cream,

      child: ListView(
        children: [
          // HEADER
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.darkGreen),

            accountName: Text(userName),

            accountEmail: Text(userEmail),

            currentAccountPicture: const CircleAvatar(
              backgroundColor: AppColors.cream,

              child: Icon(
                Icons.admin_panel_settings,
                size: 40,
                color: AppColors.darkGreen,
              ),
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

          // PENDING SHOPS
          drawerItem(
            icon: Icons.pending_actions,
            title: "Pending Shops",

            onTap: () {
              Navigator.pop(context);

              Get.to(() => const ShopApprovalsScreen());
            },
          ),

          // APPROVED SHOPS
          drawerItem(
            icon: Icons.verified,
            title: "Approved Shops",

            onTap: () {
              Navigator.pop(context);

              Get.to(() => const ApprovedShopsScreen());
            },
          ),

          // =========================
          // USER MANAGEMENT
          // =========================
          ExpansionTile(
            leading: const Icon(
              Icons.admin_panel_settings,
              color: AppColors.darkGreen,
            ),

            title: const Text(
              "User Management",
              style: TextStyle(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.w600,
              ),
            ),

            childrenPadding: const EdgeInsets.only(left: 20),

            children: [
              // USERS
              ListTile(
                leading: const Icon(Icons.people, color: AppColors.darkGreen),

                title: const Text("Users"),

                onTap: () {
                  Navigator.pop(context);

                  Get.to(() => UsersScreen());
                },
              ),

              // ROLES
              ListTile(
                leading: const Icon(Icons.badge, color: AppColors.darkGreen),

                title: const Text("Roles"),

                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => RolesScreen());
                },
              ),

              // ASSIGN PERMISSIONS
              // ASSIGN PERMISSIONS
              ListTile(
                leading: const Icon(
                  Icons.lock_open,
                  color: AppColors.darkGreen,
                ),

                title: const Text("Assign Permissions"),

                onTap: () {
                  Navigator.pop(context);

                  // REGISTER CONTROLLER ONLY ONCE
                  if (!Get.isRegistered<PermissionsController>()) {
                    Get.lazyPut<PermissionsController>(
                      () => PermissionsController(),
                      fenix: true,
                    );
                  }

                  Get.to(() => const AssignPermissionScreen());
                },
              ),
            ],
          ),
          // REPORTS
          drawerItem(icon: Icons.report, title: "Reports", onTap: () {}),

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
