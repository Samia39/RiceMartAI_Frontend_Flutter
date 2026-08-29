import 'package:flutter/material.dart';
import 'package:ricemart_ai/screens/seller/complaints/seller_complaint_list_screen.dart';
import 'package:ricemart_ai/screens/shared/notification_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/utils/themes.dart';
import '../routes/app_routes.dart';
import '../screens/seller/payout/SellerPayoutDetailsScreen.dart';
import '../screens/seller/payout/SellerPayoutsScreen.dart';

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
          // SCROLLABLE NAV ITEMS
          // (was a flat Column + Spacer(), which overflowed on
          // shorter screens — this scrolls instead)
          // =========================
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // DASHBOARD TAB
                drawerItem(
                  icon: Icons.dashboard,
                  title: "Dashboard",
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(0);
                  },
                ),

                // MY SHOP TAB
                drawerItem(
                  icon: Icons.store,
                  title: "My Shop",
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(2);
                  },
                ),

                // MY RICE TAB
                drawerItem(
                  icon: Icons.rice_bowl,
                  title: "My Rice",
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(1);
                  },
                ),

                // PAYOUT DETAILS
                drawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Payout Details",
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const SellerPayoutDetailsScreen());
                  },
                ),

                // PAYOUTS TAB (where the shop sees their payouts from admin)
                drawerItem(
                  icon: Icons.receipt_long,
                  title: "My Payouts",
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const SellerPayoutsScreen());
                  },
                ),

                // ORDERS TAB
                drawerItem(
                  icon: Icons.shopping_bag,
                  title: "Orders",
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(4);
                  },
                ),
                // COMPLAINTS TAB
                drawerItem(
                  icon: Icons.report_problem,
                  title: "Complaints",
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const SellerComplaintListScreen());
                  },
                ),

                // PROFILE TAB
                drawerItem(
                  icon: Icons.person,
                  title: "Profile",
                  onTap: () {
                    Navigator.pop(context);
                    onTabSelected(5);
                  },
                ),

                // NOTIFICATIONS
                drawerItem(
                  icon: Icons.notifications,
                  title: "Notifications",
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const NotificationsScreen());
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // =========================
          // LOGOUT — pinned at the bottom, always visible
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
