import 'package:flutter/material.dart';
import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';
import 'package:get/get.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, dynamic>? order;
  Map<String, dynamic> get orderData => Get.arguments as Map<String, dynamic>;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrder();
  }

  // =========================
  // FETCH FRESH ORDER
  // =========================
  Future<void> fetchOrder() async {
    try {
      final data = await OrderService().getOrderDetails(orderData["id"]);

      if (!mounted) return;

      setState(() {
        order = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final items = order?["items"] ?? [];

    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // =========================
        // APP BAR
        // =========================
        appBar: AppBar(title: Text("Order #${order?["id"]}")),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // ORDER SUMMARY
              // =========================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order Summary", style: AppTextStyles.heading3),

                    const SizedBox(height: 10),

                    Text("Order ID: #${order?["id"]}"),

                    const SizedBox(height: 10),

                    Text("Payment: ${order?["payment_status"] ?? "pending"}"),

                    const SizedBox(height: 10),

                    Text(
                      "Total: Rs ${order?["total_price"]}",
                      style: AppTextStyles.heading4,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

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
                        Text(
                          item["product"]?["name"] ?? "Unknown Product",
                          style: AppTextStyles.heading4,
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Shop: ${item["shop"]?["name"] ?? "Unknown Shop"}",
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Price: Rs ${item["price"]} × ${item["quantity"]}",
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Subtotal: Rs ${(item["price"] * item["quantity"])}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            color: _statusColor(item["status"]),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Text(
                            "Status: ${item["status"]}",

                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _statusTextColor(item["status"]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // =========================
              // TOTAL
              // =========================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card,

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text("Grand Total", style: AppTextStyles.heading3),

                    Text(
                      "Rs ${order?["total_price"]}",
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

  // =========================
  // STATUS COLORS
  // =========================
  Color _statusColor(String? status) {
    switch (status) {
      case "pending":
        return Colors.orange.shade100;
      case "processing":
        return Colors.blue.shade100;
      case "shipped":
        return Colors.purple.shade100;
      case "delivered":
        return Colors.green.shade100;
      default:
        return Colors.red.shade100;
    }
  }

  Color _statusTextColor(String? status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "processing":
        return Colors.blue;
      case "shipped":
        return Colors.purple;
      case "delivered":
        return Colors.green;
      default:
        return Colors.red;
    }
  }
}
