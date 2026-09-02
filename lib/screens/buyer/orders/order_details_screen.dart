import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';
import '../review/shop_review_dialog.dart';

class OrderDetailsScreen extends StatelessWidget {
  final dynamic order;

  const OrderDetailsScreen({super.key, required this.order});

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

  Color paymentStatusColor(String status) {
    switch (status) {
      case "paid":
        return AppColors.success;
      case "rejected":
        return AppColors.error;
      default:
        return AppColors.warning;
    }
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

  Map<int, Map<String, dynamic>> groupItemsByShop(List items) {
    final Map<int, Map<String, dynamic>> groups = {};

    for (final item in items) {
      final shop = item["shop"] ?? {};
      final shopId = int.tryParse(shop["id"].toString()) ?? 0;

      groups.putIfAbsent(shopId, () => {"shop": shop, "items": <dynamic>[]});
      (groups[shopId]!["items"] as List).add(item);
    }

    return groups;
  }

  double shopSubtotal(List items) {
    double total = 0;
    for (final item in items) {
      final price = double.tryParse(item["price"].toString()) ?? 0;
      final qty = double.tryParse(item["quantity"].toString()) ?? 0;
      total += price * qty;
    }
    return total;
  }

  Widget buildShopGroups(BuildContext context, List items) {
    final groups = groupItemsByShop(items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.values.map<Widget>((group) {
        final shop = group["shop"] as Map;
        final shopItems = group["items"] as List;
        final subtotal = shopSubtotal(shopItems);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              shopInfoBlock(shop),
              ...shopItems.map((item) {
                final product = item["product"];
                final status = (item["status"] ?? "pending").toString();
                final confirmed = item["customer_confirmed_at"] != null;

                return Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product["name"] ?? "Product",
                              style: AppTextStyles.heading4,
                            ),
                          ),
                          statusChip(status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      infoRow("Price", "Rs ${item["price"]}"),
                      infoRow("Quantity", item["quantity"].toString()),

                      if (status == "delivered" &&
                          order["payment_status"] != "rejected") ...[
                        const SizedBox(height: 10),

                        // =========================
                        // CONFIRM RECEIVED
                        // =========================
                        if (!confirmed)
                          Builder(
                            builder: (ctx) => SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final res = await OrderService()
                                      .confirmReceived(item["id"]);

                                  Get.snackbar(
                                    res["success"] == true
                                        ? "Thanks!"
                                        : "Error",
                                    res["message"] ?? "",
                                  );
                                },
                                child: const Text("Confirm Received"),
                              ),
                            ),
                          )
                        else
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 18,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Received",
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 8),

                        Builder(
                          builder: (ctx) => ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: ctx,
                                builder: (_) =>
                                    ShopReviewDialog(orderItemId: item["id"]),
                              );
                            },
                            child: const Text("Rate Shop"),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Shop subtotal"),
                  Text(
                    "Rs ${subtotal.toStringAsFixed(0)}",
                    style: AppTextStyles.label,
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List items = order["items"] ?? [];
    final bool isRejected = order["payment_status"] == "rejected";

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
                    if (isRejected) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order["payment"]?["rejection_reason"] != null &&
                                        order["payment"]["rejection_reason"]
                                            .toString()
                                            .isNotEmpty
                                    ? "Your payment was rejected: ${order["payment"]["rejection_reason"]}. This order cannot proceed."
                                    : "Your payment was rejected. This order cannot proceed.",
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
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
                          infoRow("Name", order["customer_name"].toString()),
                          infoRow("Phone", order["phone"].toString()),
                          infoRow("Address", order["address"].toString()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                          infoRow("Method", order["payment_method"].toString()),
                          Text(
                            "Payment Status: ${order["payment_status"]}",
                            style: AppTextStyles.label.copyWith(
                              color: paymentStatusColor(
                                order["payment_status"].toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Items by Shop", style: AppTextStyles.heading3),
                    const SizedBox(height: 16),
                    buildShopGroups(context, items),
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
