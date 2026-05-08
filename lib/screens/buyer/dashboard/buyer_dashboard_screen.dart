import 'package:flutter/material.dart';

import '../../../core/utils/themes.dart';
import '../../../core/constants/app_icons.dart';

// SELLER SCREEN
import '../../seller/dashboard/seller_dashboard_screen.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    // HOME
    Center(child: Text("Home", style: AppTextStyles.heading2)),

    // SHOPS
    Center(child: Text("Shops", style: AppTextStyles.heading2)),

    // BECOME SELLER / CREATE SHOP
    const SellerDashboardScreen(),

    // CHAT
    Center(child: Text("Chat", style: AppTextStyles.heading2)),

    // PROFILE
    Center(child: Text("Profile", style: AppTextStyles.heading2)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: screens[currentIndex],

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

            BottomNavigationBarItem(icon: Icon(AppIcons.shops), label: "Shops"),

            BottomNavigationBarItem(icon: Icon(AppIcons.add), label: "Sell"),

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
