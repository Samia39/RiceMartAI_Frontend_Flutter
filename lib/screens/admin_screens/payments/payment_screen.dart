import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List payments = [];
  bool isLoading = true;

  // Change this according to your environment
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
      final data = await OrderService().getAdminPayments();

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
    final result = await OrderService().updatePaymentStatus(
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
      content: TextField(
        controller: controller,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: "Enter rejection reason",
          border: OutlineInputBorder(),
        ),
      ),
      textConfirm: "Reject",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payments")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : payments.isEmpty
          ? const Center(child: Text("No payments found"))
          : RefreshIndicator(
              onRefresh: fetchPayments,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final p = payments[index];
                  final order = p["order"];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: AppDecorations.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order #: ${order["order_number"]}",
                          style: AppTextStyles.heading4,
                        ),

                        const SizedBox(height: 8),

                        Text("Customer: ${order["customer_name"]}"),

                        Text("Phone: ${order["phone"]}"),

                        Text("Amount: Rs ${p["amount"]}"),

                        Text("Method: ${p["payment_method"]}"),

                        Text("Transaction: ${p["transaction_id"] ?? "-"}"),

                        Text("Payment Status: ${p["status"]}"),

                        const SizedBox(height: 10),

                        if (p["screenshot_path"] != null) ...[
                          Builder(
                            builder: (context) {
                              final imageUrl =
                                  "$imageBaseUrl/storage/${p["screenshot_path"]}";

                              print("IMAGE URL: $imageUrl");

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print("IMAGE ERROR: $error");

                                    return Container(
                                      height: 180,
                                      alignment: Alignment.center,
                                      color: Colors.grey.shade200,
                                      child: const Text("Failed to load image"),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 16),

                        if (p["status"] == "pending")
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
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () {
                                    showRejectDialog(p["id"]);
                                  },
                                  child: const Text("Reject"),
                                ),
                              ),
                            ],
                          ),

                        if (p["status"] == "paid")
                          const Chip(label: Text("Approved")),

                        if (p["status"] == "rejected")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Chip(label: Text("Rejected")),

                              if (p["rejection_reason"] != null &&
                                  p["rejection_reason"].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "Reason: ${p["rejection_reason"]}",
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
