import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';
import 'admin_order_details_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);

    final data = await OrderService().getAdminOrders();

    setState(() {
      orders = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Orders")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final o = orders[index];
                final payment = o["payment"];

                return GestureDetector(
                  onTap: () {
                    Get.to(() => AdminOrderDetailsScreen(order: o));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: AppDecorations.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order #: ${o["order_number"]}",
                          style: AppTextStyles.heading4,
                        ),

                        const SizedBox(height: 5),

                        Text("Customer: ${o["customer_name"]}"),

                        const SizedBox(height: 5),

                        Text(
                          "Payment: ${o["payment_status"]}",
                          style: TextStyle(
                            color: o["payment_status"] == "paid"
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),

                        Text("Status: ${o["status"]}"),

                        const SizedBox(height: 10),

                        Text(
                          "Total: Rs ${o["total_price"]}",
                          style: AppTextStyles.heading4,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
