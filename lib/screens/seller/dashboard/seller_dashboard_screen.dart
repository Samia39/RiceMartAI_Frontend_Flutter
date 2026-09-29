import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'seller_home.dart';
import '../../chats/conversation.dart';
import 'package:get_storage/get_storage.dart';

import '../rice/add_rice_screen.dart';
import '../shop/my_shop_screen.dart';
import '../order/seller_orders_screen.dart';
import '../../buyer/profile/profile_screen.dart';
import '../../../core/utils/themes.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/services/admin/permission_service.dart';
import '../../../widgets/seller_drawer.dart';
import '../../../widgets/notification_bell.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int currentIndex = 0;
  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map && args['tabIndex'] is int) {
      currentIndex = args['tabIndex'] as int;
    }
  }

  // =========================
  // TAB SWITCH
  // =========================

  void _switchTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    final shopStatus = box.read('shop_status');

    // =========================
    // SHOP PENDING STATE
    // =========================
    if (shopStatus == 'pending') {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.hourglass_top, size: 80),
              SizedBox(height: 20),
              Text("Your shop is under review"),
              Text("Please wait for admin approval"),
            ],
          ),
        ),
      );
    }

    // =========================
    // SCREENS
    // =========================
    //

    final List<Widget> screens = [
      // =========================
      // DASHBOARD
      // =========================
      SellerHomeScreen(onTabChange: _switchTab),

      // =========================
      // MY RICE
      // =========================
      PermissionService.hasPermission('create products')
          ? const AddRiceScreen()
          : const _NoAccess(),

      // =========================
      // MY SHOP
      // =========================
      PermissionService.hasPermission('view own shop')
          ? const MyShopScreen()
          : const _NoAccess(),

      // =========================
      // CHAT
      // =========================
      ConversationsScreen(),

      // =========================
      // ORDERS
      // =========================
      PermissionService.hasPermission('view shop orders')
          ? const SellerOrdersScreen()
          : const _NoAccess(),

      // =========================
      // PROFILE
      // =========================
      const ProfileScreen(),
    ];

    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        // =========================
        // APP BAR
        // =========================
        appBar: AppBar(
          title: const Text("Seller Dashboard"),

          actions: const [
            // =========================
            // NOTIFICATIONS
            // =========================
            NotificationBell(iconColor: Colors.white, size: 24),
          ],
        ),

        // =========================
        // DRAWER
        // =========================
        drawer: SellerDrawer(onTabSelected: _switchTab),

        body: screens[currentIndex],

        // =========================
        // BOTTOM NAVIGATION
        // =========================
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,

          onTap: _switchTab,

          selectedItemColor: AppColors.darkGreen,

          unselectedItemColor: AppColors.darkGreen.withOpacity(0.5),

          type: BottomNavigationBarType.fixed,

          items: const [
            // HOME
            BottomNavigationBarItem(icon: Icon(AppIcons.home), label: "Home"),

            // RICE
            BottomNavigationBarItem(icon: Icon(Icons.rice_bowl), label: "Rice"),

            // MY SHOP
            BottomNavigationBarItem(icon: Icon(Icons.store), label: "My Shop"),

            // CHAT
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),

            // ORDERS
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: "Orders",
            ),

            // PROFILE
            BottomNavigationBarItem(
              icon: Icon(AppIcons.profile),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// NO ACCESS WIDGET
// =========================
class _NoAccess extends StatelessWidget {
  const _NoAccess();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "No Access",
        style: TextStyle(fontSize: 18, color: Colors.red),
      ),
    );
  }
}
