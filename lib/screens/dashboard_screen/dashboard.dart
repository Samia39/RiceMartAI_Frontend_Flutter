// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '/core/services/dashboard_service.dart';
import '/core/services/shop_service.dart';
import '/core/utils/themes.dart';
import '/routes/app_routes.dart';

import 'my_shop.dart';
import 'create_shops.dart';
import 'profile screen/profile_screen.dart';
import 'admin screen/admin_screen.dart';
import 'ai screen/ai_detection.dart';
import 'ai screen/ai_suggestion.dart';
import 'cart_screen.dart';
import 'chat_screen.dart';
import 'package:flutter_repo/screens/dashboard_screen/shops_screen.dart';

// ─────────────────────────────────────────────
//  DASHBOARD SCREEN  (tab host)
// ─────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GetStorage _box = GetStorage();
  int _tab = 0;

  bool _hasShop = false;

  final CartController _cart = Get.put(CartController());
  final AdminPriceController _adminPrices = Get.put(AdminPriceController());

  List<RicePrice> _prices = [];
  bool _loadingPrices = true;

  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> _apiShops = [];
  bool _loadingApiShops = true;
  String _shopsError = '';

  @override
  void initState() {
    super.initState();
    _hasShop = _box.read('has_shop') == true;
    _loadPrices();
    _loadApiShops();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPrices() async {
    setState(() => _loadingPrices = true);
    final p = await RicePriceService.fetchPrices();
    if (mounted) {
      setState(() {
        _prices = p;
        _loadingPrices = false;
      });
    }
  }

  Future<void> _loadApiShops() async {
    if (!mounted) return;
    setState(() {
      _loadingApiShops = true;
      _shopsError = '';
    });

    final result = await ShopService.getAllShops();

    if (!mounted) return;

    if (result['success'] == true) {
      final raw = result['shops'];
      final shops = raw is List
          ? raw.map((e) => Map<String, dynamic>.from(e as Map)).toList()
          : <Map<String, dynamic>>[];
      setState(() {
        _apiShops = shops;
        _loadingApiShops = false;
        _shopsError = '';
      });
    } else {
      setState(() {
        _apiShops = [];
        _loadingApiShops = false;
        _shopsError = result['message'] ?? 'Failed to load shops';
      });
      Get.snackbar(
        'Shops Error',
        _shopsError,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.red.withOpacity(0.85),
        colorText: Colors.white,
      );
    }
  }

  void _onShopCreated() {
    _box.write('has_shop', true);
    if (!mounted) return;
    setState(() {
      _hasShop = true;
      _tab = 1;
    });
    _loadApiShops();
  }

  void _onShopDeleted() {
    _box.remove('has_shop');
    if (!mounted) return;
    setState(() {
      _hasShop = false;
      _tab = 0;
    });
    _loadApiShops();
  }

  // ── 5 pages now (Home · My Shop/Create · Shops · Profile · Admin) ──
  List<Widget> get _pages {
    final home = _HomeTab(
      prices: _prices,
      loadingPrices: _loadingPrices,
      searchCtrl: _searchCtrl,
      searchQuery: _searchQuery,
      onSearch: (v) => setState(() => _searchQuery = v),
      onRefresh: () {
        _loadPrices();
        _loadApiShops();
      },
      cart: _cart,
      apiShops: _apiShops,
      loadingApiShops: _loadingApiShops,
      shopsError: _shopsError,
    );

    if (_hasShop) {
      return [
        home,
        MyShopScreen(onShopDeleted: _onShopDeleted),
        ShopsScreen(), // ← NEW
        ProfileScreen(),
        AdminScreen(),
      ];
    } else {
      return [
        home,
        CreateShopScreen(onShopCreated: _onShopCreated),
        ShopsScreen(), // ← NEW
        ProfileScreen(),
        AdminScreen(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: AppDecorations.gradientBackground,
      child: _pages[_tab],
    ),
    bottomNavigationBar: _BottomNav(
      current: _tab,
      hasShop: _hasShop,
      onTap: (i) => setState(() => _tab = i),
    ),
  );
}

// ─────────────────────────────────────────────
//  BOTTOM NAV  (now 5 items)
// ─────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int current;
  final bool hasShop;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.current,
    required this.hasShop,
    required this.onTap,
  });

  static const _itemsNoShop = [
    _NI(icon: Icons.home_outlined, active: Icons.home, label: 'Home'),
    _NI(
      icon: Icons.add_circle_outline,
      active: Icons.add_circle,
      label: 'Create',
      center: true,
    ),
    _NI(
      icon: Icons.storefront_outlined,
      active: Icons.storefront,
      label: 'Shops',
    ), // ← NEW
    _NI(icon: Icons.person_outline, active: Icons.person, label: 'Profile'),
    _NI(icon: Icons.shield_outlined, active: Icons.shield, label: 'Admin'),
  ];

  static const _itemsHasShop = [
    _NI(icon: Icons.home_outlined, active: Icons.home, label: 'Home'),
    _NI(icon: Icons.store_outlined, active: Icons.store, label: 'My Shop'),
    _NI(
      icon: Icons.storefront_outlined,
      active: Icons.storefront,
      label: 'Shops',
    ), // ← NEW
    _NI(icon: Icons.person_outline, active: Icons.person, label: 'Profile'),
    _NI(icon: Icons.shield_outlined, active: Icons.shield, label: 'Admin'),
  ];

  List<_NI> get _items => hasShop ? _itemsHasShop : _itemsNoShop;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final ico = (sw * 0.050).clamp(16.0, 24.0); // slightly smaller for 5 items
    final fs = (sw * 0.024).clamp(8.0, 11.5);
    final cs = (sw * 0.085).clamp(30.0, 42.0);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.lightGreen, AppColors.golden],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.008,
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final sel = i == current;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.center)
                        Container(
                          width: cs,
                          height: cs,
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.cream
                                : AppColors.cream.withOpacity(0.30),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.cream.withOpacity(0.7),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            sel ? item.active : item.icon,
                            color: AppColors.darkGreen.withOpacity(
                              sel ? 1 : 0.75,
                            ),
                            size: ico,
                          ),
                        )
                      else
                        Icon(
                          sel ? item.active : item.icon,
                          color: sel
                              ? AppColors.cream
                              : AppColors.darkGreen.withOpacity(0.8),
                          size: ico,
                        ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: fs,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel
                              ? AppColors.cream
                              : AppColors.darkGreen.withOpacity(0.8),
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

class _NI {
  final IconData icon, active;
  final String label;
  final bool center;
  const _NI({
    required this.icon,
    required this.active,
    required this.label,
    this.center = false,
  });
}

// ─────────────────────────────────────────────
//  HOME TAB  (unchanged)
// ─────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final List<RicePrice> prices;
  final bool loadingPrices;
  final TextEditingController searchCtrl;
  final String searchQuery;
  final ValueChanged<String> onSearch;
  final VoidCallback onRefresh;
  final CartController cart;
  final List<Map<String, dynamic>> apiShops;
  final bool loadingApiShops;
  final String shopsError;

  const _HomeTab({
    required this.prices,
    required this.loadingPrices,
    required this.searchCtrl,
    required this.searchQuery,
    required this.onSearch,
    required this.onRefresh,
    required this.cart,
    required this.apiShops,
    required this.loadingApiShops,
    required this.shopsError,
  });

  List<RicePrice> get _filteredPrices => prices
      .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
      .toList();

  List<RiceProduct> get _riceList {
    final result = <RiceProduct>[];
    for (final shop in apiShops) {
      final cats = (shop['rice_categories'] as List?) ?? [];
      for (final cat in cats) {
        result.add(
          RiceProduct(
            name: cat['name'] ?? 'Rice',
            shop: shop['shop_name'] ?? 'Unknown Shop',
            shopId: shop['id']?.toString() ?? '',
            imagePath: 'assets/images/rice.jpeg',
            price: (cat['price_per_kg'] ?? 0).toDouble(),
          ),
        );
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final bannerH = (sw * 0.42).clamp(130.0, 200.0);
    final cardW = (sw * 0.38).clamp(130.0, 170.0);
    final cardImgH = (cardW * 0.65).clamp(80.0, 110.0);
    final riceList = _riceList;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        color: AppColors.golden,
        backgroundColor: AppColors.cream,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: Row(
                  children: [
                    Text('Rice Mart', style: AppTextStyles.heading2),
                    const Spacer(),
                    _HdrBtn(
                      icon: Icons.notifications_outlined,
                      onTap: () => Get.toNamed(AppRoutes.notifications),
                    ),
                    const SizedBox(width: 8),
                    _HdrBtn(
                      icon: Icons.chat_bubble_outline,
                      onTap: () => Get.toNamed(AppRoutes.chat),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => _HdrBtn(
                        icon: Icons.shopping_cart_outlined,
                        badge: cart.totalCount,
                        onTap: () => Get.toNamed(AppRoutes.cart),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.overlayLight,
                        foregroundColor: AppColors.darkGreen,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: AppColors.borderGold.withOpacity(0.5),
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.language,
                        size: 14,
                        color: AppColors.darkGreen,
                      ),
                      label: Text(
                        'اردو',
                        style: AppTextStyles.label.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Hero banner ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: bannerH,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/home_screen.jpeg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: bannerH,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.lightGreen,
                                  AppColors.golden,
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
                          ),
                        ),
                      ),
                      Container(
                        height: bannerH,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.transparent,
                              AppColors.darkGreen.withOpacity(0.65),
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
              const SizedBox(height: 14),

              // ── Search ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  decoration: AppDecorations.inputField,
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: onSearch,
                    style: AppTextStyles.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Search for rice varieties, shops...',
                      hintStyle: AppTextStyles.hint,
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.iconMuted,
                        size: 20,
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                searchCtrl.clear();
                                onSearch('');
                              },
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.iconMuted,
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
              const SizedBox(height: 12),

              // ── AI buttons ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: _AiBtn(
                        icon: Icons.camera_alt_outlined,
                        title: 'AI Detection & Suggestion',
                        subtitle: 'Analyze rice quality',
                        onTap: () => Get.toNamed(AppRoutes.aiDetection),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AiBtn(
                        icon: Icons.auto_awesome_outlined,
                        title: 'AI Recommendation',
                        subtitle: 'Rice for recipes',
                        onTap: () => Get.toNamed(AppRoutes.aiRecommendation),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── Market Prices ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      size: 16,
                      color: AppColors.darkGreen,
                    ),
                    const SizedBox(width: 6),
                    Text('Rice Market Prices', style: AppTextStyles.heading4),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.golden.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.golden.withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        'Admin set',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10,
                          color: AppColors.golden,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onRefresh,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: AppDecorations.iconButton,
                        child: Icon(
                          Icons.refresh,
                          size: 16,
                          color: AppColors.darkGreen.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Price table
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardFill,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: loadingPrices
                      ? const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.golden,
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
                                color: AppColors.darkGreen.withOpacity(0.12),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(14),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Text(
                                      'Rice Name',
                                      style: AppTextStyles.label.copyWith(
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Price (Rs/kg)',
                                      style: AppTextStyles.label.copyWith(
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ..._filteredPrices.asMap().entries.map(
                              (e) => _PriceRow(
                                rice: e.value,
                                isLast: e.key == _filteredPrices.length - 1,
                              ),
                            ),
                            if (_filteredPrices.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'No results',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Rice List header ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 16,
                      color: AppColors.darkGreen,
                    ),
                    const SizedBox(width: 6),
                    Text('Rice List', style: AppTextStyles.heading4),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.35),
                        ),
                      ),
                      child: Text(
                        loadingApiShops
                            ? 'Loading...'
                            : shopsError.isNotEmpty
                            ? 'Error'
                            : '${riceList.length} available',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10,
                          color: shopsError.isNotEmpty
                              ? AppColors.error
                              : AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.shops),
                      child: Text(
                        'See All',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 12.5,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ── Rice List body ──────────────────────────────
              if (loadingApiShops)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.golden,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              else if (shopsError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: AppDecorations.card,
                    child: Column(
                      children: [
                        Icon(
                          Icons.wifi_off_outlined,
                          size: 36,
                          color: AppColors.darkGreen.withOpacity(0.4),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          shopsError,
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: onRefresh,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: AppDecorations.pill,
                            child: Text(
                              'Retry',
                              style: AppTextStyles.label.copyWith(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (riceList.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: AppDecorations.card,
                    child: Column(
                      children: [
                        Icon(
                          Icons.store_mall_directory_outlined,
                          size: 40,
                          color: AppColors.darkGreen.withOpacity(0.3),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No products yet.\nApproved shop products appear here.',
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  height: cardImgH + 104,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 18, right: 8),
                    itemCount: riceList.length,
                    itemBuilder: (_, i) => _ProductCard(
                      product: riceList[i],
                      cardWidth: cardW,
                      imgHeight: cardImgH,
                      cart: cart,
                    ),
                  ),
                ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HEADER BUTTON
// ─────────────────────────────────────────────
class _HdrBtn extends StatelessWidget {
  final IconData icon;
  final int badge;
  final VoidCallback onTap;
  const _HdrBtn({required this.icon, required this.onTap, this.badge = 0});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: AppDecorations.iconButton,
          child: Icon(icon, size: 19, color: AppColors.darkGreen),
        ),
        if (badge > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.golden,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$badge',
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
//  AI BUTTON
// ─────────────────────────────────────────────
class _AiBtn extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _AiBtn({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.overlayLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
            ),
            child: Icon(icon, size: 17, color: AppColors.darkGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.label.copyWith(fontSize: 12),
                  maxLines: 2,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────
//  PRICE ROW
// ─────────────────────────────────────────────
class _PriceRow extends StatelessWidget {
  final RicePrice rice;
  final bool isLast;
  const _PriceRow({required this.rice, required this.isLast});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : Border(
              bottom: BorderSide(
                color: AppColors.borderGold.withOpacity(0.2),
                width: 1,
              ),
            ),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 6,
          child: Text(
            rice.name,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            'Rs ${rice.price.toStringAsFixed(0)}',
            style: AppTextStyles.bodyLarge.copyWith(fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────
//  PRODUCT CARD
// ─────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final RiceProduct product;
  final double cardWidth, imgHeight;
  final CartController cart;
  const _ProductCard({
    required this.product,
    required this.cardWidth,
    required this.imgHeight,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Get.toNamed(
      AppRoutes.shops,
      arguments: {'highlightShopId': product.shopId},
    ),
    child: Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 12, bottom: 4),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            child: SizedBox(
              height: imgHeight,
              width: double.infinity,
              child: Image.asset(
                product.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.cream.withOpacity(0.4),
                  child: const Icon(
                    Icons.grain,
                    size: 36,
                    color: Colors.white54,
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
                  style: AppTextStyles.heading4.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.shop,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs ${product.price.toStringAsFixed(0)}/kg',
                      style: AppTextStyles.label.copyWith(fontSize: 12),
                    ),
                    Obx(
                      () => GestureDetector(
                        onTap: () {
                          cart.add(product);
                          Get.snackbar(
                            'Added',
                            '${product.name} added to cart',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: cart.contains(product)
                                ? AppColors.golden
                                : AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            cart.contains(product) ? Icons.check : Icons.add,
                            size: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
