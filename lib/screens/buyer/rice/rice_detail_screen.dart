import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/themes.dart';
import 'package:frontend/routes/app_routes.dart';
import '../../../core/services/cart_service.dart';

class RiceDetailScreen extends StatefulWidget {
  const RiceDetailScreen({super.key});

  @override
  State<RiceDetailScreen> createState() => _RiceDetailScreenState();
}

class _RiceDetailScreenState extends State<RiceDetailScreen> {
  int quantity = 1;

  // ✅ Base URL for images
  final String imageBaseUrl = "http://ricemart.sandbox.pk/storage/";

  // =========================
  // HELPER: Build image URL
  // =========================
  String? _getImageUrl(Map<String, dynamic> product) {
    final raw =
        product["image"] ??
        product["image_url"] ??
        product["photo"] ??
        product["thumbnail"] ??
        product["img"];

    if (raw == null || raw.toString().trim().isEmpty) return null;

    final str = raw.toString().trim();
    if (str.startsWith("http://") || str.startsWith("https://")) {
      return str;
    }
    return "$imageBaseUrl$str";
  }

  @override
  Widget build(BuildContext context) {
    final product = Get.arguments as Map<String, dynamic>;
    final shop = product["shop"];
    final imageUrl = _getImageUrl(product);

    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(product["name"] ?? "")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // ✅ PRODUCT IMAGE
              // =========================
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          height: 280,
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
                                color: AppColors.darkGreen,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.rice_bowl,
                                size: 120,
                                color: AppColors.darkGreen,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.rice_bowl,
                            size: 120,
                            color: AppColors.darkGreen,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // =========================
              // PRODUCT INFO
              // =========================
              Container(
                padding: const EdgeInsets.all(18),
                decoration: AppDecorations.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PRODUCT NAME
                    Text(product["name"] ?? "", style: AppTextStyles.heading2),

                    const SizedBox(height: 16),

                    // PRICE
                    Text(
                      "Rs ${product["price"]} / KG",
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.darkGreen,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // STOCK
                    Text(
                      "Available Stock: ${product["stock"]} KG",
                      style: AppTextStyles.bodyLarge,
                    ),

                    const SizedBox(height: 10),

                    // CATEGORY
                    Text(
                      "Category: ${product["rice_category"]?["name"] ?? "Rice"}",
                      style: AppTextStyles.bodyLarge,
                    ),

                    const SizedBox(height: 24),

                    // =========================
                    // QUANTITY SECTION
                    // =========================
                    Text("Quantity", style: AppTextStyles.heading4),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        // MINUS BUTTON
                        IconButton(
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.remove_circle,
                            size: 34,
                            color: AppColors.darkGreen,
                          ),
                        ),

                        // QUANTITY BOX
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            quantity.toString(),
                            style: AppTextStyles.heading4,
                          ),
                        ),

                        // PLUS BUTTON
                        IconButton(
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                          icon: const Icon(
                            Icons.add_circle,
                            size: 34,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // ADD TO CART BUTTON
              // =========================
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    CartService().addToCart(rice: product, quantity: quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${product["name"]} added to cart"),
                      ),
                    );
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text("Add To Cart"),
                ),
              ),

              const SizedBox(height: 14),

              // =========================
              // GO TO SHOP BUTTON
              // =========================
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(AppRoutes.shopDetails, arguments: shop);
                  },
                  icon: const Icon(Icons.store),
                  label: const Text("Go To Shop"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
