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

  late Map item;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Local mutable copy so we can update status in place instead of
    // popping the screen.
    item = Map.from(Get.arguments as Map);
  }

  Future<void> update(BuildContext context, int id, String status) async {
    if (isUpdating) return;
    setState(() => isUpdating = true);

    final res = await service.updateItemStatus(itemId: id, status: status);

    if (!mounted) return;

    Get.snackbar(
      res["success"] == true ? "Success" : "Error",
      res["message"] ?? "",
    );

    setState(() {
      isUpdating = false;
      if (res["success"] == true) {
        item["status"] = status; // <-- this is the "refresh"
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
    final product = item["product"];
    final order = item["order"];
    final shop = item["shop"] ?? {};
    final status = item["status"].toString();
    final currentStepIndex = _statusSteps.indexOf(status);

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

                            if (item["net_amount"] != null) ...[
                              const SizedBox(height: 10),
                              Divider(color: AppColors.golden.withOpacity(0.3)),
                              const SizedBox(height: 4),
                              Builder(
                                builder: (context) {
                                  num asNum(dynamic v) => v is num
                                      ? v
                                      : num.tryParse(v?.toString() ?? '') ?? 0;

                                  final price = asNum(item["price"]);
                                  final qty = asNum(item["quantity"]);
                                  final riceGross = price * qty;
                                  final commission = asNum(
                                    item["commission_amount"],
                                  );
                                  final riceNet = asNum(item["net_amount"]);
                                  final delivery = asNum(
                                    order["shop_delivery_charge"] ??
                                        order["delivery_charge"],
                                  );
                                  final total = riceNet + delivery;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      infoRow(
                                        "Rice price",
                                        "Rs ${riceGross.toStringAsFixed(2)}",
                                      ),
                                      infoRow(
                                        "Commission (5%)",
                                        "- Rs ${commission.toStringAsFixed(2)}",
                                      ),
                                      infoRow(
                                        "Rice price after commission",
                                        "Rs ${riceNet.toStringAsFixed(2)}",
                                      ),
                                      infoRow(
                                        "Delivery charges",
                                        "Rs ${delivery.toStringAsFixed(2)}",
                                      ),
                                      const SizedBox(height: 4),
                                      infoRow(
                                        "Total",
                                        "Rs ${total.toStringAsFixed(2)}",
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],

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
                                          : () => update(
                                              context,
                                              item["id"],
                                              "processing",
                                            ),
                                      child: const Text("Processing"),
                                    ),
                                  if (_statusSteps.indexOf("shipped") >
                                      currentStepIndex)
                                    ElevatedButton(
                                      onPressed: isUpdating
                                          ? null
                                          : () => update(
                                              context,
                                              item["id"],
                                              "shipped",
                                            ),
                                      child: const Text("Shipped"),
                                    ),
                                  if (_statusSteps.indexOf("delivered") >
                                      currentStepIndex)
                                    ElevatedButton(
                                      onPressed: isUpdating
                                          ? null
                                          : () => update(
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
