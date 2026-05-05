import 'package:flutter/material.dart';
import 'package:frontend/screens/create_shop_screen.dart';
import '../core/utils/themes.dart';
import '../core/constants/app_icons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  final screens = [
    Center(child: Text("Home", style: AppTextStyles.heading2)),
    Center(child: Text("Shops", style: AppTextStyles.heading2)),
    CreateShopScreen(),
    Center(child: Text("Chat", style: AppTextStyles.heading2)),
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
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          selectedItemColor: AppColors.darkGreen,
          unselectedItemColor: AppColors.darkGreen.withOpacity(0.5),

          items: const [
            BottomNavigationBarItem(icon: Icon(AppIcons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(AppIcons.shops), label: "Shops"),
            BottomNavigationBarItem(icon: Icon(AppIcons.add), label: "Add"),
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
