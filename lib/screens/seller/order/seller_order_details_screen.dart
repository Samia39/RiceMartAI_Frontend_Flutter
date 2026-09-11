import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';

class SellerOrderDetailScreen extends StatefulWidget {
  const SellerOrderDetailScreen({super.key});

  @override
  State<SellerOrderDetailScreen> createState() =>
      _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends State<SellerOrderDetailScreen> {
  // The seller-controlled progression. A button for a step only shows
  // if that step is still AHEAD of the current status.
  static const List<String> _statusSteps = [
    "processing",
    "shipped",
    "delivered",
  ];

  final service = OrderService();

  late Map order;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Local mutable copy so we can update status in place instead of
    // popping the screen.
    order = Map.from(Get.arguments as Map);
  }

  Future<void> update(String status) async {
    if (isUpdating) return;
    setState(() => isUpdating = true);

    final res = await service.updateShopOrderStatus(
      orderId: order["order_id"],
      status: status,
    );

    if (!mounted) return;

    Get.snackbar(
      res["success"] == true ? "Success" : "Error",
      res["message"] ?? "",
    );

    setState(() {
      isUpdating = false;
      if (res["success"] == true) {
        order["status"] = status; // <-- this is the "refresh"
        for (final item in order["items"]) {
          item["status"] = status;
        }
      }
    });
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
    final shop = order["shop"] ?? {};
    final status = order["status"].toString();
    final items = order["items"] as List;
    final currentStepIndex = _statusSteps.indexOf(status);

    num asNum(dynamic v) =>
        v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;

    final totalRiceGross = items.fold<num>(
      0,
      (sum, i) => sum + asNum(i["price"]) * asNum(i["quantity"]),
    );
    final totalCommission = items.fold<num>(
      0,
      (sum, i) => sum + asNum(i["commission_amount"]),
    );
    final totalNet = items.fold<num>(
      0,
      (sum, i) => sum + asNum(i["net_amount"]),
    );
    final delivery = asNum(order["shop_delivery_charge"]);
    final grandTotal = totalNet + delivery;

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
                                    "Order #: ${order["order_number"]}",
                                    style: AppTextStyles.heading3,
                                  ),
                                ),
                                statusChip(status),
                              ],
                            ),
                            const SizedBox(height: 14),
                            infoRow(
                              "Customer",
                              order["customer_name"].toString(),
                            ),
                            infoRow("Phone", order["phone"].toString()),

                            const SizedBox(height: 14),
                            Divider(color: AppColors.golden.withOpacity(0.3)),
                            const SizedBox(height: 6),
                            Text("Items", style: AppTextStyles.heading4),
                            const SizedBox(height: 8),

                            ...items.map((item) {
                              final product = item["product"];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        product["name"],
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ),
                                    Text(
                                      "x${item["quantity"]}  Rs ${item["price"]}",
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              );
                            }),

                            const SizedBox(height: 10),
                            Divider(color: AppColors.golden.withOpacity(0.3)),
                            const SizedBox(height: 4),
                            infoRow(
                              "Rice price",
                              "Rs ${totalRiceGross.toStringAsFixed(2)}",
                            ),
                            infoRow(
                              "Commission (5%)",
                              "- Rs ${totalCommission.toStringAsFixed(2)}",
                            ),
                            infoRow(
                              "Rice price after commission",
                              "Rs ${totalNet.toStringAsFixed(2)}",
                            ),
                            infoRow(
                              "Delivery charges",
                              "Rs ${delivery.toStringAsFixed(2)}",
                            ),
                            const SizedBox(height: 4),
                            infoRow(
                              "Total",
                              "Rs ${grandTotal.toStringAsFixed(2)}",
                            ),

                            // Buttons only for steps still ahead of the
                            // current status — this is what makes them
                            // disappear one by one as the seller progresses.
                            if (status != "delivered") ...[
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  if (_statusSteps.indexOf("processing") >
                                      currentStepIndex)
                                    ElevatedButton(
                                      onPressed: isUpdating
                                          ? null
                                          : () => update("processing"),
                                      child: const Text("Processing"),
                                    ),
                                  if (_statusSteps.indexOf("shipped") >
                                      currentStepIndex)
                                    ElevatedButton(
                                      onPressed: isUpdating
                                          ? null
                                          : () => update("shipped"),
                                      child: const Text("Shipped"),
                                    ),
                                  if (_statusSteps.indexOf("delivered") >
                                      currentStepIndex)
                                    ElevatedButton(
                                      onPressed: isUpdating
                                          ? null
                                          : () => update("delivered"),
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
