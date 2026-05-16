import 'package:flutter/material.dart';
import '../../../core/utils/themes.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final items = order["items"] ?? [];

    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        // =========================
        // APP BAR
        // =========================
        appBar: AppBar(title: Text("Order #${order["id"]}")),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // ORDER SUMMARY CARD
              // =========================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order Summary", style: AppTextStyles.heading3),

                    const SizedBox(height: 10),

                    Text("Order ID: #${order["id"]}"),

                    const SizedBox(height: 6),

                    // =========================
                    // ORDER STATUS
                    // =========================
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: order["status"] == "pending"
                            ? Colors.orange.shade100
                            : order["status"] == "processing"
                            ? Colors.blue.shade100
                            : order["status"] == "shipped"
                            ? Colors.purple.shade100
                            : order["status"] == "delivered"
                            ? Colors.green.shade100
                            : Colors.red.shade100,

                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Text(
                        "Status: ${order["status"]}",

                        style: TextStyle(
                          fontWeight: FontWeight.bold,

                          color: order["status"] == "pending"
                              ? Colors.orange
                              : order["status"] == "processing"
                              ? Colors.blue
                              : order["status"] == "shipped"
                              ? Colors.purple
                              : order["status"] == "delivered"
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text("Payment: ${order["payment_status"] ?? "pending"}"),

                    const SizedBox(height: 6),

                    Text(
                      "Total: Rs ${order["total_price"]}",
                      style: AppTextStyles.heading4,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // ITEMS LIST TITLE
              // =========================
              Text("Order Items", style: AppTextStyles.heading3),

              const SizedBox(height: 10),

              // =========================
              // ITEMS LIST
              // =========================
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,

                itemBuilder: (context, index) {
                  final item = items[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: AppDecorations.card,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PRODUCT NAME
                        Text(
                          item["product"]?["name"] ?? "Unknown Product",
                          style: AppTextStyles.heading4,
                        ),

                        const SizedBox(height: 6),

                        // SHOP INFO
                        Text(
                          "Shop: ${item["shop"]?["name"] ?? "Unknown Shop"}",
                          style: AppTextStyles.bodyLarge,
                        ),

                        const SizedBox(height: 6),

                        // PRICE + QTY
                        Text(
                          "Price: Rs ${item["price"]} × ${item["quantity"]}",
                        ),

                        const SizedBox(height: 6),

                        // SUBTOTAL
                        Text(
                          "Subtotal: Rs ${(item["price"] * item["quantity"])}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // =========================
              // TOTAL BOX (BOTTOM)
              // =========================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card,

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text("Grand Total", style: AppTextStyles.heading3),

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
