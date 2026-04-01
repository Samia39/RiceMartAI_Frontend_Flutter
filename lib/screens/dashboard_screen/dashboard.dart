// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_repo/screens/dashboard_screen/admin%20screen/admin_screen.dart';

import 'add_shops.dart';
import 'create_shops.dart';
import 'profile_screen.dart';
import './ai screen/ai_suggestion.dart';
import 'ai screen/ai_detection.dart';

// ─────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────
class RicePrice {
  final String name;
  final double price;
  final double change;

  RicePrice({required this.name, required this.price, required this.change});

  factory RicePrice.fromJson(Map<String, dynamic> json) {
    return RicePrice(
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
    );
  }

  static List<RicePrice> fallback() => [
    RicePrice(name: 'Basmati Rice', price: 280, change: 5),
    RicePrice(name: 'Super Basmati', price: 320, change: 3),
    RicePrice(name: 'Sella Rice', price: 250, change: -2),
    RicePrice(name: 'Brown Rice', price: 200, change: 1),
    RicePrice(name: 'Kainat Rice', price: 265, change: 2),
    RicePrice(name: 'Supri Rice', price: 185, change: 0),
    RicePrice(name: 'IR-6 Rice', price: 150, change: -1),
    RicePrice(name: 'Kernel Basmati', price: 295, change: 4),
  ];
}

// ─────────────────────────────────────────────
//  PRICE API SERVICE
// ─────────────────────────────────────────────
class RicePriceService {
  static const String _baseUrl =
      'https://your-api-endpoint.com/api/rice-prices';

  static Future<List<RicePrice>> fetchPrices() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => RicePrice.fromJson(e)).toList();
      }
      return RicePrice.fallback();
    } catch (_) {
      return RicePrice.fallback();
    }
  }
}

// ─────────────────────────────────────────────
//  PRODUCT MODEL
// ─────────────────────────────────────────────
class RiceProduct {
  final String name, shop, imagePath;
  final double price;

  RiceProduct({
    required this.name,
    required this.shop,
    required this.price,
    required this.imagePath,
  });

  // FIX: image paths match exactly what's declared in pubspec.yaml assets
  static List<RiceProduct> samples() => [
    RiceProduct(
      name: 'Basmati Rice',
      shop: 'Anware Sidra Rice Shop',
      price: 280,
      imagePath: 'assets/images/rice.jpeg',
    ),
    RiceProduct(
      name: 'Super Basmati',
      shop: 'Anware Sidra Rice Shop',
      price: 320,
      imagePath: 'assets/images/rice.jpeg',
    ),
    RiceProduct(
      name: 'Sella Rice',
      shop: 'Anware Sidra Rice Shop',
      price: 250,
      imagePath: 'assets/images/rice.jpeg',
    ),
    RiceProduct(
      name: 'Kainat Rice',
      shop: 'Anware Sidra Rice Shop',
      price: 265,
      imagePath: 'assets/images/rice.jpeg',
    ),
    RiceProduct(
      name: 'Brown Rice',
      shop: 'Anware Sidra Rice Shop',
      price: 200,
      imagePath: 'assets/images/rice.jpeg',
    ),
  ];
}

// ─────────────────────────────────────────────
//  DASHBOARD SCREEN
// ─────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final GetStorage _box = GetStorage();

  List<RicePrice> _prices = [];
  bool _loadingPrices = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Color _darkGreen = Color(0xFF1A2820);
  static const Color _lightGreen = Color(0xFF5A8A6E);
  static const Color _golden = Color(0xFF9D7E3F);

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    setState(() => _loadingPrices = true);
    final prices = await RicePriceService.fetchPrices();
    setState(() {
      _prices = prices;
      _loadingPrices = false;
    });
  }

  List<Widget> get _pages => [
    _HomeContent(
      prices: _prices,
      loadingPrices: _loadingPrices,
      searchController: _searchController,
      searchQuery: _searchQuery,
      onSearchChanged: (v) => setState(() => _searchQuery = v),
      onRefresh: _loadPrices,
      userName: _box.read('userName') ?? 'User',
    ),
    const ShopsScreen(),
    const CreateScreen(),
    const ProfileScreen(),
    AdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_lightGreen, _golden],
          ),
        ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────
