import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';

import '../../../core/services/shop_service.dart';
import '../../../core/utils/themes.dart';

class ShopsScreen extends StatefulWidget {
  const ShopsScreen({super.key});

  @override
  State<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends State<ShopsScreen> {
  bool isLoading = true;

  List<Map<String, dynamic>> shops = [];

  List<Map<String, dynamic>> filteredShops = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    fetchShops();
  }

  // =========================
  // FETCH APPROVED SHOPS
  // =========================
  Future<void> fetchShops() async {
    final data = await ShopService().fetchApprovedShops();

    setState(() {
      shops = data;

      filteredShops = data;

      isLoading = false;
    });
  }

  // =========================
  // SEARCH SHOPS
  // =========================
  void searchShops(String value) {
    if (value.isEmpty) {
      setState(() {
        filteredShops = shops;
      });

      return;
    }

    final results = shops.where((shop) {
      final shopName = shop["shop_name"].toString().toLowerCase();

      final ownerName = shop["owner_name"].toString().toLowerCase();

      final address = shop["address"].toString().toLowerCase();

      return shopName.contains(value.toLowerCase()) ||
          ownerName.contains(value.toLowerCase()) ||
          address.contains(value.toLowerCase());
    }).toList();

    setState(() {
      filteredShops = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Rice Shops")),

        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // SEARCH BAR
                  Padding(
                    padding: const EdgeInsets.all(16),

                    child: Container(
                      decoration: AppDecorations.inputField,

                      child: TextField(
                        controller: searchController,

                        onChanged: searchShops,

                        decoration: const InputDecoration(
                          hintText: "Search shops...",
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),

                  // EMPTY
                  if (filteredShops.isEmpty)
                    const Expanded(child: Center(child: Text("No shops found")))
                  // SHOPS LIST
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),

                        itemCount: filteredShops.length,

                        itemBuilder: (context, index) {
                          final shop = filteredShops[index];

                          return GestureDetector(
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.shopDetails,
                                arguments: shop,
                              );
                            },

                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),

                              padding: const EdgeInsets.all(16),

                              decoration: AppDecorations.card,

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    shop["shop_name"] ?? "",

                                    style: AppTextStyles.heading3,
                                  ),

                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      const Icon(Icons.person),

                                      const SizedBox(width: 8),

                                      Text(
                                        shop["owner_name"] ?? "",

                                        style: AppTextStyles.bodyLarge,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      const Icon(Icons.phone),

                                      const SizedBox(width: 8),

                                      Text(
                                        shop["phone"] ?? "",

                                        style: AppTextStyles.bodyLarge,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      const Icon(Icons.location_on),

                                      const SizedBox(width: 8),

                                      Expanded(
                                        child: Text(
                                          shop["address"] ?? "",

                                          style: AppTextStyles.bodyLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }
}
