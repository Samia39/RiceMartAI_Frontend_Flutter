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
            : ListView.builder(
                padding: const EdgeInsets.all(16),

                itemCount: items.length,

                itemBuilder: (context, index) {
                  final item = items[index];

                  final product = item["product"];

                  final status = item["status"] ?? "pending";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),

                    padding: const EdgeInsets.all(16),

                    decoration: AppDecorations.card,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // PRODUCT NAME
                        Text(
                          product["name"] ?? "Product",
                          style: AppTextStyles.heading4,
                        ),

                        const SizedBox(height: 10),

                        // PRICE
                        Text(
                          "Price: Rs ${item["price"]}",
                          style: AppTextStyles.bodyLarge,
                        ),

                        const SizedBox(height: 8),

                        // QUANTITY
                        Text(
                          "Quantity: ${item["quantity"]}",
                          style: AppTextStyles.bodyLarge,
                        ),

                        const SizedBox(height: 12),

                        // STATUS
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
                },
              ),
      ),
    );
  }
}
