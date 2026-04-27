// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/themes.dart';
import '../../core/services/shop_service.dart';

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
  final List<String> _filters = ['All', 'Approved', 'Pending'];

  // All shops loaded from API
  List<Map<String, dynamic>> _allShops = [];
  // Filtered list shown in UI
  List<Map<String, dynamic>> _filteredShops = [];

  bool _isLoading = true;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Load shops from API ──────────────────────────────────────
  // ShopService.getAllShops() returns:
  //   { 'success': true, 'shops': [ ...shopMaps ] }
  // Each shop map has:
  //   id, shop_name, owner_name, phone, address, description,
  //   cnic_number, cnic_image (full URL), is_approved,
  //   rice_categories: [ { id, name, price_per_kg } ]
  Future<void> _loadShops({String? query}) async {
    setState(() => _isLoading = true);

    final result = await ShopService.getAllShops(query: query);

    if (result['success'] == true) {
      final shops = result['shops'] as List<Map<String, dynamic>>;
      setState(() {
        _allShops = shops;
        _applyFilter();
      });
    } else {
      Get.snackbar('Error', result['message'] ?? 'Could not load shops');
      setState(() {
        _allShops = [];
        _filteredShops = [];
      });
    }

    setState(() => _isLoading = false);
  }

  // ── Apply search + filter locally ────────────────────────────
  void _applyFilter() {
    List<Map<String, dynamic>> base = List.from(_allShops);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      base = base.where((s) {
        return (s['shop_name'] ?? '').toLowerCase().contains(q) ||
            (s['owner_name'] ?? '').toLowerCase().contains(q) ||
            (s['address'] ?? '').toLowerCase().contains(q);
      }).toList();
    }

    // Tab filter
    if (_selectedFilter == 'Approved') {
      base = base
          .where((s) => s['is_approved'] == true || s['is_approved'] == 1)
          .toList();
    } else if (_selectedFilter == 'Pending') {
      base = base
          .where((s) => s['is_approved'] == false || s['is_approved'] == 0)
          .toList();
    }

    setState(() => _filteredShops = base);
  }

  void _onSearch(String val) {
    _searchQuery = val;
    _applyFilter();
  }

  // ════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════
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
              // ── AppBar ─────────────────────────────────────
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
                    // Refresh
                    GestureDetector(
                      onTap: () => _loadShops(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _cream.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _border.withOpacity(0.5)),
                        ),
                        child: const Icon(
                          Icons.refresh,
                          size: 18,
                          color: _darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Search ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: _cream.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border.withOpacity(0.5)),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearch,
                    style: const TextStyle(color: _darkGreen, fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Search by name, owner, or address...',
                      hintStyle: TextStyle(
                        color: _darkGreen.withOpacity(0.5),
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: _darkGreen.withOpacity(0.7),
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                _onSearch('');
                              },
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: _darkGreen.withOpacity(0.6),
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Filter chips ───────────────────────────────
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: _filters.length,
                  itemBuilder: (_, i) {
                    final selected = _selectedFilter == _filters[i];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedFilter = _filters[i]);
                        _applyFilter();
                      },
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
              const SizedBox(height: 10),

              // ── Count row ──────────────────────────────────
              if (!_isLoading)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
                  child: Row(
                    children: [
                      Text(
                        '${_filteredShops.length} shop${_filteredShops.length == 1 ? '' : 's'} found',
                        style: TextStyle(
                          fontSize: 12,
                          color: _darkGreen.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── List ───────────────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: _darkGreen,
                          strokeWidth: 2.5,
                        ),
                      )
                    : _filteredShops.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.storefront_outlined,
                              size: 52,
                              color: _darkGreen.withOpacity(0.35),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No shops match your search'
                                  : 'No shops available yet',
                              style: TextStyle(
                                fontSize: 14,
                                color: _darkGreen.withOpacity(0.65),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadShops(),
                        color: _darkGreen,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          itemCount: _filteredShops.length,
                          itemBuilder: (_, i) =>
                              _ShopCard(shop: _filteredShops[i]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHOP CARD — renders real API shop data
// ─────────────────────────────────────────────
class _ShopCard extends StatelessWidget {
  final Map<String, dynamic> shop;

  static const Color _darkGreen = Color(0xFF1A2820);
  static const Color _cream = Color(0xFFD4C9A8);
  static const Color _border = Color(0xFFB8A97A);
  static const Color _golden = Color(0xFF9D7E3F);

  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    final isApproved = shop['is_approved'] == true || shop['is_approved'] == 1;

    // rice_categories from backend: [ { id, name, price_per_kg } ]
    final categories = (shop['rice_categories'] as List?) ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _cream.withOpacity(0.22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border.withOpacity(0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Banner image (cnic_image is full URL from backend) ──
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: shop['cnic_image'] != null
                ? Image.network(
                    shop['cnic_image'],
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shop name + approval badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        shop['shop_name'] ?? 'Unnamed Shop',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: _darkGreen,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? Colors.green.withOpacity(0.15)
                            : Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isApproved ? '✅ Approved' : '⏳ Pending',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isApproved
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Owner
                _iconRow(
                  Icons.person_outline,
                  shop['owner_name'] ?? 'Unknown Owner',
                ),
                const SizedBox(height: 3),

                // Address
                _iconRow(
                  Icons.location_on_outlined,
                  shop['address'] ?? 'No address',
                ),
                const SizedBox(height: 3),

                // Phone
                if ((shop['phone'] ?? '').toString().isNotEmpty)
                  _iconRow(Icons.phone_outlined, shop['phone']),

                // Description
                if ((shop['description'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    shop['description'],
                    style: TextStyle(
                      fontSize: 11.5,
                      color: _darkGreen.withOpacity(0.65),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Rice category chips
                if (categories.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: categories.take(5).map((cat) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _golden.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _golden.withOpacity(0.35)),
                        ),
                        child: Text(
                          '${cat['name']}  •  PKR ${cat['price_per_kg']}/kg',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: _golden,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 13, color: _darkGreen.withOpacity(0.6)),
      const SizedBox(width: 4),
      Expanded(
        child: Text(
          text,
          style: TextStyle(fontSize: 12, color: _darkGreen.withOpacity(0.7)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _placeholder() => Container(
    height: 80,
    color: _cream.withOpacity(0.4),
    child: const Center(
      child: Icon(Icons.storefront, size: 40, color: Colors.white54),
    ),
  );
}
