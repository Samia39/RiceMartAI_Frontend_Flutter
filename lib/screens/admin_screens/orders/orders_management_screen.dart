import 'package:flutter/material.dart';
import '../../../core/utils/themes.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  List<Map<String, dynamic>> orders = [
    {
      "id": "1001",
      "buyer": "Hamza",
      "seller": "Punjab Rice Traders",
      "rice": "Super Basmati",
      "qty": "50 kg",
      "status": "Pending",
    },

    {
      "id": "1002",
      "buyer": "Ali",
      "seller": "Basmati House",
      "rice": "Brown Rice",
      "qty": "20 kg",
      "status": "Processing",
    },
  ];

  void updateStatus(int index, String status) {
    setState(() {
      orders[index]["status"] = status;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Order marked $status")));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Orders Management")),

        body: ListView.builder(
          padding: const EdgeInsets.all(18),

          itemCount: orders.length,

          itemBuilder: (context, index) {
            var order = orders[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 20),

              padding: const EdgeInsets.all(16),

              decoration: AppDecorations.card,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text("Order #${order["id"]}", style: AppTextStyles.heading4),

                  const SizedBox(height: 10),

                  Text("Buyer: ${order["buyer"]}"),

                  Text("Seller: ${order["seller"]}"),

                  Text("Rice: ${order["rice"]}"),

                  Text("Quantity: ${order["qty"]}"),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderGold),

                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Text("Status: ${order["status"]}"),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            updateStatus(index, "Delivered");
                          },
                          child: const Text("Deliver"),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            updateStatus(index, "Cancelled");
                          },
                          child: const Text("Cancel"),
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
