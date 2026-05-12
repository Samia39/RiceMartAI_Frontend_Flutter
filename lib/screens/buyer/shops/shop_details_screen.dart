import 'package:flutter/material.dart';

import '../../../core/services/product_service.dart';
import '../../../core/utils/themes.dart';

class ShopDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> shop;

  const ShopDetailsScreen({super.key, required this.shop});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  List<Map<String, dynamic>> productList = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    fetchProducts();
  }

  // =========================
  // FETCH SHOP PRODUCTS
  // =========================
  Future<void> fetchProducts() async {
    final data = await ProductService().fetchShopProducts(
      shopId: widget.shop["id"],
    );

    setState(() {
      productList = data;

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;

    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: Text(shop["shop_name"] ?? "")),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =========================
              // SHOP INFO
              // =========================
              Container(
                padding: const EdgeInsets.all(16),

                decoration: AppDecorations.card,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      shop["shop_name"] ?? "",
                      style: AppTextStyles.heading2,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Owner: ${shop["owner_name"]}",
                      style: AppTextStyles.bodyLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Phone: ${shop["phone"]}",
                      style: AppTextStyles.bodyLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Address: ${shop["address"]}",
                      style: AppTextStyles.bodyLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      shop["description"] ?? "",
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // =========================
              // TITLE
              // =========================
              Text("Available Products", style: AppTextStyles.heading3),

              const SizedBox(height: 14),

              // =========================
              // LOADING
              // =========================
              if (isLoading) const Center(child: CircularProgressIndicator()),

              // =========================
              // EMPTY
              // =========================
              if (!isLoading && productList.isEmpty)
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(16),

                  decoration: AppDecorations.card,

                  child: const Text("No products available"),
                ),

              // =========================
              // PRODUCT LIST
              // =========================
              if (!isLoading && productList.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: productList.length,

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,

                    mainAxisSpacing: 16,

                    crossAxisSpacing: 16,

                    childAspectRatio: 0.72,
                  ),

                  itemBuilder: (context, index) {
                    final product = productList[index];

                    return Container(
                      padding: const EdgeInsets.all(14),

                      decoration: AppDecorations.card,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // IMAGE
                          Container(
                            height: 90,
                            width: double.infinity,

                            decoration: BoxDecoration(
                              color: AppColors.cream,

                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: const Icon(
                              Icons.rice_bowl,
                              size: 50,
                              color: AppColors.darkGreen,
                            ),
                          ),

                          const SizedBox(height: 12),

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
                            product["rice_category"]?["name"] ?? "",

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: AppTextStyles.bodyMedium,
                          ),

                          const SizedBox(height: 8),

                          // PRICE
                          Text(
                            "Rs ${product["price"]}",

                            style: AppTextStyles.heading4.copyWith(
                              color: AppColors.darkGreen,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // STOCK
                          Text(
                            "${product["stock"]} KG",

                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
