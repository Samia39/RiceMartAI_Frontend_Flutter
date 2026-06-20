// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'rice_marketplace_page.dart';
import 'user/shops_screen.dart';
import 'user/profile_screen.dart';
import 'user/conversations_screen.dart';

// ─────────────────────────────────────────────
//  THEME
// ─────────────────────────────────────────────

class AppColors {
  AppColors._();
  static const Color darkGreen  = Color(0xFF1A2820);
  static const Color lightGreen = Color(0xFF5A8A6E);
  static const Color golden     = Color(0xFF9D7E3F);
  static const Color cream      = Color(0xFFD4C9A8);
  static const Color borderGold = Color(0xFFB8A97A);
  static const Color error      = Color(0xFFD32F2F);

  static Color cardFill      = cream.withOpacity(0.22);
  static Color cardBorder    = borderGold.withOpacity(0.45);
  static Color inputFill     = cream.withOpacity(0.30);
  static Color inputBorder   = borderGold.withOpacity(0.55);
  static Color overlayLight  = cream.withOpacity(0.30);
  static Color iconMuted     = darkGreen.withOpacity(0.75);
  static Color divider       = darkGreen.withOpacity(0.15);
}

class AppGradients {
  AppGradients._();
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.lightGreen, AppColors.golden],
  );
}

class AppTextStyles {
  AppTextStyles._();
  static const TextStyle heading3 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.bold,
    color: AppColors.darkGreen, letterSpacing: 0.3,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14, color: AppColors.darkGreen, height: 1.5,
  );
  static TextStyle bodySmall = TextStyle(
    fontSize: 12, color: AppColors.darkGreen.withOpacity(0.65), height: 1.4,
  );
  static TextStyle labelMuted = TextStyle(
    fontSize: 13, color: AppColors.darkGreen.withOpacity(0.75),
  );
}

// ─────────────────────────────────────────────
//  MAIN
// ─────────────────────────────────────────────
void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const RiceMartApp());
}

class RiceMartApp extends StatelessWidget {
  const RiceMartApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rice Mart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.light(
          primary: AppColors.darkGreen,
          secondary: AppColors.golden,
          surface: AppColors.cream,
        ),
        scaffoldBackgroundColor: AppColors.lightGreen,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.darkGreen),
          titleTextStyle: AppTextStyles.heading3,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
      ),
      home: const UserDashboard(),
    );
  }
}

// ─────────────────────────────────────────────
//  USER DASHBOARD
// ─────────────────────────────────────────────
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _titles = [
    'Marketplace', 'Rice', 'Shops', 'Chat', 'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const RicePage(),
      const ShopsPage(),
      const ChatPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        leading: GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cream.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderGold.withOpacity(0.50)),
            ),
            child: Icon(Icons.menu, color: AppColors.darkGreen, size: 20),
          ),
        ),
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cream.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderGold.withOpacity(0.50)),
              ),
              child: Icon(Icons.shopping_cart_outlined,
                  color: AppColors.darkGreen, size: 20),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: 285,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 22),
              decoration: BoxDecoration(
                color: AppColors.darkGreen.withOpacity(0.55),
                border: Border(
                  bottom: BorderSide(
                      color: AppColors.borderGold.withOpacity(0.40), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58, height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cream.withOpacity(0.20),
                      border: Border.all(
                          color: AppColors.borderGold.withOpacity(0.60),
                          width: 1.5),
                    ),
                    child: Icon(Icons.person, size: 36, color: AppColors.darkGreen),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.darkGreen,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          )),
                      Text('Marketplace User',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.darkGreen.withOpacity(0.65),
                            fontSize: 12,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _drawerTile(Icons.home_outlined, 'Home', onTap: () {
                    setState(() => _currentIndex = 0);
                    Navigator.pop(context);
                  }),
                  _drawerTile(Icons.storefront_outlined, 'Rice Marketplace',
                      onTap: () {
                    setState(() => _currentIndex = 1);
                    Navigator.pop(context);
                  }),
                  _drawerTile(Icons.store_outlined, 'Shops', onTap: () {
                    setState(() => _currentIndex = 2);
                    Navigator.pop(context);
                  }),
                  _drawerTile(Icons.chat_bubble_outline, 'Chat', onTap: () {
                    setState(() => _currentIndex = 3);
                    Navigator.pop(context);
                  }),
                  _drawerTile(Icons.shopping_cart_outlined, 'My Cart',
                      onTap: () => Navigator.pop(context)),
                  _drawerTile(Icons.person_outline, 'Profile', onTap: () {
                    setState(() => _currentIndex = 4);
                    Navigator.pop(context);
                  }),
                  _drawerTile(Icons.receipt_long_outlined, 'My Orders',
                      onTap: () => Navigator.pop(context)),
                  _drawerTile(Icons.notifications_outlined, 'Notifications',
                      onTap: () => Navigator.pop(context)),
                  _drawerTile(Icons.settings_outlined, 'Settings',
                      onTap: () => Navigator.pop(context)),
                  _drawerTile(Icons.feedback_outlined, 'Feedback',
                      onTap: () => Navigator.pop(context)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    child: Divider(
                        color: AppColors.borderGold.withOpacity(0.40),
                        thickness: 1),
                  ),
                  _drawerTile(Icons.logout, 'Logout',
                      color: AppColors.error, onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(IconData icon, String label,
      {required VoidCallback onTap, Color? color}) {
    final c = color ?? Colors.black;
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.cream.withOpacity(0.10),
      highlightColor: AppColors.cream.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.cream.withOpacity(color != null ? 0.08 : 0.12),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                    color: AppColors.borderGold.withOpacity(0.30), width: 1),
              ),
              child: Icon(icon, color: c, size: 18),
            ),
            const SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: c,
                  fontSize: 14,
                  fontWeight: color != null ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout',
            style: TextStyle(
                color: AppColors.darkGreen, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?',
            style: TextStyle(color: AppColors.darkGreen.withOpacity(0.75))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.darkGreen)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Logout',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded,                'label': 'Home'},
      {'icon': Icons.grain_rounded,               'label': 'Rice'},
      {'icon': Icons.store_rounded,               'label': 'Shops'},
      {'icon': Icons.chat_bubble_outline_rounded, 'label': 'Chat'},
      {'icon': Icons.person_rounded,              'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.golden.withOpacity(0.88),
        border: Border(
          top: BorderSide(
              color: AppColors.borderGold.withOpacity(0.50), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _currentIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 66,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 40, height: 36,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.darkGreen.withOpacity(0.20)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          items[i]['icon'] as IconData,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.5,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PAGES
// ─────────────────────────────────────────────

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.background),
      child: Center(
        child: Text('Home',
          style: TextStyle(
            fontFamily: 'Poppins', fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGreen, letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

class RicePage extends StatelessWidget {
  const RicePage({super.key});
  @override
  Widget build(BuildContext context) => const RiceMarketplacePage();
}

class ShopsPage extends StatelessWidget {
  const ShopsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight,
      ),
      child: const ShopsScreen(),
    );
  }
}

// ← CHAT PAGE — ConversationsScreen connect kiya
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5A8A6E), Color(0xFF9D7E3F)],
          ),
        ),
        child: const ConversationsScreen(),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + kToolbarHeight,
      ),
      child: const ProfileScreen(),
    );
  }
}