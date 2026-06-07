import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';

import 'admin_order_details_screen.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  bool isLoading = true;

  List activeOrders = [];

  List historyOrders = [];

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);

    fetchOrders();
  }

  @override
  void dispose() {
    tabController.dispose();

    super.dispose();
  }

  // =========================
  // FETCH ORDERS
  // =========================
  Future<void> fetchOrders() async {
    try {
      final data = await OrderService().getAdminOrders();

      final active = data.where((order) {
        final items = order["items"] ?? [];

        return items.any(
          (i) => i["status"] != "delivered" && i["status"] != "cancelled",
        );
      }).toList();

      final history = data.where((order) {
        final items = order["items"] ?? [];

        return items.isNotEmpty &&
            items.every(
              (i) => i["status"] == "delivered" || i["status"] == "cancelled",
            );
      }).toList();

      setState(() {
        activeOrders = active;

        historyOrders = history;

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // =========================
  // STATUS COLOR
  // =========================
  Color statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;

      case "processing":
        return Colors.blue;

      case "shipped":
        return Colors.purple;

      case "delivered":
        return Colors.green;

      case "cancelled":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // =========================
  // ORDER CARD
  // =========================
  Widget orderCard(dynamic order) {
    final items = order["items"] ?? [];

    String overallStatus = "pending";

    if (items.any((i) => i["status"] == "cancelled")) {
      overallStatus = "cancelled";
    } else if (items.isNotEmpty &&
        items.every((i) => i["status"] == "delivered")) {
      overallStatus = "delivered";
    } else if (items.any((i) => i["status"] == "shipped")) {
      overallStatus = "shipped";
    } else if (items.any((i) => i["status"] == "processing")) {
      overallStatus = "processing";
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => AdminOrderDetailsScreen(order: order));
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),

        padding: const EdgeInsets.all(16),

        decoration: AppDecorations.card,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ORDER ID
            Text("Order #${order["id"]}", style: AppTextStyles.heading3),

            const SizedBox(height: 10),

            // CUSTOMER
            Text(
              "Customer: ${order["customer_name"]}",
              style: AppTextStyles.bodyLarge,
            ),

            const SizedBox(height: 8),

            // TOTAL
            Text(
              "Total: Rs ${order["total_price"]}",
              style: AppTextStyles.heading4,
            ),

            const SizedBox(height: 8),

            // PAYMENT
            Text(
              "Payment: ${order["payment_status"]}",
              style: AppTextStyles.bodyLarge,
            ),

            const SizedBox(height: 8),

            // STATUS
            Row(
              children: [
                Text("Status: ", style: AppTextStyles.bodyLarge),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: statusColor(overallStatus),

                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    overallStatus.toUpperCase(),

                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ITEMS COUNT
            Text("Items: ${items.length}", style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text("Orders Management"),

          bottom: TabBar(
            controller: tabController,

            tabs: const [
              Tab(text: "Active Orders"),

              Tab(text: "History"),
            ],
          ),
        ),

        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: tabController,

                children: [
                  // ACTIVE ORDERS
                  activeOrders.isEmpty
                      ? const Center(child: Text("No active orders"))
                      : RefreshIndicator(
                          onRefresh: fetchOrders,

                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),

                            itemCount: activeOrders.length,

                            itemBuilder: (context, index) {
                              return orderCard(activeOrders[index]);
                            },
                          ),
                        ),

                  // HISTORY ORDERS
                  historyOrders.isEmpty
                      ? const Center(child: Text("No history orders"))
                      : RefreshIndicator(
                          onRefresh: fetchOrders,

                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),

                            itemCount: historyOrders.length,

                            itemBuilder: (context, index) {
                              return orderCard(historyOrders[index]);
                            },
                          ),
                        ),
                ],
              ),
      ),
    );
  }
}
