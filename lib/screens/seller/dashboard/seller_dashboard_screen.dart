import 'package:flutter/material.dart';
import 'package:frontend/screens/chats/conversation.dart';
import 'package:get_storage/get_storage.dart';

import '../rice/add_rice_screen.dart';
import '../shop/my_shop_screen.dart';
import '../order/seller_orders_screen.dart';

import '../../../core/utils/themes.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/services/permission_service.dart';
import '../../../widgets/seller_drawer.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final shopStatus = box.read('shop_status');
    final hasShop = box.read('has_shop') ?? false;

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
    // SCREENS (PERMISSION BASED)
    // =========================
    final List<Widget> screens = [
      Center(child: Text("Seller Home", style: AppTextStyles.heading2)),

      // ADD RICE (permission required)
      PermissionService.hasPermission('create products')
          ? const AddRiceScreen()
          : const _NoAccess(),

      // MY SHOP (permission required)
      PermissionService.hasPermission('view shops')
          ? const MyShopScreen()
          : const _NoAccess(),

      ConversationsScreen(),
      // ORDERS (permission required)
      PermissionService.hasPermission('view orders')
          ? const SellerOrdersScreen()
          : const _NoAccess(),

      // PROFILE (always allowed)
      Center(child: Text("Profile", style: AppTextStyles.heading2)),
    ];

    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Seller Dashboard")),

        drawer: SellerDrawer(
          onTabSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),

        body: screens[currentIndex],

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },

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
