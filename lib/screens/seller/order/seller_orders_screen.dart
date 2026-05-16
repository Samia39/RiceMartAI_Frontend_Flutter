import 'package:flutter/material.dart';

import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  // =========================
  // ORDERS LIST
  // =========================
  List orders = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    fetchSellerOrders();
  }

  // =========================
  // FETCH SELLER ORDERS
  // =========================
  Future<void> fetchSellerOrders() async {
    try {
      final data = await OrderService().fetchSellerOrders();

      setState(() {
        orders = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // =========================
  // UPDATE ORDER STATUS
  // =========================
  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      final data = await OrderService().updateOrderStatus(
        orderId: orderId,
        status: status,
      );

      // REFRESH ORDERS
      fetchSellerOrders();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data["message"])));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Seller Orders")),

        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            // EMPTY ORDERS
            : orders.isEmpty
            ? Center(
                child: Text("No orders found", style: AppTextStyles.heading3),
              )
            // ORDERS LIST
            : ListView.builder(
                padding: const EdgeInsets.all(16),

                itemCount: orders.length,

                itemBuilder: (context, index) {
                  final item = orders[index];

                  final product = item["product"];
                  final order = item["order"];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),

                    padding: const EdgeInsets.all(16),

                    decoration: AppDecorations.card,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // =========================
                        // PRODUCT NAME
                        // =========================
                        Text(
                          product["name"] ?? "",
                          style: AppTextStyles.heading4,
                        ),

                        const SizedBox(height: 12),

                        // =========================
                        // ORDER ID
                        // =========================
                        Text(
                          "Order ID: ${order["id"]}",
                          style: AppTextStyles.bodyLarge,
                        ),

                        const SizedBox(height: 8),

                        // =========================
                        // QUANTITY
                        // =========================
                        Text(
                          "Quantity: ${item["quantity"]}",
                          style: AppTextStyles.bodyLarge,
                        ),

                        const SizedBox(height: 8),

                        // =========================
                        // PRICE
                        // =========================
                        Text(
                          "Price: Rs ${item["price"]}",
                          style: AppTextStyles.bodyLarge,
                        ),

                        const SizedBox(height: 8),

                        // =========================
                        // ORDER STATUS
                        // =========================
                        Text(
                          "Status: ${order["status"]}",
                          style: AppTextStyles.bodyLarge,
                        ),

                        const SizedBox(height: 8),

                        // =========================
                        // PAYMENT STATUS
                        // =========================
                        Text(
                          "Payment: ${order["payment_status"]}",
                          style: AppTextStyles.bodyLarge,
                        ),

                        const SizedBox(height: 18),

                        // =========================
                        // STATUS UPDATE BUTTONS
                        // =========================
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,

                          children: [
                            // PROCESSING
                            ElevatedButton(
                              onPressed: () {
                                updateOrderStatus(
                                  orderId: order["id"],
                                  status: "processing",
                                );
                              },

                              child: const Text("Processing"),
                            ),

                            // SHIPPED
                            ElevatedButton(
                              onPressed: () {
                                updateOrderStatus(
                                  orderId: order["id"],
                                  status: "shipped",
                                );
                              },

                              child: const Text("Shipped"),
                            ),

                            // DELIVERED
                            ElevatedButton(
                              onPressed: () {
                                updateOrderStatus(
                                  orderId: order["id"],
                                  status: "delivered",
                                );
                              },

                              child: const Text("Delivered"),
                            ),

                            // CANCELLED
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),

                              onPressed: () {
                                updateOrderStatus(
                                  orderId: order["id"],
                                  status: "cancelled",
                                );
                              },

                              child: const Text("Cancel"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
