import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ricemart_ai/controllers/auth_controller.dart';

import '../core/utils/themes.dart';
import '../routes/app_routes.dart';

class SellerDrawer extends StatefulWidget {
  final Function(int) onTabSelected;

  const SellerDrawer({super.key, required this.onTabSelected});

  @override
  State<SellerDrawer> createState() => _SellerDrawerState();
}

class _SellerDrawerState extends State<SellerDrawer> {
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
    final userName = _box.read("name") ?? "Seller";
    final userEmail = _box.read("email") ?? "";

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
                    widget.onTabSelected(0);
                  },
                ),

                // MY SHOP TAB
                drawerItem(
                  icon: Icons.store,
                  title: "My Shop",
                  onTap: () {
                    Navigator.pop(context);
                    widget.onTabSelected(2);
                  },
                ),

                // MY RICE TAB
                drawerItem(
                  icon: Icons.rice_bowl,
                  title: "My Rice",
                  onTap: () {
                    Navigator.pop(context);
                    widget.onTabSelected(1);
                  },
                ),

                // PAYOUT DETAILS
                drawerItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Payout Details",
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.sellerPayoutDetails);
                  },
                ),

                // PAYOUTS TAB
                drawerItem(
                  icon: Icons.receipt_long,
                  title: "My Payouts",
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.sellerPayouts);
                  },
                ),

                // ORDERS TAB
                drawerItem(
                  icon: Icons.shopping_bag,
                  title: "Orders",
                  onTap: () {
                    Navigator.pop(context);
                    widget.onTabSelected(4);
                  },
                ),

                // COMPLAINTS TAB
                drawerItem(
                  icon: Icons.report_problem,
                  title: "Complaints",
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.sellerComplaints);
                  },
                ),

                // PROFILE TAB
                drawerItem(
                  icon: Icons.person,
                  title: "Profile",
                  onTap: () {
                    Navigator.pop(context);
                    widget.onTabSelected(5);
                  },
                ),

                // NOTIFICATIONS
                drawerItem(
                  icon: Icons.notifications,
                  title: "Notifications",
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.notifications);
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // LOGOUT
          drawerItem(
            icon: Icons.logout,
            title: "Logout",
            color: Colors.red,
            onTap: () async {
              await Get.find<AuthController>().logout();
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // DRAWER ITEM

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
