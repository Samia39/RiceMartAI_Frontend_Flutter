import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';
import '../../../core/services/product_service.dart';
import '../../../core/utils/themes.dart';
import '../../../core/services/cart_service.dart';

class AllRiceScreen extends StatefulWidget {
  final VoidCallback? onCartUpdated;

  const AllRiceScreen({
    super.key,
    this.onCartUpdated,
    required String initialSearchQuery,
  });

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
  Widget productCard(Map<String, dynamic> product, double imageHeight) {
    return GestureDetector(
      // OPEN DETAIL SCREEN
      onTap: () async {
        // WAIT FOR RETURN VALUE
        final result = await Get.toNamed(
          AppRoutes.riceDetails,
          arguments: product,
        );

        // REFRESH UI WHEN CART UPDATED
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
            // IMAGE
            Container(
              height: imageHeight,
              width: double.infinity,

              decoration: BoxDecoration(
                color: AppColors.cream,

                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),

              child: const Icon(
                Icons.rice_bowl,
                size: 50,
                color: AppColors.darkGreen,
              ),
            ),

            // CONTENT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // PRODUCT NAME
                    Text(
                      product["name"] ?? "",

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: AppTextStyles.heading4.copyWith(fontSize: 15),
                    ),

                    const SizedBox(height: 4),

                    // CATEGORY
                    Text(
                      product["rice_category"]?["name"] ?? "",

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),

                    const Spacer(),

                    // PRICE + CART
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Rs ${product["price"]}/KG",

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: AppTextStyles.heading4.copyWith(
                              color: AppColors.darkGreen,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        Container(
                          height: 34,
                          width: 34,

                          decoration: BoxDecoration(
                            color: AppColors.darkGreen,

                            borderRadius: BorderRadius.circular(10),
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
                              size: 18,
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

    int crossAxisCount = 2;

    double childAspectRatio = 0.78;

    double imageHeight = 110;

    // MOBILE SMALL
    if (width < 360) {
      crossAxisCount = 2;
      childAspectRatio = 0.72;
      imageHeight = 90;
    }
    // TABLET
    else if (width > 700) {
      crossAxisCount = 3;
      childAspectRatio = 0.85;
      imageHeight = 140;
    }

    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Rice Marketplace")),

        body: SafeArea(
          child: Column(
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
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              // EMPTY
              else if (filteredProducts.isEmpty)
                const Expanded(child: Center(child: Text("No products found")))
              // GRID
              else
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    itemCount: filteredProducts.length,

                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,

                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,

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
