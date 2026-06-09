import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';
import '../controllers/admin/user_management/permissions_controller.dart';
import '../core/utils/themes.dart';

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

              Get.toNamed(AppRoutes.sellerApprovals);
            },
          ),

          // APPROVED SHOPS
          drawerItem(
            icon: Icons.verified,
            title: "Approved Shops",

            onTap: () {
              Navigator.pop(context);

              Get.toNamed(AppRoutes.approvedShops);
            },
          ),
          // Orders
          drawerItem(
            icon: Icons.shopping_bag,
            title: "Orders",

            onTap: () {
              Navigator.pop(context);

              Get.toNamed(AppRoutes.adminordersscreen);
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

                  Get.toNamed(AppRoutes.users);
                },
              ),

              // ROLES
              ListTile(
                leading: const Icon(Icons.badge, color: AppColors.darkGreen),

                title: const Text("Roles"),

                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.roles);
                },
              ),

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

                  Get.toNamed(AppRoutes.assignPermissions);
                },
              ),
            ],
          ),

          drawerItem(
            icon: Icons.pending_actions,
            title: "Payment Approvals",

            onTap: () {
              Navigator.pop(context);

              Get.toNamed(AppRoutes.paymentScreen);
            },
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
