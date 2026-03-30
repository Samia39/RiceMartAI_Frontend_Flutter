// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GetStorage box = GetStorage();
  final TextEditingController _searchController = TextEditingController();

  // ── Rice price data ──────────────────────────────────────────────
  final List<Map<String, dynamic>> _ricePrices = [
    {
      'name': 'Basmati Rice',
      'price': 280,
      'change': '+5%',
      'up': true,
      'zero': false,
    },
    {
      'name': 'Super Basmati',
      'price': 320,
      'change': '+3%',
      'up': true,
      'zero': false,
    },
    {
      'name': 'Sella Rice',
      'price': 250,
      'change': '-2%',
      'up': false,
      'zero': false,
    },
    {
      'name': 'Brown Rice',
      'price': 200,
      'change': '+1%',
      'up': true,
      'zero': false,
    },
    {
      'name': 'Kainat Rice',
      'price': 265,
      'change': '+2%',
      'up': true,
      'zero': false,
    },
    {
      'name': 'Supri Rice',
      'price': 185,
      'change': '0%',
      'up': true,
      'zero': true,
    },
    {
      'name': 'IR-6 Rice',
      'price': 150,
      'change': '-1%',
      'up': false,
      'zero': false,
    },
    {
      'name': 'Kernel Basmati',
      'price': 295,
      'change': '+4%',
      'up': true,
      'zero': false,
    },
  ];

  // ── Product data ─────────────────────────────────────────────────
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Basmati Rice',
      'shop': 'Anware Sidra Rice Sh...',
      'price': 280,
      'color': Color(0xFFD4C5A9),
    },
    {
      'name': 'Super Basmati',
      'shop': 'Anware Sidra Rice Sh...',
      'price': 320,
      'color': Color(0xFFBFAF90),
    },
    {
      'name': 'Sella Rice',
      'shop': 'Anware Sidra Rice Sh...',
      'price': 250,
      'color': Color(0xFFCFC0A0),
    },
  ];

  String get _userName => box.read('userName') ?? 'User';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8DA882),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7A9268), Color(0xFF8DA882), Color(0xFFB2A86A)],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12),
                      _buildHeroBanner(),
                      SizedBox(height: 16),
                      _buildSearchBar(),
                      SizedBox(height: 12),
                      _buildAIDetectionCard(),
                      SizedBox(height: 10),
                      _buildAIRecommendationCard(),
                      SizedBox(height: 20),
                      _buildPriceTable(),
                      SizedBox(height: 20),
                      _buildProductsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Rice Mart',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2A14),
              letterSpacing: 0.3,
            ),
          ),
          // Language toggle
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Color(0xFFD6DEC8).withOpacity(0.45),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFFB8C9A3).withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language, size: 15, color: Color(0xFF2D3A22)),
                SizedBox(width: 5),
                Text(
                  'اردو',
                  style: TextStyle(
                    color: Color(0xFF2D3A22),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero banner ──────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Background image placeholder (replace with real asset/network image)
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A7A3A), Color(0xFFB8C9A3)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Image.network(
                'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?w=800',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Color(0xFF5A7A4A),
                  child: Icon(Icons.grass, size: 60, color: Colors.white38),
                ),
              ),
            ),
            // Dark overlay gradient
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                ),
              ),
            ),
            // Text overlay
            Positioned(
              bottom: 18,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Premium Quality Rice',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Discover the finest rice varieties',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12.5,
                      shadows: [Shadow(blurRadius: 3, color: Colors.black38)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search bar ───────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFD6DEC8).withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFB8C9A3).withOpacity(0.6)),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: Color(0xFF2D3A22), fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search for rice varieties, shops...',
            hintStyle: TextStyle(
              color: Color(0xFF5A6B4A).withOpacity(0.7),
              fontSize: 13.5,
            ),
            prefixIcon: Icon(Icons.search, color: Color(0xFF5A6B4A), size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── AI Detection card ────────────────────────────────────────────
  Widget _buildAIDetectionCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          // TODO: navigate to AI Detection screen
          Get.snackbar(
            'AI Detection',
            'Opening rice quality analyzer...',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Color(0xFFD6DEC8).withOpacity(0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFB8C9A3).withOpacity(0.55)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF2D3A22),
                size: 22,
              ),
              SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Detection & Suggestion',
                    style: TextStyle(
                      color: Color(0xFF1E2A14),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Analyze rice quality',
                    style: TextStyle(
                      color: Color(0xFF2D3A22).withOpacity(0.7),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Icon(Icons.chevron_right, color: Color(0xFF5A6B4A), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── AI Recommendation card ───────────────────────────────────────
  Widget _buildAIRecommendationCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          // TODO: navigate to AI Recommendation screen
          Get.snackbar(
            'AI Recommendation',
            'Finding rice for your recipes...',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Color(0xFFD6DEC8).withOpacity(0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFB8C9A3).withOpacity(0.55)),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF2D3A22), size: 22),
              SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Recommendation',
                    style: TextStyle(
                      color: Color(0xFF1E2A14),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Rice for recipes',
                    style: TextStyle(
                      color: Color(0xFF2D3A22).withOpacity(0.7),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Icon(Icons.chevron_right, color: Color(0xFF5A6B4A), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Price table ──────────────────────────────────────────────────
  Widget _buildPriceTable() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(Icons.trending_up, size: 18, color: Color(0xFF1E2A14)),
              SizedBox(width: 6),
              Text(
                'Real-Time Rice Prices',
                style: TextStyle(
                  color: Color(0xFF1E2A14),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFD6DEC8).withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFB8C9A3).withOpacity(0.5)),
            ),
            child: Column(
              children: [
                // Table header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFFB8C9A3).withOpacity(0.45),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text('Rice Name', style: _headerStyle()),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('Price (Rs/kg)', style: _headerStyle()),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Change',
                          textAlign: TextAlign.right,
                          style: _headerStyle(),
                        ),
                      ),
                    ],
                  ),
                ),
                // Table rows
                ...List.generate(_ricePrices.length, (i) {
                  final rice = _ricePrices[i];
                  final isLast = i == _ricePrices.length - 1;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: Color(0xFFB8C9A3).withOpacity(0.35),
                                width: 0.8,
                              ),
                            ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            rice['name'],
                            style: TextStyle(
                              color: Color(0xFF1E2A14),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Rs ${rice['price']}',
                            style: TextStyle(
                              color: Color(0xFF2D3A22),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            rice['change'],
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: rice['zero']
                                  ? Color(0xFF2D3A22)
                                  : rice['up']
                                  ? Color(0xFF2E7D32)
                                  : Color(0xFFC62828),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _headerStyle() => TextStyle(
    color: Color(0xFF1E2A14),
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );

  // ── Products section ─────────────────────────────────────────────
  Widget _buildProductsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(
                Icons.shopping_basket_outlined,
                size: 18,
                color: Color(0xFF1E2A14),
              ),
              SizedBox(width: 6),
              Text(
                'Products',
                style: TextStyle(
                  color: Color(0xFF1E2A14),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Product cards row
          Row(
            children: _products.map((product) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: product == _products.last ? 0 : 10,
                  ),
                  child: _buildProductCard(product),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          'Product',
          '${product['name']} selected',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFD6DEC8).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFB8C9A3).withOpacity(0.55)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 90,
                width: double.infinity,
                color: product['color'],
                child: Icon(Icons.grass, size: 40, color: Colors.white38),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: TextStyle(
                      color: Color(0xFF1E2A14),
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    product['shop'],
                    style: TextStyle(
                      color: Color(0xFF2D3A22).withOpacity(0.65),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rs ${product['price']}/kg',
                    style: TextStyle(
                      color: Color(0xFF2D3A22),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
