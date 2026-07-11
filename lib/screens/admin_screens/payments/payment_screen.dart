import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/payment_service.dart';
import '../../../core/utils/themes.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService paymentService = PaymentService();

  List payments = [];
  bool isLoading = true;

  static const String imageBaseUrl = "http://localhost:8000";

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    if (mounted) {
      setState(() => isLoading = true);
    }

    try {
      final data = await paymentService.getAdminPayments();

      if (mounted) {
        setState(() {
          payments = data;
        });
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> updatePayment(
    int paymentId,
    String status, {
    String? rejectionReason,
  }) async {
    final result = await paymentService.updatePaymentStatus(
      paymentId: paymentId,
      paymentStatus: status,
      rejectionReason: rejectionReason,
    );

    Get.snackbar(
      result["success"] == true ? "Success" : "Error",
      result["message"] ?? "Updated",
      snackPosition: SnackPosition.BOTTOM,
    );

    if (result["success"] == true) {
      fetchPayments();
    }
  }

  Future<void> showRejectDialog(int paymentId) async {
    final controller = TextEditingController();

    Get.defaultDialog(
      title: "Reject Payment",
      titleStyle: AppTextStyles.heading3,
      backgroundColor: AppColors.cream,
      radius: 12,
      content: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Container(
          decoration: AppDecorations.inputField,
          child: TextField(
            controller: controller,
            maxLines: 3,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: "Enter rejection reason",
              hintStyle: AppTextStyles.hint,
            ),
          ),
        ),
      ),
      textConfirm: "Reject",
      textCancel: "Cancel",
      confirmTextColor: AppColors.cream,
      buttonColor: AppColors.error,
      onConfirm: () async {
        final reason = controller.text.trim();

        if (reason.isEmpty) {
          Get.snackbar(
            "Error",
            "Please enter rejection reason",
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        Get.back();

        await updatePayment(paymentId, "rejected", rejectionReason: reason);
      },
    );
  }

  // =========================
  // PAYMENT STATUS COLOR (pending / paid / rejected)
  // =========================
  Color statusColor(String status) {
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
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Payments")),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : payments.isEmpty
            ? Center(
                child: Text(
                  "No payments found",
                  style: AppTextStyles.bodyLarge,
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: RefreshIndicator(
                        onRefresh: fetchPayments,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 24 : 12,
                            vertical: 12,
                          ),
                          itemCount: payments.length,
                          itemBuilder: (context, index) {
                            final p = payments[index];
                            final order = p["order"];
                            final status = p["status"].toString();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
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
                                          "Order #: ${order["order_number"]}",
                                          style: AppTextStyles.heading4,
                                        ),
                                      ),
                                      statusChip(status),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  infoRow(
                                    "Customer",
                                    order["customer_name"].toString(),
                                  ),
                                  infoRow("Phone", order["phone"].toString()),
                                  infoRow("Amount", "Rs ${p["amount"]}"),
                                  infoRow(
                                    "Method",
                                    p["payment_method"].toString(),
                                  ),
                                  infoRow(
                                    "Transaction",
                                    (p["transaction_id"] ?? "-").toString(),
                                  ),

                                  const SizedBox(height: 6),

                                  if (p["screenshot_path"] != null) ...[
                                    Builder(
                                      builder: (context) {
                                        final imageUrl =
                                            "$imageBaseUrl/storage/${p["screenshot_path"]}";

                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.cardBorder,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Image.network(
                                              imageUrl,
                                              height: 180,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      height: 180,
                                                      alignment:
                                                          Alignment.center,
                                                      color:
                                                          AppColors.inputFill,
                                                      child: Text(
                                                        "Failed to load image",
                                                        style: AppTextStyles
                                                            .bodySmall
                                                            .copyWith(
                                                              color: AppColors
                                                                  .error,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                  ],

                                  if (status == "pending")
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              updatePayment(p["id"], "paid");
                                            },
                                            child: const Text("Approve"),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.error,
                                              foregroundColor: AppColors.cream,
                                            ),
                                            onPressed: () {
                                              showRejectDialog(p["id"]);
                                            },
                                            child: const Text("Reject"),
                                          ),
                                        ),
                                      ],
                                    ),

                                  if (status == "rejected" &&
                                      p["rejection_reason"] != null &&
                                      p["rejection_reason"]
                                          .toString()
                                          .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: infoRow(
                                        "Reason",
                                        p["rejection_reason"].toString(),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
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
