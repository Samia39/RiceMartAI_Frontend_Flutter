import 'package:flutter/material.dart';
import 'package:frontend/screens/chats/conversation.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/screens/buyer/profile/profile_screen.dart';
import 'package:frontend/screens/buyer/rice/all_rice_screen.dart';
import 'package:frontend/screens/buyer/shops/shops_screen.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/utils/themes.dart';
import '../../../widgets/app_drawer.dart';
import '../home/home_screen.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  final box = GetStorage();
  final CartService cartService = CartService();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),

      AllRiceScreen(
        onCartUpdated: () {
          setState(() {});
        },
      ),

      const ShopsScreen(),

      ConversationsScreen(),

      const ProfileScreen(),
    ];
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        // APP BAR
        appBar: AppBar(
          title: const Text("Marketplace"),

          actions: [
            // CART ICON
            Stack(
              children: [
                IconButton(
                  onPressed: () async {
                    await Get.toNamed(AppRoutes.cart);

                    setState(() {});
                  },

                  icon: const Icon(Icons.shopping_cart),
                ),

                if (cartService.getCart().isNotEmpty)
                  Positioned(
                    right: 5,
                    top: 5,

                    child: Container(
                      padding: const EdgeInsets.all(5),

                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),

                      child: Text(
                        cartService.getCart().length.toString(),

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // DRAWER
        drawer: AppDrawer(
          onTabSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),

        // BODY
        body: screens[currentIndex],

        // BOTTOM NAVIGATION
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.cream,

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

            BottomNavigationBarItem(icon: Icon(AppIcons.rice), label: "Rice"),

            BottomNavigationBarItem(icon: Icon(AppIcons.shops), label: "Shops"),

            BottomNavigationBarItem(icon: Icon(AppIcons.chat), label: "Chat"),

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
