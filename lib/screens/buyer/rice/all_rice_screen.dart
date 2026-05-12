import 'package:flutter/material.dart';

import '../../../core/services/product_service.dart';
import '../../../core/utils/themes.dart';

import 'rice_detail_screen.dart';

class AllRiceScreen extends StatefulWidget {
  const AllRiceScreen({super.key});

  @override
  State<AllRiceScreen> createState() => _AllRiceScreenState();
}

class _AllRiceScreenState extends State<AllRiceScreen> {
  List<Map<String, dynamic>> productList = [];
  List<Map<String, dynamic>> filteredProducts = [];

  bool isLoading = true;

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    fetchProducts();
  }

  // =========================
  // FETCH ALL PRODUCTS
  // =========================
  Future<void> fetchProducts() async {
    final data = await ProductService().fetchAllProducts();

    setState(() {
      productList = data;
      filteredProducts = data;
      isLoading = false;
    });
  }

  // =========================
  // SEARCH PRODUCTS
  // =========================
  void searchProducts(String value) {
    final result = productList.where((product) {
      final name = product["name"].toString().toLowerCase();

      final category =
          product["rice_category"]?["name"].toString().toLowerCase() ?? "";

      return name.contains(value.toLowerCase()) ||
          category.contains(value.toLowerCase());
    }).toList();

    setState(() {
      filteredProducts = result;
    });
  }

  // =========================
  // PRODUCT CARD
  // =========================
  Widget productCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(builder: (_) => RiceDetailScreen(rice: product)),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),

              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // IMAGE
            Container(
              height: 130,
              width: double.infinity,

              decoration: BoxDecoration(
                color: AppColors.cream,

                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),

              child: const Icon(
                Icons.rice_bowl,
                size: 60,
                color: AppColors.darkGreen,
              ),
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.all(12),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // PRODUCT NAME
                  Text(
                    product["name"] ?? "",

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: AppTextStyles.heading4,
                  ),

                  const SizedBox(height: 4),

                  // CATEGORY
                  Text(
                    "Category: ${product["rice_category"]?["name"] ?? ""}",

                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // PRICE
                  Text(
                    "Rs ${product["price"]}/KG",

                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.darkGreen,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // STOCK
                  Text(
                    "Stock: ${product["stock"]} KG",

                    style: AppTextStyles.bodyMedium,
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
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Rice Marketplace")),

        body: Column(
          children: [
            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(16),

              child: Container(
                decoration: AppDecorations.inputField,

                child: TextField(
                  controller: searchController,

                  onChanged: searchProducts,

                  decoration: const InputDecoration(
                    hintText: "Search rice or category...",
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),

            // LOADING
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            // EMPTY
            else if (filteredProducts.isEmpty)
              const Expanded(child: Center(child: Text("No products found")))
            // GRID
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),

                  itemCount: filteredProducts.length,

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,

                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,

                    childAspectRatio: 0.68,
                  ),

                  itemBuilder: (context, index) {
                    return productCard(filteredProducts[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
