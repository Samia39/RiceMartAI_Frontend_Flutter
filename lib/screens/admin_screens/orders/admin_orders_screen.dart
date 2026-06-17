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
  final OrderService orderService = OrderService();

  List activeOrders = [];
  List historyOrders = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);

    try {
      final active = await orderService.getAdminOrders();

      final history = await orderService.getAdminOrderHistory();

      setState(() {
        activeOrders = active;
        historyOrders = history;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case "processing":
        return Colors.orange;

      case "shipped":
        return Colors.blue;

      case "delivered":
        return Colors.green;

      case "cancelled":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  Widget buildOrderList(List orders, bool isHistory) {
    if (orders.isEmpty) {
      return Center(
        child: Text(isHistory ? "No history found" : "No active orders"),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final o = orders[index];

          return GestureDetector(
            onTap: () async {
              await Get.to(
                () => AdminOrderDetailsScreen(order: o, isHistory: isHistory),
              );

              fetchOrders();
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

                  const SizedBox(height: 8),

                  Text("Customer: ${o["customer_name"]}"),

                  Text("Phone: ${o["phone"]}"),

                  const SizedBox(height: 8),

                  Text(
                    "Payment: ${o["payment_status"]}",
                    style: TextStyle(
                      color: o["payment_status"] == "paid"
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "Status: ${o["status"]}",
                    style: TextStyle(
                      color: statusColor(o["status"]),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Orders"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Active"),
              Tab(text: "History"),
            ],
          ),
        ),

        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  buildOrderList(activeOrders, false),

                  buildOrderList(historyOrders, true),
                ],
              ),
      ),
    );
  }
}
