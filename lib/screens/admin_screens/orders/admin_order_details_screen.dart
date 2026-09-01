import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  const AdminOrderDetailsScreen({super.key});

  // Reached via Get.toNamed(AppRoutes.adminOrderDetail,
  // arguments: {"order": o, "isHistory": isHistory})
  Map get _args => Get.arguments as Map;
  Map get order => _args["order"] as Map;
  bool get isHistory => _args["isHistory"] as bool? ?? false;

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
      if (mounted) setState(() => isUpdating = false);
    }
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

  Widget buildShopGroups() {
    final items = order["items"] as List;
    final groups = groupItemsByShop(items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.values.map<Widget>((group) {
        final shop = group["shop"] as Map;
        final shopItems = group["items"] as List;
        final subtotal = shopSubtotal(shopItems);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: AppDecorations.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              shopInfoBlock(shop),
              ...shopItems.map<Widget>((item) {
                final itemStatus = item["status"].toString();

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
                              item["product"]["name"],
                              style: AppTextStyles.heading4,
                            ),
                          ),
                          statusChip(itemStatus),
                        ],
                      ),
                      const SizedBox(height: 6),
                      infoRow("Quantity", item["quantity"].toString()),
                      if (!widget.isHistory) ...[
                        const SizedBox(height: 8),
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
                            // Admin-only — sellers can't cancel a paid order.
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: AppColors.cream,
                              ),
                              onPressed: () =>
                                  updateItemStatus(item["id"], "cancelled"),
                              child: const Text("Cancel"),
                            ),
                          ],
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
    final orderStatus = order["status"].toString();
    final paymentStatus = order["payment_status"].toString();

    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Order Details")),
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
                                    "Order #: ${order["order_number"]}",
                                    style: AppTextStyles.heading3,
                                  ),
                                ),
                                statusChip(orderStatus),
                              ],
                            ),
                            const SizedBox(height: 12),
                            infoRow(
                              "Customer",
                              order["customer_name"].toString(),
                            ),
                            infoRow("Phone", order["phone"].toString()),
                            infoRow("Address", order["address"].toString()),
                            const SizedBox(height: 6),
                            Text(
                              "Payment: $paymentStatus",
                              style: AppTextStyles.label.copyWith(
                                color: paymentStatusColor(paymentStatus),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text("Items by shop", style: AppTextStyles.heading3),
                      const SizedBox(height: 10),
                      buildShopGroups(),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppDecorations.card,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Order Total", style: AppTextStyles.heading3),
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
          },
        ),
      ),
    );
  }
}
