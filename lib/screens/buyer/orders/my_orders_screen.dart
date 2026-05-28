import 'package:flutter/material.dart';
import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';
import 'package:get/get.dart';
import 'package:frontend/routes/app_routes.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  List activeOrders = [];
  List historyOrders = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);

    fetchAllOrders();
  }

  // =========================
  // FETCH BOTH LISTS
  // =========================
  Future<void> fetchAllOrders() async {
    setState(() => isLoading = true);

    final active = await OrderService().getActiveOrders();

    final history = await OrderService().getOrderHistory();

    setState(() {
      activeOrders = active;
      historyOrders = history;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text("My Orders"),

          bottom: TabBar(
            controller: tabController,

            tabs: const [
              Tab(text: "Active"),
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
                  buildOrderList(activeOrders),

                  // HISTORY ORDERS
                  buildOrderList(historyOrders),
                ],
              ),
      ),
    );
  }

  // =========================
  // COMMON ORDER LIST
  // =========================
  Widget buildOrderList(List orders) {
    if (orders.isEmpty) {
      return const Center(child: Text("No orders found"));
    }

    return RefreshIndicator(
      onRefresh: fetchAllOrders,

      child: ListView.builder(
        padding: const EdgeInsets.all(16),

        itemCount: orders.length,

        itemBuilder: (context, index) {
          final order = orders[index];

          // =========================
          // GET ITEMS
          // =========================
          final items = order["items"] ?? [];

          // =========================
          // OVERALL STATUS
          // =========================
          String overallStatus = "pending";

          // ANY CANCELLED
          if (items.any((i) => i["status"] == "cancelled")) {
            overallStatus = "cancelled";
          }
          // ALL DELIVERED
          else if (items.isNotEmpty &&
              items.every((i) => i["status"] == "delivered")) {
            overallStatus = "delivered";
          }
          // ANY SHIPPED
          else if (items.any((i) => i["status"] == "shipped")) {
            overallStatus = "shipped";
          }
          // ANY PROCESSING
          else if (items.any((i) => i["status"] == "processing")) {
            overallStatus = "processing";
          }

          return GestureDetector(
            onTap: () async {
              await Get.toNamed(AppRoutes.orderDetails, arguments: order);

              // AUTO REFRESH AFTER BACK
              fetchAllOrders();
            },

            child: Container(
              margin: const EdgeInsets.only(bottom: 16),

              padding: const EdgeInsets.all(16),

              decoration: AppDecorations.card,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ORDER ID
                  Text("Order #${order["id"]}", style: AppTextStyles.heading4),

                  const SizedBox(height: 10),

                  // STATUS
                  Text(
                    "Status: $overallStatus",
                    style: AppTextStyles.bodyLarge,
                  ),

                  const SizedBox(height: 10),

                  // TOTAL
                  Text(
                    "Total: Rs ${order["total_price"]}",
                    style: AppTextStyles.heading4,
                  ),

                  const SizedBox(height: 10),

                  // ITEMS
                  Text(
                    "Items: ${order["items"].length}",
                    style: AppTextStyles.bodyLarge,
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
