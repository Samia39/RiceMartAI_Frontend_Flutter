import 'package:flutter/material.dart';
import '../../chats/conversation.dart';
import '../../../routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../profile/profile_screen.dart';
import '../rice/all_rice_screen.dart';
import '../shops/shops_screen.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/utils/themes.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/notification_bell.dart';
import '../home/home_screen.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  final box = GetStorage();
  final CartService cartService = Get.find<CartService>();
  int currentIndex = 0;
  String riceSearchQuery = '';

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      if (args['tabIndex'] is int) {
        currentIndex = args['tabIndex'] as int;
      }
      if (args['riceSearchQuery'] is String) {
        riceSearchQuery = args['riceSearchQuery'] as String;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onSeeAllProducts: () {
          setState(() {
            riceSearchQuery = ''; // no filter — show everything
            currentIndex = 1; // Rice tab index
          });
        },
      ),

      AllRiceScreen(
        key: ValueKey(riceSearchQuery), // rebuild state when query changes
        onCartUpdated: () {
          setState(() {});
        },
        initialSearchQuery: riceSearchQuery,
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
            // =========================
            // NOTIFICATIONS
            // =========================
            const NotificationBell(iconColor: Colors.white, size: 24),

            // CART ICON
            Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.cart);
                  },
                  icon: const Icon(Icons.shopping_cart),
                ),

                Obx(() {
                  final count = cartService.cart.length;
                  if (count == 0) return const SizedBox.shrink();

                  return Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
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
