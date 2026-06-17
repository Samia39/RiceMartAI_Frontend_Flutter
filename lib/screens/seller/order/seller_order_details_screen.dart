import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/order_service.dart';

class SellerOrderDetailScreen extends StatelessWidget {
  final dynamic item;

  SellerOrderDetailScreen({super.key, required this.item});

  final service = OrderService();

  Future<void> update(int id, String status) async {
    await service.updateItemStatus(itemId: id, status: status);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final product = item["product"];
    final order = item["order"];

    return Scaffold(
      appBar: AppBar(title: const Text("Order Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product["name"], style: const TextStyle(fontSize: 20)),

            const SizedBox(height: 10),

            Text("Order: ${order["order_number"]}"),
            Text("Customer: ${order["customer_name"]}"),
            Text("Phone: ${order["phone"]}"),

            const SizedBox(height: 20),

            Text("Status: ${item["status"]}"),

            const SizedBox(height: 20),

            if (item["status"] != "delivered")
              ElevatedButton(
                onPressed: () => update(item["id"], "shipped"),
                child: const Text("Mark as Shipped"),
              ),
          ],
        ),
      ),
    );
  }
}
