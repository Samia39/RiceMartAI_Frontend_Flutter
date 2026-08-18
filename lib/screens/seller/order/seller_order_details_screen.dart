import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';

class SellerOrderDetailScreen extends StatelessWidget {
  final dynamic item;

  SellerOrderDetailScreen({super.key, required this.item});

  final service = OrderService();

  Future<void> update(BuildContext context, int id, String status) async {
    final res = await service.updateItemStatus(itemId: id, status: status);

    Get.snackbar(
      res["success"] == true ? "Success" : "Error",
      res["message"] ?? "",
    );

    if (res["success"] == true) Get.back();
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodyMedium,
          children: [
            TextSpan(text: "$label: ", style: AppTextStyles.label),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Color statusColor(String status) {
    switch (status) {
      case "processing":
        return AppColors.warning;
      case "shipped":
        return AppColors.info;
      case "delivered":
        return AppColors.success;
      case "cancelled":
        return AppColors.error;
      default:
        return AppColors.labelSecondary;
    }
  }

  Widget statusChip(String status) {
    final color = statusColor(status);

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: AppTextStyles.label.copyWith(color: color, fontSize: 11.5),
      ),
      backgroundColor: color.withOpacity(0.15),
      side: BorderSide(color: color.withOpacity(0.45)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  // Only the 4 fields needed: shop name, owner, location, city.
  Widget shopInfoBlock(Map shop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.golden.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.golden.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shop["shop_name"]?.toString() ?? "Shop",
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: 2),
          infoRow("Owner", shop["owner_name"]?.toString() ?? "-"),
          infoRow("Location", shop["address"]?.toString() ?? "-"),
          infoRow("City", shop["city"]?.toString() ?? "-"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = item["product"];
    final order = item["order"];
    final shop = item["shop"] ?? {};
    final status = item["status"].toString();

    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Order Detail")),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 40 : 16,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      shopInfoBlock(shop),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppDecorations.card,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product["name"],
                                    style: AppTextStyles.heading3,
                                  ),
                                ),
                                statusChip(status),
                              ],
                            ),

                            const SizedBox(height: 14),

                            infoRow("Order", order["order_number"].toString()),
                            infoRow(
                              "Customer",
                              order["customer_name"].toString(),
                            ),
                            infoRow("Phone", order["phone"].toString()),

                            // No cancel button here — sellers only see paid, approved
                            // orders and can only progress them, never cancel.
                            if (status != "delivered") ...[
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => update(
                                      context,
                                      item["id"],
                                      "processing",
                                    ),
                                    child: const Text("Processing"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        update(context, item["id"], "shipped"),
                                    child: const Text("Shipped"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => update(
                                      context,
                                      item["id"],
                                      "delivered",
                                    ),
                                    child: const Text("Delivered"),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
