import 'package:flutter/material.dart';
import 'package:frontend/screens/buyer/profile/profile_screen.dart';

import 'package:frontend/screens/buyer/rice/all_rice_screen.dart';
import 'package:frontend/screens/buyer/shops/shops_screen.dart';

import '../../../core/utils/themes.dart';
import '../../../core/constants/app_icons.dart';

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

    // RICE MARKETPLACE
    const AllRiceScreen(),

    // SHOPS
    const ShopsScreen(),

    // CHAT
    Center(child: Text("Chat", style: AppTextStyles.heading2)),

    // PROFILE
    const ProfileScreen(),
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
