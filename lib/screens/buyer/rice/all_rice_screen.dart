import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
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
  List<Map<String, dynamic>> categories = [];

  bool isLoading = true;
  bool categoriesLoading = true;

  final searchController = TextEditingController();

  int? selectedCategoryId;

  String? get _effectiveInitialQuery {
    if (widget.initialSearchQuery != null &&
        widget.initialSearchQuery!.isNotEmpty) {
      return widget.initialSearchQuery;
    }
    final args = Get.arguments;
    if (args is Map && args['initialSearchQuery'] is String) {
      return args['initialSearchQuery'] as String;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchCategories();
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

    final initialQuery = _effectiveInitialQuery;

    if (initialQuery != null && initialQuery.isNotEmpty) {
      searchController.text = initialQuery;
    }

    applyFilters();
  }

  // =========================
  // FETCH CATEGORIES (for the browse row)
  // =========================
  Future<void> fetchCategories() async {
    final data = await ProductService().fetchCategories();

    if (!mounted) return;

    setState(() {
      categories = data;
      categoriesLoading = false;
    });
  }

  // =========================
  // APPLY BOTH TEXT SEARCH + CATEGORY FILTER TOGETHER
  // =========================
  void applyFilters() {
    final query = searchController.text.toLowerCase();

    final result = productList.where((product) {
      final name = product["name"].toString().toLowerCase();
      final categoryName =
          product["rice_category"]?["name"].toString().toLowerCase() ?? "";
      final categoryId = product["rice_category"]?["id"];

      final matchesText =
          query.isEmpty || name.contains(query) || categoryName.contains(query);

      final matchesCategory =
          selectedCategoryId == null ||
          (categoryId != null &&
              int.tryParse(categoryId.toString()) == selectedCategoryId);

      return matchesText && matchesCategory;
    }).toList();

    setState(() {
      filteredProducts = result;
    });
  }

  void searchProducts(String value) {
    applyFilters();
  }

  void onCategoryTap(int categoryId) {
    setState(() {
      selectedCategoryId = selectedCategoryId == categoryId ? null : categoryId;
    });
    applyFilters();
  }

  // =========================
  // BROWSE BY CATEGORY ROW
  // =========================
  Widget categoryBrowseRow() {
    if (categoriesLoading) {
      return const SizedBox(
        height: 90,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final id = int.tryParse(category["id"].toString());
          final isSelected = selectedCategoryId == id;
          final imageUrl = category["image_url"];

          return GestureDetector(
            onTap: () {
              if (id != null) onCategoryTap(id);
            },
            child: SizedBox(
              width: 68,
              child: Column(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.darkGreen
                            : AppColors.darkGreen.withOpacity(0.15),
                        width: isSelected ? 2.5 : 1,
                      ),
                      color: AppColors.cream.withOpacity(0.6),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.rice_bowl,
                              color: AppColors.darkGreen,
                            ),
                          )
                        : const Icon(
                            Icons.rice_bowl,
                            color: AppColors.darkGreen,
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category["name"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? AppColors.darkGreen : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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
        clipBehavior: Clip.antiAlias,
        decoration: AppDecorations.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: imageHeight,
              width: double.infinity,
              color: AppColors.cream.withOpacity(0.5),
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
                              Get.find<CartService>().addToCart(
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
        appBar: AppBar(title: const Text("Rice Marketplace")),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),

              // BROWSE BY CATEGORY
              categoryBrowseRow(),

              // ACTIVE CATEGORY FILTER CHIP
              if (selectedCategoryId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
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
                            Text(
                              "Category: ${categories.firstWhere((c) => int.tryParse(c["id"].toString()) == selectedCategoryId)["name"]}",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.darkGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() => selectedCategoryId = null);
                                applyFilters();
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
                        if (selectedCategoryId != null ||
                            searchController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextButton(
                              onPressed: () {
                                searchController.clear();
                                setState(() => selectedCategoryId = null);
                                applyFilters();
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
