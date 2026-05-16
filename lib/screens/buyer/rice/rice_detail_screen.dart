import 'package:flutter/material.dart';

import '../../../core/utils/themes.dart';

import '../shops/shop_details_screen.dart';
import '../../../core/services/cart_service.dart';

class RiceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> rice;

  const RiceDetailScreen({super.key, required this.rice});

  @override
  State<RiceDetailScreen> createState() => _RiceDetailScreenState();
}

class _RiceDetailScreenState extends State<RiceDetailScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.rice;

    final shop = product["shop"];

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
              // PRODUCT IMAGE
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

                child: const Icon(
                  Icons.rice_bowl,
                  size: 120,
                  color: AppColors.darkGreen,
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
                    // ADD ITEM TO CART
                    CartService().addToCart(rice: product, quantity: quantity);

                    // SHOW MESSAGE
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${product["name"]} added to cart"),
                      ),
                    );

                    // GO BACK + REFRESH CART BADGE
                    Navigator.pop(context, true);
                  },

                  icon: const Icon(Icons.shopping_cart),

                  label: const Text("Add To Cart"),
                ),
              ),

              const SizedBox(height: 14),

              // =========================
              // BUY NOW BUTTON
              // =========================
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: () {},

                  icon: const Icon(Icons.flash_on),

                  label: const Text("Buy Now"),
                ),
              ),

              const SizedBox(height: 14),

              // =========================
              // CHAT SELLER BUTTON
              // =========================
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: () {},

                  icon: const Icon(Icons.chat),

                  label: const Text("Chat Seller"),
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
                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => ShopDetailsScreen(shop: shop),
                      ),
                    );
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
