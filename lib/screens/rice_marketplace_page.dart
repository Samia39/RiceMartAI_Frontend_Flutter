// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  RICE PRODUCT MODEL
// ─────────────────────────────────────────────
class RiceProduct {
  final int id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final double rating;
  final int reviews;
  final String shopName;
  final bool inStock;
  final String description;

  const RiceProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.rating,
    required this.reviews,
    required this.shopName,
    required this.inStock,
    required this.description,
  });
}

// ─────────────────────────────────────────────
//  DUMMY DATA
// ─────────────────────────────────────────────
final List<RiceProduct> _allProducts = [
  const RiceProduct(
    id: 1, name: 'Basmati Rice', category: 'Basmati',
    price: 180, unit: 'per kg', rating: 4.8, reviews: 124,
    shopName: 'Ali Rice Store', inStock: true,
    description: 'Premium long-grain aromatic basmati rice.',
  ),
  const RiceProduct(
    id: 2, name: 'Super Kernel Basmati', category: 'Basmati',
    price: 220, unit: 'per kg', rating: 4.9, reviews: 98,
    shopName: 'Punjab Grain Co.', inStock: true,
    description: 'Extra long super kernel basmati, perfect for biryani.',
  ),
  const RiceProduct(
    id: 3, name: 'Sella Rice', category: 'Sella',
    price: 150, unit: 'per kg', rating: 4.5, reviews: 76,
    shopName: 'Raza Traders', inStock: true,
    description: 'Golden sella rice with firm texture.',
  ),
  const RiceProduct(
    id: 4, name: 'Brown Rice', category: 'Brown',
    price: 200, unit: 'per kg', rating: 4.3, reviews: 55,
    shopName: 'Health Grains', inStock: true,
    description: 'Whole grain brown rice, high in fiber.',
  ),
  const RiceProduct(
    id: 5, name: 'Irri-6 Rice', category: 'Irri',
    price: 90, unit: 'per kg', rating: 4.1, reviews: 210,
    shopName: 'Bulk Rice Hub', inStock: true,
    description: 'Popular everyday rice for daily cooking.',
  ),
  const RiceProduct(
    id: 6, name: 'Irri-9 Rice', category: 'Irri',
    price: 95, unit: 'per kg', rating: 4.2, reviews: 180,
    shopName: 'Bulk Rice Hub', inStock: false,
    description: 'Improved Irri variety with better aroma.',
  ),
  const RiceProduct(
    id: 7, name: 'Jasmine Rice', category: 'Aromatic',
    price: 260, unit: 'per kg', rating: 4.7, reviews: 43,
    shopName: 'Gourmet Grains', inStock: true,
    description: 'Thai jasmine rice, soft and fragrant.',
  ),
  const RiceProduct(
    id: 8, name: 'White Sella', category: 'Sella',
    price: 140, unit: 'per kg', rating: 4.4, reviews: 88,
    shopName: 'Raza Traders', inStock: true,
    description: 'White sella rice, ideal for pulao.',
  ),
];

const List<String> _categories = [
  'All', 'Basmati', 'Sella', 'Brown', 'Irri', 'Aromatic',
];

// ─────────────────────────────────────────────
//  COLOR CONSTANTS (matching app theme)
// ─────────────────────────────────────────────
const Color _darkGreen  = Color(0xFF1A2820);
const Color _lightGreen = Color(0xFF5A8A6E);
const Color _golden     = Color(0xFF9D7E3F);
const Color _cream      = Color(0xFFD4C9A8);
const Color _borderGold = Color(0xFFB8A97A);
const Color _errorRed   = Color(0xFFD32F2F);

// ─────────────────────────────────────────────
//  RICE MARKETPLACE PAGE
// ─────────────────────────────────────────────
class RiceMarketplacePage extends StatefulWidget {
  const RiceMarketplacePage({super.key});

  @override
  State<RiceMarketplacePage> createState() => _RiceMarketplacePageState();
}

