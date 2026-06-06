// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/shop_service.dart';
import '../../models/shop_model.dart';

class ShopsScreen extends StatefulWidget {
  const ShopsScreen({super.key});

  @override
  State<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends State<ShopsScreen> {
  List<Shop> shops = [];
  List<Shop> filtered = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadShops();
  }

  Future<void> loadShops() async {
    setState(() => isLoading = true);
    try {
      shops = await ShopService.getAllShops();
      filtered = shops;
    } catch (e) {
      filtered = [];
    }
    setState(() => isLoading = false);
  }

  void searchShops(String query) {
    setState(() {
      filtered = shops
          .where((s) =>
              s.name.toLowerCase().contains(query.toLowerCase()) ||
              (s.address ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Search Bar ───────────────────────────────────
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFD4C9A8).withOpacity(0.30),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFB8A97A).withOpacity(0.55)),
            ),
            child: TextField(
              onChanged: searchShops,
              style: const TextStyle(
                  color: Color(0xFF1A2820), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search shops...',
                hintStyle: TextStyle(
                    color: const Color(0xFF1A2820).withOpacity(0.60),
                    fontSize: 14),
                prefixIcon: Icon(Icons.search,
                    color: const Color(0xFF1A2820).withOpacity(0.75)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 15),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Shops List ───────────────────────────────────
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.store,
                              size: 60,
                              color: const Color(0xFF1A2820).withOpacity(0.45)),
                          const SizedBox(height: 12),
                          const Text('No shops found',
                              style: TextStyle(
                                  color: Color(0xFF1A2820), fontSize: 14)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadShops,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final shop = filtered[i];
                          return GestureDetector(
                            onTap: () => Get.toNamed(
                                '/shop-detail',
                                arguments: shop.id),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4C9A8)
                                    .withOpacity(0.22),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0xFFB8A97A)
                                        .withOpacity(0.45)),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        const BorderRadius.horizontal(
                                            left: Radius.circular(16)),
                                    child: shop.logo != null
                                        ? Image.network(
                                            'http://localhost/sheezabackend/public/storage/${shop.logo}',
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _noLogo(),
                                          )
                                        : _noLogo(),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(shop.name,
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1A2820),
                                              )),
                                          const SizedBox(height: 4),
                                          if (shop.address != null)
                                            Row(
                                              children: [
                                                Icon(
                                                    Icons
                                                        .location_on_outlined,
                                                    size: 14,
                                                    color:
                                                        const Color(0xFF1A2820)
                                                            .withOpacity(
                                                                0.75)),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    shop.address!,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: const Color(
                                                                0xFF1A2820)
                                                            .withOpacity(
                                                                0.65)),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${shop.products.length} Products',
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF9D7E3F),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(right: 12),
                                    child: Icon(Icons.arrow_forward_ios,
                                        size: 16,
                                        color: const Color(0xFF1A2820)
                                            .withOpacity(0.75)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _noLogo() {
    return Container(
      width: 90,
      height: 90,
      color: const Color(0xFFD4C9A8).withOpacity(0.22),
      child: const Icon(Icons.store,
          size: 35, color: Color(0xFF1A2820)),
    );
  }
}