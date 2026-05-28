import 'package:flutter/material.dart';
import 'package:frontend/screens/seller/order/seller_orders_screen.dart';
import 'package:get_storage/get_storage.dart';

import '../rice/add_rice_screen.dart';
import '../shop/create_shop_screen.dart';
import '../shop/my_shop_screen.dart';

import '../../../core/utils/themes.dart';
import '../../../core/constants/app_icons.dart';
import '../../../widgets/seller_drawer.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  bool hasShop = false;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    loadSellerData();
  }

  void loadSellerData() {
    final box = GetStorage();

    hasShop = box.read("has_shop") ?? false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // NO SHOP
    if (!hasShop) {
      return const CreateShopScreen();
    }

    // SELLER SCREENS
    final List<Widget> screens = [
      // HOME
      Center(child: Text("Seller Home", style: AppTextStyles.heading2)),

      // RICE
      const AddRiceScreen(),

      // MY SHOP
      const MyShopScreen(),

      // ORDERS
      const SellerOrdersScreen(),

      // PROFILE
      Center(child: Text("Profile", style: AppTextStyles.heading2)),
    ];

    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Seller Dashboard")),
        // Drawer
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
