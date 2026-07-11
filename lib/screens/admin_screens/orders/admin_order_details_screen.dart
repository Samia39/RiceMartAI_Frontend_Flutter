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

  // =========================
  // ORDER / ITEM STATUS COLOR
  // (pending / processing / shipped / delivered / cancelled)
  // =========================
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

  // =========================
  // PAYMENT STATUS COLOR (pending / paid / rejected)
  // =========================
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

  // =========================
  // "Label: value" ROW
  // =========================
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

  // =========================
  // STATUS CHIP
  // =========================
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

  @override
  Widget build(BuildContext context) {
    final items = order["items"];
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

                      Text("Items", style: AppTextStyles.heading3),

                      const SizedBox(height: 10),

                      ...items.map<Widget>((item) {
                        final itemStatus = item["status"].toString();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: AppDecorations.card,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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

                              const SizedBox(height: 8),

                              infoRow("Quantity", item["quantity"].toString()),

                              const SizedBox(height: 10),

                              if (!widget.isHistory)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => updateItemStatus(
                                        item["id"],
                                        "processing",
                                      ),
                                      child: const Text("Processing"),
                                    ),

                                    ElevatedButton(
                                      onPressed: () => updateItemStatus(
                                        item["id"],
                                        "shipped",
                                      ),
                                      child: const Text("Shipped"),
                                    ),

                                    ElevatedButton(
                                      onPressed: () => updateItemStatus(
                                        item["id"],
                                        "delivered",
                                      ),
                                      child: const Text("Delivered"),
                                    ),

                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.error,
                                        foregroundColor: AppColors.cream,
                                      ),
                                      onPressed: () => updateItemStatus(
                                        item["id"],
                                        "cancelled",
                                      ),
                                      child: const Text("Cancel"),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 20),
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