//  BOTTOM NAVIGATION BAR  ← RESPONSIVE FIX
// ─────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const Color _darkGreen = Color(0xFF1A2820);
  static const Color _lightGreen = Color(0xFF5A8A6E);
  static const Color _golden = Color(0xFF9D7E3F);
  static const Color _cream = Color(0xFFD4C9A8);

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // FIX: use MediaQuery for responsive sizing instead of hardcoded values
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = (screenWidth * 0.055).clamp(18.0, 26.0);
    final fontSize = (screenWidth * 0.028).clamp(9.0, 13.0);
    final centerBtnSize = (screenWidth * 0.095).clamp(34.0, 46.0);

    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      _NavItem(
        icon: Icons.storefront_outlined,
        activeIcon: Icons.storefront,
        label: 'Shops',
      ),
      _NavItem(
        icon: Icons.add_circle_outline,
        activeIcon: Icons.add_circle,
        label: 'Create',
        isCenter: true,
      ),
      _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
      ),
      _NavItem(
        icon: Icons.shield_outlined,
        activeIcon: Icons.shield,
        label: 'Admin',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_lightGreen, _golden],
        ),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      // FIX: SafeArea wraps the inner content so bottom padding is handled
      // correctly on notched devices (iPhone, Android gesture nav)
      child: SafeArea(
        top: false,
        child: Padding(
          // FIX: vertical padding scales with screen so items never get clipped
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.008,
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (item.isCenter)
                          // FIX: center button size is now responsive
                          Container(
                            width: centerBtnSize,
                            height: centerBtnSize,
                            decoration: BoxDecoration(
                              color: selected
                                  ? _cream
                                  : _cream.withOpacity(0.30),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _cream.withOpacity(0.7),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              selected ? item.activeIcon : item.icon,
                              color: selected
                                  ? _darkGreen
                                  : _darkGreen.withOpacity(0.75),
                              size: iconSize,
                            ),
                          )
                        else
                          Icon(
                            selected ? item.activeIcon : item.icon,
                            color: selected
                                ? _cream
                                : _darkGreen.withOpacity(0.8),
                            size: iconSize,
                          ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected
                                ? _cream
                                : _darkGreen.withOpacity(0.8),
                            letterSpacing: 0.2,
                          ),
                          // FIX: prevent label overflow on narrow screens
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
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

class _NavItem {
  final IconData icon, activeIcon;
  final String label;
  final bool isCenter;
  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isCenter = false,
  });
}

// ─────────────────────────────────────────────
//  HOME CONTENT
// ─────────────────────────────────────────────
class _HomeContent extends StatelessWidget {
  final List<RicePrice> prices;
  final bool loadingPrices;
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;
  final String userName;

  static const Color _darkGreen = Color(0xFF1A2820);
  static const Color _lightGreen = Color(0xFF5A8A6E);
  static const Color _golden = Color(0xFF9D7E3F);
  static const Color _cream = Color(0xFFD4C9A8);
  static const Color _border = Color(0xFFB8A97A);

  const _HomeContent({
    required this.prices,
    required this.loadingPrices,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.userName,
  });

