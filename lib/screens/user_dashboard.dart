import 'package:flutter/material.dart';

void main() {
  runApp(const RiceMartApp());
}

class RiceMartApp extends StatelessWidget {
  const RiceMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rice Mart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto', useMaterial3: true),
      home: const UserDashboard(),
    );
  }
}

// ─── COLORS (exact figma) ───────────────────
const kDarkGreen = Color(0xFF2D4A27);
const kMidGreen  = Color(0xFF4A6741);
const kOlive     = Color(0xFF6B7C3E);
const kGoldOlive = Color(0xFF8A7A3A);
const kDrawerBg  = Color(0xFFEDE8D0);
const kLogoutRed = Color(0xFFB03A2E);
const kIconGrey  = Color(0xFF3A3A2E);

// ─── USER DASHBOARD ─────────────────────────
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = const [
    HomePage(), RicePage(), ShopsPage(), ChatPage(), ProfilePage(),
  ];

  final List<String> _titles = [
    'Marketplace', 'Rice', 'Shops', 'Chat', 'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,

      // ── AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 26),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600,
            fontSize: 20, letterSpacing: 0.4,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 26),
            onPressed: () {},
          ),
        ],
      ),

      drawer: _buildDrawer(context),
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ════════════════════════════════════════════
  //  DRAWER — exact figma
  // ════════════════════════════════════════════
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: kDrawerBg,
      child: Column(
        children: [
          // Dark green header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 22),
            color: kDarkGreen,
            child: Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(color: Colors.white30, width: 1.5),
                  ),
                  child: const Icon(Icons.person, size: 38, color: Colors.white70),
                ),
                const SizedBox(width: 14),
                const Text('User',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 6),
              children: [
                _drawerTile(Icons.home_outlined, 'Home', onTap: () {
                  setState(() => _currentIndex = 0); Navigator.pop(context);
                }),
                _drawerTile(Icons.storefront_outlined, 'Rice Marketplace', onTap: () {
                  setState(() => _currentIndex = 1); Navigator.pop(context);
                }),
                _drawerTile(Icons.store_outlined, 'Shops', onTap: () {
                  setState(() => _currentIndex = 2); Navigator.pop(context);
                }),
                _drawerTile(Icons.shopping_cart_outlined, 'My Cart', onTap: () {
                  Navigator.pop(context);
                }),
                _drawerTile(Icons.person_outline, 'Profile', onTap: () {
                  setState(() => _currentIndex = 4); Navigator.pop(context);
                }),
                _drawerTile(Icons.receipt_long_outlined, 'My Orders', onTap: () {
                  Navigator.pop(context);
                }),
                _drawerTile(Icons.notifications_outlined, 'Notifications', onTap: () {
                  Navigator.pop(context);
                }),
                _drawerTile(Icons.settings_outlined, 'Settings', onTap: () {
                  Navigator.pop(context);
                }),
                _drawerTile(Icons.feedback_outlined, 'Feedback', onTap: () {
                  Navigator.pop(context);
                }),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Divider(color: Color(0xFFCCC9A8), thickness: 1),
                ),
                _drawerTile(Icons.logout, 'Logout', color: kLogoutRed, onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String label,
      {required VoidCallback onTap, Color? color}) {
    final c = color ?? kIconGrey;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(label,
                style: TextStyle(
                  color: c, fontSize: 15,
                  fontWeight: color != null ? FontWeight.bold : FontWeight.w500,
                )),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kLogoutRed),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════
  //  BOTTOM NAV — exact figma: Home|Rice|Shops|Chat|Profile
  // ════════════════════════════════════════════
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded,               'label': 'Home'},
      {'icon': Icons.grain_rounded,              'label': 'Rice'},
      {'icon': Icons.store_rounded,              'label': 'Shops'},
      {'icon': Icons.chat_bubble_outline_rounded,'label': 'Chat'},
      {'icon': Icons.person_rounded,             'label': 'Profile'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _currentIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        color: selected ? kDarkGreen : Colors.grey,
                        size: 26,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                          color: selected ? kDarkGreen : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // active indicator dot
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 3,
                        width: selected ? 20 : 0,
                        decoration: BoxDecoration(
                          color: kDarkGreen,
                          borderRadius: BorderRadius.circular(4),
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

// ─── HOME PAGE ──────────────────────────────
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A6741), Color(0xFF6B7C3E), Color(0xFF8A7A3A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Text('Home',
          style: TextStyle(
            color: Colors.white, fontSize: 32,
            fontWeight: FontWeight.bold, letterSpacing: 1.0,
          )),
      ),
    );
  }
}

// ─── PLACEHOLDER PAGES ───────────────────────
class RicePage extends StatelessWidget {
  const RicePage({super.key});
  @override
  Widget build(BuildContext context) => _Placeholder(
      icon: Icons.grain_rounded, label: 'Rice Marketplace',
      colors: [kDarkGreen, kOlive]);
}

class ShopsPage extends StatelessWidget {
  const ShopsPage({super.key});
  @override
  Widget build(BuildContext context) => _Placeholder(
      icon: Icons.store_rounded, label: 'Shops',
      colors: [kOlive, kDarkGreen]);
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});
  @override
  Widget build(BuildContext context) => _Placeholder(
      icon: Icons.chat_bubble_rounded, label: 'Chat',
      colors: [kMidGreen, kOlive]);
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => _Placeholder(
      icon: Icons.person_rounded, label: 'Profile',
      colors: [kDarkGreen, kGoldOlive]);
}

class _Placeholder extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> colors;
  const _Placeholder({required this.icon, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors,
            begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.white30),
            const SizedBox(height: 14),
            Text(label, style: const TextStyle(color: Color.fromARGB(255, 177, 196, 181), fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Coming soon...', style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}