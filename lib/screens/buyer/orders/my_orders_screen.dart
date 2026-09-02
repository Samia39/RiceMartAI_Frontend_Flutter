import 'package:flutter/material.dart';
import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
          final items = order["items"] ?? [];

          // =========================
          // OVERALL STATUS
          // =========================
          String overallStatus = "pending";

          if (order["payment_status"] == "rejected") {
            overallStatus = "rejected";
          } else if (items.any((i) => i["status"] == "cancelled")) {
            overallStatus = "cancelled";
          } else if (items.isNotEmpty &&
              items.every((i) => i["status"] == "delivered")) {
            overallStatus =
                items.every((i) => i["customer_confirmed_at"] != null)
                ? "completed"
                : "delivered";
          } else if (items.any((i) => i["status"] == "shipped")) {
            overallStatus = "shipped";
          } else if (items.any((i) => i["status"] == "processing")) {
            overallStatus = "processing";
          }

          Color tagColor;
          switch (overallStatus) {
            case "rejected":
            case "cancelled":
              tagColor = AppColors.error;
              break;
            case "completed":
              tagColor = AppColors.success;
              break;
            case "processing":
              tagColor = AppColors.warning;
              break;
            case "shipped":
              tagColor = AppColors.info;
              break;
            case "delivered":
              tagColor = AppColors.success;
              break;
            default:
              tagColor = AppColors.labelSecondary;
          }

          return GestureDetector(
            onTap: () async {
              await Get.toNamed(AppRoutes.orderDetails, arguments: order);
              fetchAllOrders();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order #${order["id"]}",
                        style: AppTextStyles.heading4,
                      ),
                      Chip(
                        label: Text(
                          overallStatus.toUpperCase(),
                          style: AppTextStyles.label.copyWith(
                            color: tagColor,
                            fontSize: 11.5,
                          ),
                        ),
                        backgroundColor: tagColor.withOpacity(0.15),
                        side: BorderSide(color: tagColor.withOpacity(0.45)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                    ],
                  ),

                  if (overallStatus == "rejected") ...[
                    const SizedBox(height: 8),
                    Text(
                      "Your payment was rejected. This order cannot proceed.",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  Text(
                    "Payment: ${order["payment_method"]}",
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Payment Status: ${order["payment_status"]}",
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Total: Rs ${order["total_price"]}",
                    style: AppTextStyles.heading4,
                  ),
                  const SizedBox(height: 10),
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