  List<RicePrice> get _filtered => prices
      .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    // FIX: responsive sizing for hero banner and product cards
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerHeight = (screenWidth * 0.42).clamp(130.0, 200.0);
    final cardWidth = (screenWidth * 0.38).clamp(130.0, 170.0);
    final cardImageHeight = (cardWidth * 0.65).clamp(80.0, 110.0);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        color: _golden,
        backgroundColor: _cream,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Bar ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rice Mart',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _darkGreen,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          'Hello, $userName 👋',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _darkGreen.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _cream.withOpacity(0.30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _border.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.language,
                            size: 15,
                            color: _darkGreen,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'اردو',
                            style: TextStyle(
                              color: _darkGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Hero Banner ── FIX: responsive height + asset image ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: bannerHeight,
                        width: double.infinity,
                        // FIX: AssetImage with proper cacheWidth for performance;
                        // errorBuilder shows gradient fallback if asset is missing
                        child: Image.asset(
                          'assets/images/home_screen.jpeg',
                          fit: BoxFit.cover,
                          // cacheWidth helps Flutter decode at the right resolution
                          cacheWidth:
                              (screenWidth *
                                      MediaQuery.of(context).devicePixelRatio)
                                  .round(),
                          errorBuilder: (_, error, __) {
                            // Only shown if asset is genuinely missing from pubspec.yaml
                            return Container(
                              height: bannerHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _lightGreen.withOpacity(0.8),
                                    _golden.withOpacity(0.8),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.grain,
                                  size: 64,
                                  color: Colors.white54,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        height: bannerHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.transparent,
                              _darkGreen.withOpacity(0.65),
                            ],
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 18,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Premium Quality Rice',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Discover the finest rice varieties',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Search ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: _cream.withOpacity(0.30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border.withOpacity(0.55)),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    style: const TextStyle(color: _darkGreen, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search for rice varieties, shops...',
                      hintStyle: TextStyle(
                        color: _darkGreen.withOpacity(0.55),
                        fontSize: 13.5,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: _darkGreen.withOpacity(0.75),
                        size: 20,
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                searchController.clear();
                                onSearchChanged('');
                              },
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: _darkGreen.withOpacity(0.6),
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── AI Buttons ─────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    _AiFeatureButton(
                      icon: Icons.camera_alt_outlined,
                      title: 'AI Detection & Suggestion',
                      subtitle: 'Analyze rice quality',
                      onTap: () => Get.to(
                        () => const AiDetectionScreen(),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _AiFeatureButton(
                      icon: Icons.auto_awesome_outlined,
                      title: 'AI Recommendation',
                      subtitle: 'Rice for recipes',
                      onTap: () => Get.to(
                        () => const AiRecommendationScreen(),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Real-Time Prices ───────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, size: 18, color: _darkGreen),
                    const SizedBox(width: 6),
                    const Text(
                      'Real-Time Rice Prices',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _darkGreen,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onRefresh,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _cream.withOpacity(0.30),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _border.withOpacity(0.5)),
                        ),
                        child: Icon(
                          Icons.refresh,
                          size: 16,
                          color: _darkGreen.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: _cream.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border.withOpacity(0.4)),
                  ),
                  child: loadingPrices
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF9D7E3F),
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: _darkGreen.withOpacity(0.15),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      'Rice Name',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: _darkGreen,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Price (Rs/kg)',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: _darkGreen,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Change',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: _darkGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ..._filtered.asMap().entries.map(
                              (e) => _PriceRow(
                                rice: e.value,
                                isLast: e.key == _filtered.length - 1,
                              ),
                            ),
                            if (_filtered.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'No results found',
                                  style: TextStyle(
                                    color: _darkGreen.withOpacity(0.6),
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 22),

              // ── Products ── FIX: responsive card width & image height ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 18,
                      color: _darkGreen,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Products',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _darkGreen,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: _darkGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                          decoration: TextDecoration.underline,
                          decorationColor: _darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                // FIX: image + name(18) + shop(16) + price(18) + paddings(~30) + shadow(4)
                height: cardImageHeight + 104,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 18, right: 8),
                  itemCount: RiceProduct.samples().length,
                  itemBuilder: (context, i) => _ProductCard(
                    product: RiceProduct.samples()[i],
                    cardWidth: cardWidth,
                    imageHeight: cardImageHeight,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  REUSABLE WIDGETS
// ─────────────────────────────────────────────
class _AiFeatureButton extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  static const Color _darkGreen = Color(0xFF1A2820);
  static const Color _cream = Color(0xFFD4C9A8);
  static const Color _border = Color(0xFFB8A97A);

  const _AiFeatureButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: _cream.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _cream.withOpacity(0.30),
                shape: BoxShape.circle,
                border: Border.all(color: _border.withOpacity(0.5)),
              ),
              child: Icon(icon, size: 20, color: _darkGreen),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _darkGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _darkGreen.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: _darkGreen.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final RicePrice rice;
  final bool isLast;
  static const Color _darkGreen = Color(0xFF1A2820);
  static const Color _border = Color(0xFFB8A97A);

  const _PriceRow({required this.rice, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isPositive = rice.change > 0;
    final isNeutral = rice.change == 0;
    final changeColor = isNeutral
        ? _darkGreen.withOpacity(0.55)
        : isPositive
        ? const Color(0xFF2E7D32)
        : const Color(0xFFC62828);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: _border.withOpacity(0.25), width: 1),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              rice.name,
              style: const TextStyle(
                fontSize: 13,
                color: _darkGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'Rs ${rice.price.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 13, color: _darkGreen),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              isNeutral
                  ? '0%'
                  : '${isPositive ? '+' : ''}${rice.change.toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: changeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// FIX: _ProductCard now accepts responsive cardWidth and imageHeight
class _ProductCard extends StatelessWidget {
  final RiceProduct product;
  final double cardWidth;
  final double imageHeight;

  static const Color _darkGreen = Color(0xFF1A2820);
  static const Color _cream = Color(0xFFD4C9A8);
  static const Color _border = Color(0xFFB8A97A);

  const _ProductCard({
    required this.product,
    required this.cardWidth,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 12, bottom: 4),
      decoration: BoxDecoration(
        color: _cream.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            child: SizedBox(
              height: imageHeight,
              width: double.infinity,
              // FIX: Image.asset with errorBuilder; asset must be in pubspec.yaml
              child: Image.asset(
                product.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: _cream.withOpacity(0.4),
                  child: const Center(
                    child: Icon(Icons.grain, size: 36, color: Colors.white54),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _darkGreen,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  product.shop,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: _darkGreen.withOpacity(0.65),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  'Rs ${product.price.toStringAsFixed(0)}/kg',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
