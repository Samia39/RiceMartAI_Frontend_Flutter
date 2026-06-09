import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final Map order;

  const AdminOrderDetailsScreen({super.key, required this.order});

  @override
  State<AdminOrderDetailsScreen> createState() =>
      _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  late Map order;

  @override
  void initState() {
    super.initState();
    order = widget.order;
  }

  Future<void> updateStatus(String status) async {
    final result = await OrderService().updateOrderStatus(
      orderId: order["id"],
      status: status,
    );

    Get.snackbar(
      "Updated",
      result["message"] ?? "Order updated",
      snackPosition: SnackPosition.BOTTOM,
    );

    setState(() {
      order["status"] = status;
    });
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

            ...items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: AppDecorations.card,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item["product"]["name"]),
                    Text("x${item["quantity"]}"),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            Text("Update Status", style: AppTextStyles.heading3),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: [
                statusBtn("processing"),
                statusBtn("shipped"),
                statusBtn("delivered"),
                statusBtn("cancelled"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget statusBtn(String status) {
    return ElevatedButton(
      onPressed: () => updateStatus(status),
      child: Text(status.toUpperCase()),
    );
  }
}
