import 'package:flutter/material.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/utils/themes.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class CartScreen extends StatefulWidget {
  // =========================
  // CALLBACK FOR CART BADGE
  // =========================
  final VoidCallback? onCartUpdated;

  const CartScreen({super.key, this.onCartUpdated});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List cart = [];
  double total = 0;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  // =========================
  // LOAD CART
  // =========================
  void loadCart() {
    cart = Get.find<CartService>().getCart();
    total = Get.find<CartService>().totalPrice();
    setState(() {});
  }

  // =========================
  // REMOVE ITEM
  // =========================
  void removeItem(int riceId) {
    Get.find<CartService>().removeItem(riceId);
    loadCart();
    widget.onCartUpdated?.call();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Item removed from cart")));
  }

  // =========================
  // INCREASE QUANTITY
  // Stops at available stock instead of going over it.
  // =========================
  void increaseQuantity(int index) {
    final int stock = int.tryParse(cart[index]["stock"].toString()) ?? 0;
    final int currentQty = cart[index]["quantity"];

    if (currentQty >= stock) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Only $stock KG in stock")));
      return;
    }

    final int newQty = Get.find<CartService>().updateQuantity(
      riceId: cart[index]["id"],
      quantity: currentQty + 1,
    );

    cart[index]["quantity"] = newQty;

    loadCart();
    widget.onCartUpdated?.call();
  }

  // =========================
  // DECREASE QUANTITY
  // =========================
  void decreaseQuantity(int index) {
    if (cart[index]["quantity"] > 1) {
      cart[index]["quantity"]--;

      Get.find<CartService>().updateQuantity(
        riceId: cart[index]["id"],
        quantity: cart[index]["quantity"],
      );

      loadCart();
      widget.onCartUpdated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("My Cart")),

        body: cart.isEmpty
            ? Center(
                child: Text("Cart is empty", style: AppTextStyles.heading3),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;

                  // =========================
                  // SINGLE CART ITEM CARD
                  // =========================
                  Widget buildItemCard(int index) {
                    final item = cart[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: AppDecorations.card,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item["name"], style: AppTextStyles.heading4),

                          const SizedBox(height: 10),

                          Text(
                            "Price: Rs ${item["price"]}",
                            style: AppTextStyles.bodyLarge,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Stock: ${item["stock"]} KG",
                            style: AppTextStyles.bodyLarge,
                          ),

                          const SizedBox(height: 16),

                          // =========================
                          // QUANTITY CONTROLS
                          // =========================
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => decreaseQuantity(index),
                                icon: const Icon(Icons.remove),
                              ),

                              Text(
                                item["quantity"].toString(),
                                style: AppTextStyles.heading4,
                              ),

                              IconButton(
                                onPressed: () => increaseQuantity(index),
                                icon: const Icon(Icons.add),
                              ),

                              const Spacer(),

                              IconButton(
                                onPressed: () => removeItem(item["id"]),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  // =========================
                  // CART ITEMS LIST
                  // =========================
                  final itemsList = ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    itemBuilder: (context, index) => buildItemCard(index),
                  );

                  // =========================
                  // TOTAL SECTION
                  // =========================
                  final totalSection = Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppDecorations.card,

                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total", style: AppTextStyles.heading3),
                            Text(
                              "Rs ${total.toStringAsFixed(0)}",
                              style: AppTextStyles.heading3,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 50,

                          child: ElevatedButton(
                            onPressed: () {
                              Get.toNamed(AppRoutes.checkout);
                            },
                            child: const Text("Checkout"),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (!isWide) {
                    // =========================
                    // NARROW LAYOUT (unchanged behavior)
                    // =========================
                    return Column(
                      children: [
                        Expanded(child: itemsList),
                        totalSection,
                      ],
                    );
                  }

                  // =========================
                  // WIDE LAYOUT: items on the left, sticky total on the right
                  // =========================
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: constraints.maxHeight - 32,
                                child: ListView.builder(
                                  itemCount: cart.length,
                                  itemBuilder: (context, index) =>
                                      buildItemCard(index),
                                ),
                              ),
                            ),

                            const SizedBox(width: 24),

                            Expanded(flex: 2, child: totalSection),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
