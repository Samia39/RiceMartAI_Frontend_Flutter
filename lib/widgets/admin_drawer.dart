import 'package:flutter/material.dart';
import 'package:frontend/screens/admin_screens/courier_management/courier_charge_screen.dart';
import 'package:frontend/screens/admin_screens/payout/admin_payouts_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';
import '../controllers/admin/user_management/permissions_controller.dart';
import '../core/utils/themes.dart';
import '../screens/admin_screens/courier_management/city_screen.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final userName = box.read("name") ?? "Admin";
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
              child: Icon(
                Icons.admin_panel_settings,
                size: 40,
                color: AppColors.darkGreen,
              ),
            ),
          ),

          // SCROLLABLE MENU ITEMS
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
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

                // ORDERS
                drawerItem(
                  icon: Icons.shopping_bag,
                  title: "Orders",
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.adminordersscreen);
                  },
                ),

                // USER MANAGEMENT
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
                      leading: const Icon(
                        Icons.people,
                        color: AppColors.darkGreen,
                      ),
                      title: const Text("Users"),
                      onTap: () {
                        Navigator.pop(context);
                        Get.toNamed(AppRoutes.users);
                      },
                    ),

                    // ROLES
                    ListTile(
                      leading: const Icon(
                        Icons.badge,
                        color: AppColors.darkGreen,
                      ),
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

                // COURIER MaNAGEMENT
                ExpansionTile(
                  leading: const Icon(
                    Icons.local_shipping,
                    color: AppColors.darkGreen,
                  ),
                  title: const Text(
                    "Courier Management",
                    style: TextStyle(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.only(left: 20),
                  children: [
                    //city screen
                    ListTile(
                      leading: const Icon(
                        Icons.location_city,
                        color: AppColors.darkGreen,
                      ),
                      title: const Text("Cities"),
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => const CityScreen());
                      },
                    ),
                    // COURIER CHARGES
                    ListTile(
                      leading: const Icon(
                        Icons.attach_money,
                        color: AppColors.darkGreen,
                      ),
                      title: const Text("Courier Charges"),
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => const CourierChargeScreen());
                      },
                    ),
                  ],
                ),

                // PAYMENT APPROVALS
                drawerItem(
                  icon: Icons.pending_actions,
                  title: "Payment Approvals",
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.paymentScreen);
                  },
                ),
                // PAYMENT SETTINGS
                drawerItem(
                  icon: Icons.payment,
                  title: "Payment Settings",
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.adminPaymentSettings);
                  },
                ),

                // SELLER PAYOUTS
                drawerItem(
                  icon: Icons.account_balance_wallet,
                  title: "Seller Payouts",
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const AdminPayoutsScreen());
                  },
                ),

                // REPORTS
                drawerItem(
                  icon: Icons.report,
                  title: "Reports",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                // SETTINGS → navigates to profile.dart
                drawerItem(
                  icon: Icons.settings,
                  title: "Settings",
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.profile);
                  },
                ),
              ],
            ),
          ),

          // LOGOUT - always visible at bottom
          const Divider(height: 1),
          drawerItem(
            icon: Icons.logout,
            title: "Logout",
            color: Colors.red,
            onTap: () {
              GetStorage().erase();
              Get.offAllNamed("/login");
            },
          ),
          const SizedBox(height: 20),
        ],
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
