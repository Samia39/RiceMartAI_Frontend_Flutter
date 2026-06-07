import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/themes.dart';
import 'payment_details_screen.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final dynamic order;

  const AdminOrderDetailsScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailsScreen> createState() =>
      _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  late Map<String, dynamic> orderData;

  @override
  void initState() {
    super.initState();
    orderData = Map<String, dynamic>.from(widget.order);
  }

  // =========================
  // STATUS COLOR
  // =========================
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

  // =========================
  // NEXT VALID ACTIONS FLOW
  // =========================
  List<String> getNextStatuses(String currentStatus) {
    switch (currentStatus) {
      case "pending":
        return ["processing", "cancelled"];

      case "processing":
        return ["shipped", "cancelled"];

      case "shipped":
        return ["delivered"];

      default:
        return [];
    }
  }

  // =========================
  // UPDATE STATUS (CONNECT API HERE)
  // =========================
  Future<void> updateOrderStatus({
    required int itemIndex,
    required String newStatus,
  }) async {
    try {
      // 🔥 CONNECT YOUR BACKEND HERE
      // await OrderService.updateStatus(
      //   orderId: orderData["id"],
      //   itemId: orderData["items"][itemIndex]["id"],
      //   status: newStatus,
      // );

      setState(() {
        orderData["items"][itemIndex]["status"] = newStatus;
      });

      Get.snackbar(
        "Success",
        "Status updated to $newStatus",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update status",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List items = orderData["items"] ?? [];

    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: Text("Order #${orderData["id"]}")),

        body: ListView(
          padding: const EdgeInsets.all(16),

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
                    orderData["customer_name"],
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Phone: ${orderData["phone"]}",
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Address: ${orderData["address"]}",
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Total: Rs ${orderData["total_price"]}",
                    style: AppTextStyles.heading4,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =========================
            // ITEMS LIST
            // =========================
            ...List.generate(items.length, (index) {
              final item = items[index];
              final product = item["product"];
              final shop = item["shop"];
              final status = item["status"] ?? "pending";

              final availableActions = getNextStatuses(status);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product["name"], style: AppTextStyles.heading4),

                    const SizedBox(height: 10),

                    Text(
                      "Shop: ${shop["name"]}",
                      style: AppTextStyles.bodyLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Quantity: ${item["quantity"]}",
                      style: AppTextStyles.bodyLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Price: Rs ${item["price"]}",
                      style: AppTextStyles.bodyLarge,
                    ),

                    const SizedBox(height: 12),

                    // =========================
                    // SMART STATUS UI
                    // =========================
                    Builder(
                      builder: (context) {
                        if (availableActions.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
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
                          );
                        }

                        return Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // CURRENT STATUS
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
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

                            // ACTION BUTTONS
                            ...availableActions.map((newStatus) {
                              return ElevatedButton(
                                onPressed: () {
                                  updateOrderStatus(
                                    itemIndex: index,
                                    newStatus: newStatus,
                                  );
                                },
                                child: Text(newStatus.toUpperCase()),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // =========================
            // PAYMENT BUTTON
            // =========================
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => PaymentDetailsScreen(order: orderData));
                },
                child: const Text("View Payment"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