class _RiceMarketplacePageState extends State<RiceMarketplacePage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query    = '';
  String _category = 'All';

  List<RiceProduct> get _filtered {
    return _allProducts.where((p) {
      final matchCat = _category == 'All' || p.category == _category;
      final matchQ   = _query.isEmpty ||
          p.name.toLowerCase().contains(_query.toLowerCase()) ||
          p.category.toLowerCase().contains(_query.toLowerCase()) ||
          p.shopName.toLowerCase().contains(_query.toLowerCase());
      return matchCat && matchQ;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_lightGreen, _golden],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Rice Marketplace',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _darkGreen,
                  letterSpacing: 0.3,
                ),
              ),
            ),

            // ── Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: _cream.withOpacity(0.30),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _borderGold.withOpacity(0.55)),
                  boxShadow: [
                    BoxShadow(
                      color: _darkGreen.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: _darkGreen,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search rice or category...',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: _darkGreen.withOpacity(0.55),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: _darkGreen.withOpacity(0.70),
                      size: 22,
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close,
                              color: _darkGreen.withOpacity(0.60),
                              size: 20,
                            ),
                            onPressed: () => setState(() {
                              _query = '';
                              _searchCtrl.clear();
                            }),
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

            // ── Category Chips
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: _categories.length,
                itemBuilder: (ctx, i) {
                  final cat      = _categories[i];
                  final selected = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? _darkGreen
                            : _cream.withOpacity(0.30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? _darkGreen
                              : _borderGold.withOpacity(0.50),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: selected ? _cream : _darkGreen,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Products Grid or Empty
            Expanded(
              child: results.isEmpty
                  ? _buildEmpty()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: results.length,
                      itemBuilder: (ctx, i) =>
                          _ProductCard(product: results[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grain_outlined,
            size: 64,
            color: _darkGreen.withOpacity(0.30),
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _darkGreen.withOpacity(0.65),
            ),
          ),
          if (_query.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Try a different search term',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: _darkGreen.withOpacity(0.45),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  PRODUCT CARD
// ─────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final RiceProduct product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: _cream.withOpacity(0.22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderGold.withOpacity(0.45)),
          boxShadow: [
            BoxShadow(
              color: _darkGreen.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 110,
                width: double.infinity,
                color: _darkGreen.withOpacity(0.12),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.grain,
                        size: 52,
                        color: _darkGreen.withOpacity(0.25),
                      ),
                    ),
                    if (!product.inStock)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _errorRed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Out of Stock',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _darkGreen.withOpacity(0.70),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _darkGreen,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.shopName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.5,
                      color: _darkGreen.withOpacity(0.60),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: _golden),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toString(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _darkGreen,
                        ),
                      ),
                      Text(
                        ' (${product.reviews})',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: _darkGreen.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rs. ${product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: _darkGreen,
                            ),
                          ),
                          Text(
                            product.unit,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: _darkGreen.withOpacity(0.55),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: product.inStock ? () {} : null,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: product.inStock
                                ? _darkGreen
                                : _darkGreen.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
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

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductDetailSheet(product: product),
    );
  }
}

// ─────────────────────────────────────────────
//  PRODUCT DETAIL BOTTOM SHEET
// ─────────────────────────────────────────────
class _ProductDetailSheet extends StatefulWidget {
  final RiceProduct product;
  const _ProductDetailSheet({required this.product});

  @override
  State<_ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<_ProductDetailSheet> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_lightGreen, _golden],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: _borderGold.withOpacity(0.45)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _darkGreen.withOpacity(0.30),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Image
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            height: 140,
            decoration: BoxDecoration(
              color: _darkGreen.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderGold.withOpacity(0.40)),
            ),
            child: Center(
              child: Icon(
                Icons.grain,
                size: 72,
                color: _darkGreen.withOpacity(0.25),
              ),
            ),
          ),

          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _darkGreen,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _darkGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _borderGold.withOpacity(0.40),
                          ),
                        ),
                        child: Text(
                          p.category,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _darkGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.shopName,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: _darkGreen.withOpacity(0.60),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: _golden),
                      const SizedBox(width: 4),
                      Text(
                        '${p.rating}  (${p.reviews} reviews)',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.5,
                          color: _darkGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p.description,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: _darkGreen.withOpacity(0.75),
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),

                  // Qty + Price
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _cream.withOpacity(0.30),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _borderGold.withOpacity(0.50),
                          ),
                        ),
                        child: Row(
                          children: [
                            _qtyBtn(Icons.remove, () {
                              if (_qty > 1) setState(() => _qty--);
                            }),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Text(
                                '$_qty',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: _darkGreen,
                                ),
                              ),
                            ),
                            _qtyBtn(Icons.add, () => setState(() => _qty++)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Rs. ${(p.price * _qty).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _darkGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: p.inStock
                          ? () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${p.name} added to cart!',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: _darkGreen,
                                    ),
                                  ),
                                  backgroundColor: _cream.withOpacity(0.95),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        p.inStock ? 'Add to Cart' : 'Out of Stock',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.inStock
                            ? _darkGreen
                            : _darkGreen.withOpacity(0.35),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: _darkGreen),
      ),
    );
  }
}