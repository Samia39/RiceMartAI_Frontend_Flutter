import 'package:flutter/material.dart';

import '../../../core/utils/themes.dart';

class OrderDetailsScreen extends StatelessWidget {
  final dynamic order;

  const OrderDetailsScreen({super.key, required this.order});

  Color statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;

      case "processing":
        return Colors.blue;

      case "shipped":
        return Colors.purple;

      case "delivered":
        return Colors.green;

      case "cancelled":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List items = order["items"] ?? [];

    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: Text("Order #${order["id"]}")),

        body: items.isEmpty
            ? const Center(child: Text("No items found"))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // =========================
                    // CUSTOMER INFO
                    // =========================
                    Container(
                      padding: const EdgeInsets.all(16),

                      decoration: AppDecorations.card,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Customer Information",
                            style: AppTextStyles.heading4,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            "Name: ${order["customer_name"]}",
                            style: AppTextStyles.bodyLarge,
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Phone: ${order["phone"]}",
                            style: AppTextStyles.bodyLarge,
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Address: ${order["address"]}",
                            style: AppTextStyles.bodyLarge,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // PAYMENT INFO
                    // =========================
                    Container(
                      padding: const EdgeInsets.all(16),

                      decoration: AppDecorations.card,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Payment Information",
                            style: AppTextStyles.heading4,
                          ),

                          const SizedBox(height: 12),

                          Text(
                            "Method: ${order["payment_method"]}",
                            style: AppTextStyles.bodyLarge,
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Payment Status: ${order["payment_status"]}",
                            style: AppTextStyles.bodyLarge,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // ORDER ITEMS TITLE
                    // =========================
                    Text("Order Items", style: AppTextStyles.heading3),

                    const SizedBox(height: 16),

                    // =========================
                    // ITEMS
                    // =========================
                    ...items.map((item) {
                      final product = item["product"];

                      final status = item["status"] ?? "pending";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),

                        padding: const EdgeInsets.all(16),

                        decoration: AppDecorations.card,

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              product["name"] ?? "Product",
                              style: AppTextStyles.heading4,
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "Price: Rs ${item["price"]}",
                              style: AppTextStyles.bodyLarge,
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Quantity: ${item["quantity"]}",
                              style: AppTextStyles.bodyLarge,
                            ),

                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),

                              decoration: BoxDecoration(
                                color: statusColor(status),

                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: Text(
                                status.toUpperCase(),

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 10),

                    // =========================
                    // TOTAL
                    // =========================
                    Container(
                      padding: const EdgeInsets.all(16),

                      decoration: AppDecorations.card,

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Text("Total", style: AppTextStyles.heading3),

                          Text(
                            "Rs ${order["total_price"]}",
                            style: AppTextStyles.heading3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
