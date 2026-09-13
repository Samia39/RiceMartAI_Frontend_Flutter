import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';
import '../review/shop_review_dialog.dart';
import '../../../routes/app_routes.dart';

class OrderDetailsScreen extends StatefulWidget {
  final dynamic order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late final Set<int> _reviewedItemIds;
  late final Set<int> _confirmedShopIds;
  bool _confirmingShop = false;

  @override
  void initState() {
    super.initState();
    final List items = widget.order["items"] ?? [];
    _reviewedItemIds = items
        .where((item) => item["review"] != null)
        .map<int>((item) => int.tryParse(item["id"].toString()) ?? -1)
        .toSet();

    // A shop counts as "confirmed" only if ALL its items in this
    // order are confirmed.
    final Map<int, List> byShop = {};
    for (final item in items) {
      final shopId = int.tryParse(item["shop"]?["id"].toString() ?? '') ?? 0;
      byShop.putIfAbsent(shopId, () => []).add(item);
    }
    _confirmedShopIds = byShop.entries
        .where((e) => e.value.every((i) => i["customer_confirmed_at"] != null))
        .map((e) => e.key)
        .toSet();
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

  Future<void> confirmShop(int orderId, int shopId) async {
    if (_confirmingShop) return;
    setState(() => _confirmingShop = true);

    final res = await OrderService().confirmShopReceived(orderId, shopId);

    Get.snackbar(
      res["success"] == true ? "Thanks!" : "Error",
      res["message"] ?? "",
    );

    if (res["success"] == true) {
      setState(() => _confirmedShopIds.add(shopId));
    }

    if (mounted) setState(() => _confirmingShop = false);
  }

  Widget buildShopGroups(BuildContext context, List items, int orderId) {
    final groups = groupItemsByShop(items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.entries.map<Widget>((entry) {
        final shopId = entry.key;
        final shop = entry.value["shop"] as Map;
        final shopItems = entry.value["items"] as List;
        final subtotal = shopSubtotal(shopItems);

        final allDelivered = shopItems.every((i) => i["status"] == "delivered");
        final confirmed = _confirmedShopIds.contains(shopId);
        final rejected = widget.order["payment_status"] == "rejected";

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
                    ],
                  ),
                );
              }),

              // =========================
              // CONFIRM RECEIVED — once per shop, not per item
              // =========================
              if (allDelivered && !rejected) ...[
                const SizedBox(height: 10),
                if (!confirmed)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Did you receive all items from this shop?",
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      ElevatedButton(
                        onPressed: _confirmingShop
                            ? null
                            : () => confirmShop(orderId, shopId),
                        child: const Text("Yes, Confirm Received"),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton(
                        onPressed: () async {
                          await Get.toNamed(AppRoutes.customerNewComplaint);
                        },
                        child: const Text("No, Report an Issue"),
                      ),
                    ],
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

                // Rating still keyed off the first item for now — see
                // note below about needing the ShopReview files to make
                // this properly one-review-per-shop on the backend too.
                if (confirmed)
                  Builder(
                    builder: (ctx) {
                      final reviewed = shopItems.any(
                        (i) => _reviewedItemIds.contains(
                          int.tryParse(i["id"].toString()) ?? -1,
                        ),
                      );

                      if (reviewed) {
                        return Row(
                          children: [
                            Icon(Icons.star, size: 18, color: AppColors.golden),
                            const SizedBox(width: 6),
                            Text(
                              "Reviewed",
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.golden,
                              ),
                            ),
                          ],
                        );
                      }

                      return ElevatedButton(
                        onPressed: () async {
                          final firstItemId = shopItems.first["id"];
                          final submitted = await showDialog<bool>(
                            context: ctx,
                            builder: (_) =>
                                ShopReviewDialog(orderItemId: firstItemId),
                          );
                          if (submitted == true) {
                            setState(() {
                              _reviewedItemIds.add(
                                int.tryParse(firstItemId.toString()) ?? -1,
                              );
                            });
                          }
                        },
                        child: const Text("Rate Shop"),
                      );
                    },
                  ),
              ],

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
    final order = widget.order;
    final List items = order["items"] ?? [];
    final bool isRejected = order["payment_status"] == "rejected";
    final int orderId = int.tryParse(order["id"].toString()) ?? 0;

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
                    buildShopGroups(context, items, orderId),
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
