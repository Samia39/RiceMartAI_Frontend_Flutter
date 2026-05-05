import 'package:flutter/material.dart';
import '../../../core/utils/themes.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<Map<String, dynamic>> payouts = [
    {
      "order": "1001",
      "seller": "Punjab Rice Traders",
      "amount": "15000",
      "commission": "750",
      "status": "Pending",
    },

    {
      "order": "1002",
      "seller": "Basmati House",
      "amount": "22000",
      "commission": "1100",
      "status": "Pending",
    },
  ];

  void markPaid(int index) {
    setState(() {
      payouts[index]["status"] = "Paid";
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Payment released")));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Payments & Commission")),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // Summary cards
              Container(
                padding: const EdgeInsets.all(18),

                decoration: AppDecorations.card,

                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: const [Text("Total Sales"), Text("Rs 37,000")],
                    ),

                    SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: const [
                        Text("Platform Commission"),
                        Text("Rs 1,850"),
                      ],
                    ),

                    SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: const [
                        Text("Pending Payouts"),
                        Text("Rs 35,150"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Text("Seller Payouts", style: AppTextStyles.heading3),

              const SizedBox(height: 15),

              ...List.generate(payouts.length, (index) {
                var item = payouts[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 18),

                  padding: const EdgeInsets.all(16),

                  decoration: AppDecorations.card,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "Order #${item["order"]}",
                        style: AppTextStyles.heading4,
                      ),

                      const SizedBox(height: 10),

                      Text("Seller: ${item["seller"]}"),

                      Text("Amount: Rs ${item["amount"]}"),

                      Text("Commission: Rs ${item["commission"]}"),

                      const SizedBox(height: 10),

                      Text("Status: ${item["status"]}"),

                      const SizedBox(height: 15),

                      if (item["status"] == "Pending")
                        SizedBox(
                          width: double.infinity,

                          child: ElevatedButton(
                            onPressed: () {
                              markPaid(index);
                            },
                            child: const Text("Release Payment"),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
