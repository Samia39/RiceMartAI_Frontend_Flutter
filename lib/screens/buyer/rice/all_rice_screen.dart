// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';
import '../../../core/services/product_service.dart';
import '../../../core/utils/themes.dart';
import '../../../core/services/cart_service.dart';

class AllRiceScreen extends StatefulWidget {
  final VoidCallback? onCartUpdated;
  final String? initialSearchQuery;

  const AllRiceScreen({super.key, this.onCartUpdated, this.initialSearchQuery});

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
      isLoading = false;
    });

    if (widget.initialSearchQuery != null &&
        widget.initialSearchQuery!.isNotEmpty) {
      searchController.text = widget.initialSearchQuery!;
      searchProducts(widget.initialSearchQuery!);
    } else {
      setState(() {
        filteredProducts = data;
      });
    }
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
  Widget productCard(Map<String, dynamic> product, double imageHeight) {
    final imageUrl = ProductService.getImageUrl(product);

    return GestureDetector(
      onTap: () async {
        final result = await Get.toNamed(
          AppRoutes.riceDetails,
          arguments: product,
        );
        if (result == true) {
          setState(() {});
          widget.onCartUpdated?.call();
        }
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
            // ✅ IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Container(
                height: imageHeight,
                width: double.infinity,
                color: AppColors.cream,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        height: imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              color: AppColors.darkGreen,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.rice_bowl,
                              size: 50,
                              color: AppColors.darkGreen,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.rice_bowl,
                          size: 50,
                          color: AppColors.darkGreen,
                        ),
                      ),
              ),
            ),

            // CONTENT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product["name"] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading4.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product["rice_category"]?["name"] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[700],
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Rs ${product["price"]}/KG",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.heading4.copyWith(
                              color: AppColors.darkGreen,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          height: 28,
                          width: 28,
                          decoration: BoxDecoration(
                            color: AppColors.darkGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              CartService().addToCart(
                                rice: product,
                                quantity: 1,
                              );
                              setState(() {});
                              widget.onCartUpdated?.call();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${product["name"]} added to cart",
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Bound the card's own width instead of a fixed column count —
    // this keeps cards small and consistent on both mobile and wide
    // desktop/web windows, where a fixed crossAxisCount would otherwise
    // stretch each cell (and its aspect-ratio-derived height) hugely.
    double maxCardWidth = 170;
    double childAspectRatio = 0.68;
    double imageHeight = 85;

    if (width < 360) {
      maxCardWidth = 150;
      childAspectRatio = 0.62;
      imageHeight = 75;
    }

    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Rice Marketplace"),
          bottom:
              widget.initialSearchQuery != null &&
                  widget.initialSearchQuery!.isNotEmpty &&
                  searchController.text.isNotEmpty
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(36),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.golden.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.golden.withOpacity(0.60),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 13,
                                color: AppColors.golden,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "AI Filter: ${widget.initialSearchQuery}",
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.darkGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  searchController.clear();
                                  searchProducts('');
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 13,
                                  color: AppColors.darkGreen.withOpacity(0.60),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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

              if (isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filteredProducts.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: AppColors.darkGreen.withOpacity(0.30),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No products found",
                          style: AppTextStyles.bodyLarge,
                        ),
                        if (widget.initialSearchQuery != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextButton(
                              onPressed: () {
                                searchController.clear();
                                searchProducts('');
                              },
                              child: const Text("Show all products"),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredProducts.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: maxCardWidth,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      return productCard(filteredProducts[index], imageHeight);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
