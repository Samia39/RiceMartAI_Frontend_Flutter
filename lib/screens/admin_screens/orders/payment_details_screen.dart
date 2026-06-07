import 'package:flutter/material.dart';

import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final dynamic order;

  const PaymentDetailsScreen({super.key, required this.order});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  late dynamic order;

  @override
  void initState() {
    super.initState();

    order = widget.order;
  }

  Future<void> updatePayment(String status) async {
    final result = await OrderService().updatePaymentStatus(
      orderId: order["id"],
      paymentStatus: status,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result["message"])));

    setState(() {
      order["payment_status"] = status;
    });
  }

  Color paymentColor(String status) {
    switch (status) {
      case "paid":
        return Colors.green;

      case "rejected":
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Payment Details")),

        body: Padding(
          padding: const EdgeInsets.all(16),

          child: Container(
            padding: const EdgeInsets.all(16),

            decoration: AppDecorations.card,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text("Order #${order["id"]}", style: AppTextStyles.heading3),

                const SizedBox(height: 20),

                Text(
                  "Payment Method: ${order["payment_method"]}",

                  style: AppTextStyles.bodyLarge,
                ),

                const SizedBox(height: 10),

                Text(
                  "Total: Rs ${order["total_price"]}",

                  style: AppTextStyles.heading4,
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color: paymentColor(order["payment_status"]),

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    order["payment_status"].toUpperCase(),

                    style: const TextStyle(
                      color: Colors.white,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // =========================
                // APPROVE
                // =========================
                if (order["payment_status"] != "paid")
                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      onPressed: () {
                        updatePayment("paid");
                      },

                      child: const Text("Approve Payment"),
                    ),
                  ),

                const SizedBox(height: 14),

                // =========================
                // REJECT
                // =========================
                if (order["payment_status"] != "rejected")
                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),

                      onPressed: () {
                        updatePayment("rejected");
                      },

                      child: const Text("Reject Payment"),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
