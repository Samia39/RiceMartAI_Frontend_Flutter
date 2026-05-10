import 'package:flutter/material.dart';

import '../../../core/utils/themes.dart';

import '../shops/shop_details_screen.dart';

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
    final rice = widget.rice;

    final shop = rice["shop"];

    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: Text(rice["name"] ?? "")),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // PRODUCT IMAGE
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

              // PRODUCT INFO
              Container(
                padding: const EdgeInsets.all(18),

                decoration: AppDecorations.card,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(rice["name"] ?? "", style: AppTextStyles.heading2),

                    const SizedBox(height: 16),

                    Text(
                      "Rs ${rice["price"]} / KG",

                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.darkGreen,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Available Stock: ${rice["stock"]} KG",

                      style: AppTextStyles.bodyLarge,
                    ),

                    const SizedBox(height: 24),

                    // QUANTITY
                    Text("Quantity", style: AppTextStyles.heading4),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        // MINUS
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

                        // PLUS
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

              // ADD TO CART
              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: () {},

                  icon: const Icon(Icons.shopping_cart),

                  label: const Text("Add To Cart"),
                ),
              ),

              const SizedBox(height: 14),

              // BUY NOW
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

              // CHAT SELLER
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

              // GO TO SHOP
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
