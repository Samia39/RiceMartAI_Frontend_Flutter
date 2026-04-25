import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShopsScreen extends StatefulWidget {
  const ShopsScreen({Key? key}) : super(key: key);

  @override
  State<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends State<ShopsScreen> {
  static const Color _darkGreen = Color(0xFF1A2820);
  static const Color _lightGreen = Color(0xFF5A8A6E);
  static const Color _golden = Color(0xFF9D7E3F);
  static const Color _cream = Color(0xFFD4C9A8);
  static const Color _border = Color(0xFFB8A97A);

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Nearby', 'Top Rated', 'Open Now'];

  final List<Map<String, dynamic>> _shops = [
    {
      'name': 'Anware Sidra Rice Shop',
      'location': 'Lahore, Punjab',
      'rating': 4.8,
      'reviews': 124,
      'open': true,
      'specialty': 'Basmati & Super Basmati',
      'image': 'lib/assets/shop1.jpg',
    },
    {
      'name': 'Al-Madina Rice Store',
      'location': 'Karachi, Sindh',
      'rating': 4.5,
      'reviews': 89,
      'open': true,
      'specialty': 'Sella & Brown Rice',
      'image': 'lib/assets/shop2.jpg',
    },
    {
      'name': 'Punjab Rice Center',
      'location': 'Faisalabad, Punjab',
      'rating': 4.6,
      'reviews': 102,
      'open': false,
      'specialty': 'Kainat & IR-6 Rice',
      'image': 'lib/assets/shop3.jpg',
    },
    {
      'name': 'Kernel Basmati House',
      'location': 'Islamabad, ICT',
      'rating': 4.9,
      'reviews': 211,
      'open': true,
      'specialty': 'Kernel & Premium Basmati',
      'image': 'lib/assets/shop4.jpg',
    },
    {
      'name': 'Green Valley Rice',
      'location': 'Multan, Punjab',
      'rating': 4.3,
      'reviews': 67,
      'open': true,
      'specialty': 'Organic Brown Rice',
      'image': 'lib/assets/shop5.jpg',
    },
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
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _cream.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _border.withOpacity(0.5)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: _darkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Rice Shops',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _darkGreen,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _cream.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _border.withOpacity(0.5)),
                      ),
                      child: const Icon(
                        Icons.tune,
                        size: 18,
                        color: _darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Search ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: _cream.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border.withOpacity(0.5)),
                  ),
                  child: TextField(
                    style: const TextStyle(color: _darkGreen, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Search shops by name or location...',
                      hintStyle: TextStyle(
                        color: _darkGreen.withOpacity(0.5),
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: _darkGreen.withOpacity(0.7),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Filters ───────────────────────────────────
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: _filters.length,
                  itemBuilder: (_, i) {
                    final selected = _selectedFilter == _filters[i];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedFilter = _filters[i]),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? _darkGreen
                              : _cream.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? _darkGreen
                                : _border.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          _filters[i],
                          style: TextStyle(
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
              const SizedBox(height: 16),

              // ── Shop List ─────────────────────────────────
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: _shops.length,
                  itemBuilder: (_, i) => _ShopCard(shop: _shops[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final Map<String, dynamic> shop;
  static const Color _darkGreen = Color(0xFF1A2820);
  static const Color _cream = Color(0xFFD4C9A8);
  static const Color _border = Color(0xFFB8A97A);

  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    final isOpen = shop['open'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _cream.withOpacity(0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border.withOpacity(0.45)),
      ),
      child: Column(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: Image.asset(
                shop['image'],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: _cream.withOpacity(0.4),
                  child: const Center(
                    child: Icon(
                      Icons.storefront,
                      size: 48,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop['name'],
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: _darkGreen,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: _darkGreen.withOpacity(0.6),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            shop['location'],
                            style: TextStyle(
                              fontSize: 12,
                              color: _darkGreen.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Specialty: ${shop['specialty']}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: _darkGreen.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isOpen
                            ? Colors.green.withOpacity(0.15)
                            : Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isOpen ? 'Open' : 'Closed',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isOpen
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFF9D7E3F),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${shop['rating']}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _darkGreen,
                          ),
                        ),
                        Text(
                          ' (${shop['reviews']})',
                          style: TextStyle(
                            fontSize: 11,
                            color: _darkGreen.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
