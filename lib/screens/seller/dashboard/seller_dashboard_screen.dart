import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'seller_home.dart';
import '../../chats/conversation.dart';
import 'package:get_storage/get_storage.dart';

import '../rice/add_rice_screen.dart';
import '../shop/my_shop_screen.dart';
import '../order/seller_orders_screen.dart';
import 'package:ricemart_ai/screens/buyer/profile/profile_screen.dart';
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

  void _switchTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    final shopStatus = box.read('shop_status');

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

    final List<Widget> screens = [
      SellerHomeScreen(onTabChange: _switchTab),

      PermissionService.hasPermission('create products')
          ? const AddRiceScreen()
          : const _NoAccess(),

      PermissionService.hasPermission('view own shop')
          ? const MyShopScreen()
          : const _NoAccess(),

      ConversationsScreen(),

      PermissionService.hasPermission('view shop orders')
          ? const SellerOrdersScreen()
          : const _NoAccess(),

      const ProfileScreen(),
    ];

    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text("Seller Dashboard"),

          actions: const [NotificationBell(iconColor: Colors.white, size: 24)],
        ),

        drawer: SellerDrawer(onTabSelected: _switchTab),

        body: screens[currentIndex],

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,

          onTap: _switchTab,

          selectedItemColor: AppColors.darkGreen,

          unselectedItemColor: AppColors.darkGreen.withOpacity(0.5),

          type: BottomNavigationBarType.fixed,

          items: const [
            BottomNavigationBarItem(icon: Icon(AppIcons.home), label: "Home"),

            BottomNavigationBarItem(icon: Icon(Icons.rice_bowl), label: "Rice"),

            BottomNavigationBarItem(icon: Icon(Icons.store), label: "My Shop"),

            BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),

            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: "Orders",
            ),

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
