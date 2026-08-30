import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/utils/themes.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/shop_reviews_section.dart'; // ✅ adjust path to match your project structure

class ShopDetailsScreen extends StatefulWidget {
  const ShopDetailsScreen({super.key});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  Map<String, dynamic> get shop => Get.arguments as Map<String, dynamic>;

  List<Map<String, dynamic>> productList = [];
  bool isLoading = true;
  bool isStartingChat = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final data = await ProductService().fetchShopProducts(shopId: shop["id"]);
    setState(() {
      productList = data;
      isLoading = false;
    });
  }

  // =============================================
  // Opens or creates a conversation with the shop
  // =============================================
  Future<void> openChat() async {
    setState(() => isStartingChat = true);

    final result = await ChatService().startConversation(
      shopId: shop["id"] as int,
    );

    setState(() => isStartingChat = false);

    if (result["conversation_id"] != null) {
      Get.toNamed(
        AppRoutes.chat,
        arguments: {
          "conversation_id": result["conversation_id"],
          "other_name": shop["shop_name"] ?? "Shop",
        },
      );
    } else {
      Get.snackbar("Error", "Could not start chat. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // SHOP INFO CARD
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

              const SizedBox(height: 16),

              // =========================
              // CHAT WITH SELLER BUTTON
              // =========================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isStartingChat ? null : openChat,
                  icon: isStartingChat
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.chat_bubble_outline),
                  label: Text(
                    isStartingChat ? "Opening..." : "Chat with Seller",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // =========================
              // TITLE
              // =========================
              Text("Available Products", style: AppTextStyles.heading3),
              const SizedBox(height: 14),

              if (isLoading) const Center(child: CircularProgressIndicator()),

              if (!isLoading && productList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: AppDecorations.card,
                  child: const Text("No products available"),
                ),

              if (!isLoading && productList.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, index) {
                    final product = productList[index];
                    final imageUrl = ProductService.getImageUrl(product);

                    // ✅ Whole card is now clickable -> goes to product details
                    return GestureDetector(
                      onTap: () async {
                        final result = await Get.toNamed(
                          AppRoutes.riceDetails,
                          arguments: product,
                        );
                        if (result == true) {
                          setState(() {});
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: AppDecorations.card,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ PRODUCT IMAGE
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                height: 90,
                                width: double.infinity,
                                color: AppColors.cream,
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 90,
                                        errorBuilder: (c, e, s) => const Icon(
                                          Icons.rice_bowl,
                                          size: 50,
                                          color: AppColors.darkGreen,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.rice_bowl,
                                        size: 50,
                                        color: AppColors.darkGreen,
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              product["name"] ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.heading4,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product["rice_category"]?["name"] ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: 8),

                            // ✅ PRICE + ADD TO CART
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Rs ${product["price"]}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.heading4.copyWith(
                                      color: AppColors.darkGreen,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    CartService().addToCart(
                                      rice: product,
                                      quantity: 1,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "${product["name"]} added to cart",
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.darkGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.add_shopping_cart_rounded,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${product["stock"]} KG left",
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // =========================
              // SHOP REVIEWS
              // Visible to any customer viewing this shop, so they
              // can see what past buyers said before purchasing.
              // =========================
              Text("Customer Reviews", style: AppTextStyles.heading3),
              const SizedBox(height: 14),
              ShopReviewsSection(shopId: shop["id"] as int),
            ],
          ),
        ),
      ),
    );
  }
}
