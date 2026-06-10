import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final Map order;
  final bool isHistory;

  const AdminOrderDetailsScreen({
    super.key,
    required this.order,
    this.isHistory = false,
  });

  @override
  State<AdminOrderDetailsScreen> createState() =>
      _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  late Map order;

  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    order = widget.order;
  }

  Future<void> updateItemStatus(int itemId, String status) async {
    if (isUpdating) return;

    setState(() => isUpdating = true);

    try {
      final result = await OrderService().adminUpdateItemStatus(
        itemId: itemId,
        status: status,
      );

      Get.snackbar(
        result["success"] == true ? "Success" : "Error",
        result["message"] ?? "",
        snackPosition: SnackPosition.BOTTOM,
      );

      if (result["success"] == true && mounted) {
        setState(() {
          final item = order["items"].firstWhere((e) => e["id"] == itemId);

          item["status"] = status;

          if (result["order_status"] != null) {
            order["status"] = result["order_status"];
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = order["items"];

    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order #: ${order["order_number"]}",
                    style: AppTextStyles.heading3,
                  ),

                  const SizedBox(height: 10),

                  Text("Customer: ${order["customer_name"]}"),
                  Text("Phone: ${order["phone"]}"),
                  Text("Address: ${order["address"]}"),

                  const SizedBox(height: 10),

                  Text("Payment: ${order["payment_status"]}"),
                  Text("Status: ${order["status"]}"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text("Items", style: AppTextStyles.heading3),

            const SizedBox(height: 10),

            ...items.map<Widget>((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: AppDecorations.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["product"]["name"],
                      style: AppTextStyles.heading4,
                    ),

                    const SizedBox(height: 6),

                    Text("Quantity: ${item["quantity"]}"),

                    Text("Item Status: ${item["status"]}"),

                    const SizedBox(height: 10),

                    if (!widget.isHistory)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                updateItemStatus(item["id"], "processing"),
                            child: const Text("Processing"),
                          ),

                          ElevatedButton(
                            onPressed: () =>
                                updateItemStatus(item["id"], "shipped"),
                            child: const Text("Shipped"),
                          ),

                          ElevatedButton(
                            onPressed: () =>
                                updateItemStatus(item["id"], "delivered"),
                            child: const Text("Delivered"),
                          ),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () =>
                                updateItemStatus(item["id"], "cancelled"),
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
