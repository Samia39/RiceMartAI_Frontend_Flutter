import 'package:flutter/material.dart';
import '../../../core/services/cart_service.dart';
import '../../../core/utils/themes.dart';

import '../../../core/services/order_service.dart';
import 'package:get/get.dart';

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
    cart = CartService().getCart();
    total = CartService().totalPrice();
    setState(() {});
  }

  // =========================
  // REMOVE ITEM
  // =========================
  void removeItem(int riceId) {
    CartService().removeItem(riceId);
    loadCart();
    widget.onCartUpdated?.call();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Item removed from cart")));
  }

  // =========================
  // INCREASE QUANTITY
  // =========================
  void increaseQuantity(int index) {
    cart[index]["quantity"]++;

    CartService().updateQuantity(
      riceId: cart[index]["id"],
      quantity: cart[index]["quantity"],
    );

    loadCart();
    widget.onCartUpdated?.call();
  }

  // =========================
  // DECREASE QUANTITY
  // =========================
  void decreaseQuantity(int index) {
    if (cart[index]["quantity"] > 1) {
      cart[index]["quantity"]--;

      CartService().updateQuantity(
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
            : Column(
                children: [
                  // =========================
                  // CART ITEMS
                  // =========================
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
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
                      },
                    ),
                  ),

                  // =========================
                  // TOTAL SECTION
                  // =========================
                  Container(
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
                            onPressed: () async {
                              final result = await OrderService().checkout();

                              if (result["success"] == true) {
                                // CLEAR CART AFTER SUCCESS
                                CartService().clearCart();

                                setState(() {
                                  cart = [];
                                  total = 0;
                                });

                                widget.onCartUpdated?.call();

                                Get.snackbar(
                                  "Success",
                                  "Order placed successfully",
                                );
                              } else {
                                Get.snackbar(
                                  "Error",
                                  result["message"] ?? "Checkout failed",
                                );
                              }
                            },
                            child: const Text("Checkout"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
