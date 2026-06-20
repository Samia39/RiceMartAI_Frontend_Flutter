// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/themes.dart';
import '../core/services/auth_service.dart';
import 'seller/seller_orders_screen.dart';
import 'seller/seller_shop_screen.dart';
import 'seller/seller_conversations_screen.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});
  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _titles = [
    'Seller Dashboard', 'My Rice', 'My Shop', 'Chat', 'Orders', 'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final user = AuthService.getCurrentUser();
    final pages = [
      const _HomePage(),
      const _RicePage(),
      const _MyShopPage(),
      _ChatPage(context: context), // ← Fix
      _OrdersPage(context: context),
      const _ProfilePage(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        title: Text(_titles[_currentIndex],
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            )),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cream.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderGold.withOpacity(0.50)),
            ),
            child: Icon(Icons.store_outlined,
                color: AppColors.darkGreen, size: 20),
          ),
        ],
      ),
      drawer: _buildDrawer(context, user),
      body: pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDrawer(BuildContext context, Map user) {
    return Drawer(
      width: 285,
      backgroundColor: Colors.transparent,
      child: Container(
        color: AppColors.cream,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 22),
              color: AppColors.darkGreen,
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cream.withOpacity(0.20),
                      border: Border.all(color: AppColors.borderGold, width: 2),
                    ),
                    child: Icon(Icons.storefront, color: AppColors.cream, size: 38),
                  ),
                  const SizedBox(height: 10),
                  Text(user['name'] ?? 'Seller',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.cream,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )),
                  Text('Seller',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.cream.withOpacity(0.70),
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerTile(Icons.dashboard_outlined, 'Dashboard', onTap: () {
                    setState(() => _currentIndex = 0);
                    Navigator.pop(context);
                  }),
                  _drawerTile(Icons.store_outlined, 'My Shop', onTap: () {
                    setState(() => _currentIndex = 2);
                    Navigator.pop(context);
                  }),
                  _drawerTile(Icons.rice_bowl_outlined, 'My Rice', onTap: () {
                    setState(() => _currentIndex = 1);
                    Navigator.pop(context);
                  }),
                  _drawerTile(Icons.chat_bubble_outline, 'Chat', onTap: () {
                    setState(() => _currentIndex = 3);
                    Navigator.pop(context);
                  }),
                  _drawerTile(Icons.shopping_bag_outlined, 'Orders', onTap: () {
                    setState(() => _currentIndex = 4);
                    Navigator.pop(context);
                  }),
                  _drawerTile(Icons.notifications_outlined, 'Notifications',
                      onTap: () => Navigator.pop(context)),
                  _drawerTile(Icons.settings_outlined, 'Settings',
                      onTap: () => Navigator.pop(context)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () async {
                  await AuthService.logout();
                  Get.offAllNamed('/login');
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.30)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.error, size: 22),
                      const SizedBox(width: 12),
                      Text('Logout',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.error,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(IconData icon, String label, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkGreen, size: 22),
      title: Text(label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.darkGreen,
          )),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded,               'label': 'Home'},
      {'icon': Icons.rice_bowl_rounded,          'label': 'Rice'},
      {'icon': Icons.store_rounded,              'label': 'My Shop'},
      {'icon': Icons.chat_bubble_outline_rounded,'label': 'Chat'},
      {'icon': Icons.shopping_bag_rounded,       'label': 'Orders'},
      {'icon': Icons.person_rounded,             'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.golden.withOpacity(0.88),
        border: Border(
          top: BorderSide(color: AppColors.borderGold.withOpacity(0.50), width: 1),
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
                  width: 58,
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
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9.5,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
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

// ── Pages ─────────────────────────────────────────────────────────

class _HomePage extends StatelessWidget {
  const _HomePage();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: const Center(
        child: Text('Welcome',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
              letterSpacing: 1.0,
            )),
      ),
    );
  }
}

class _RicePage extends StatelessWidget {
  const _RicePage();
  @override
  Widget build(BuildContext context) => Container(
        decoration: AppDecorations.gradientBackground,
      );
}

class _MyShopPage extends StatelessWidget {
  const _MyShopPage();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight,
        ),
        child: const SellerShopScreen(),
      ),
    );
  }
}

// ← FIX — SellerConversationsScreen connect kiya
class _ChatPage extends StatelessWidget {
  final BuildContext context;
  const _ChatPage({required this.context});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight,
        ),
        child: const SellerConversationsScreen(),
      ),
    );
  }
}

class _OrdersPage extends StatelessWidget {
  final BuildContext context;
  const _OrdersPage({required this.context});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight,
        ),
        child: const SellerOrdersScreen(),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();
  @override
  Widget build(BuildContext context) => Container(
        decoration: AppDecorations.gradientBackground,
      );
}