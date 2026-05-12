import 'package:flutter/material.dart';

import '../../../core/services/cart_service.dart';
import '../../../core/utils/themes.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

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

  void loadCart() {
    cart = CartService().getCart();

    total = CartService().totalPrice();

    setState(() {});
  }

  void removeItem(int riceId) {
    CartService().removeItem(riceId);

    loadCart();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Item removed from cart")));
  }

  void increaseQuantity(int index) {
    cart[index]["quantity"]++;

    CartService().updateQuantity(
      riceId: cart[index]["id"],
      quantity: cart[index]["quantity"],
    );

    loadCart();
  }

  void decreaseQuantity(int index) {
    if (cart[index]["quantity"] > 1) {
      cart[index]["quantity"]--;

      CartService().updateQuantity(
        riceId: cart[index]["id"],
        quantity: cart[index]["quantity"],
      );

      loadCart();
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
                              // NAME
                              Text(item["name"], style: AppTextStyles.heading4),

                              const SizedBox(height: 10),

                              // PRICE
                              Text(
                                "Price: Rs ${item["price"]}",

                                style: AppTextStyles.bodyLarge,
                              ),

                              const SizedBox(height: 10),

                              // STOCK
                              Text(
                                "Stock: ${item["stock"]} KG",

                                style: AppTextStyles.bodyLarge,
                              ),

                              const SizedBox(height: 16),

                              // QUANTITY
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      decreaseQuantity(index);
                                    },

                                    icon: const Icon(Icons.remove),
                                  ),

                                  Text(
                                    item["quantity"].toString(),

                                    style: AppTextStyles.heading4,
                                  ),

                                  IconButton(
                                    onPressed: () {
                                      increaseQuantity(index);
                                    },

                                    icon: const Icon(Icons.add),
                                  ),

                                  const Spacer(),

                                  // REMOVE
                                  IconButton(
                                    onPressed: () {
                                      removeItem(item["id"]);
                                    },

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

                  // TOTAL
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
                            onPressed: () {},

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
