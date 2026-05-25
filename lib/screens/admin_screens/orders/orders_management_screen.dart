import 'package:flutter/material.dart';

import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';

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

  // =========================
  // FETCH ADMIN ORDERS
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
  // UPDATE ITEM STATUS
  // =========================
  Future<void> updateItemStatus({
    required int itemId,
    required String status,
  }) async {
    try {
      final data = await OrderService().adminUpdateItemStatus(
        itemId: itemId,
        status: status,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data["message"])));

      fetchOrders();
    } catch (e) {
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

      default:
        return Colors.red;
    }
  }

  // =========================
  // ORDER CARD
  // =========================
  Widget orderCard(dynamic order) {
    final items = order["items"] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
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
            "Customer: ${order["user"]?["name"] ?? "Unknown"}",
            style: AppTextStyles.bodyLarge,
          ),

          const SizedBox(height: 6),

          // EMAIL
          Text(order["user"]?["email"] ?? "", style: AppTextStyles.bodyMedium),

          const SizedBox(height: 10),

          // TOTAL
          Text(
            "Total: Rs ${order["total_price"]}",
            style: AppTextStyles.heading4,
          ),

          const SizedBox(height: 18),

          // ITEMS
          ...items.map<Widget>((item) {
            final product = item["product"];
            final shop = item["shop"];

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // PRODUCT
                  Text(product?["name"] ?? "", style: AppTextStyles.heading4),

                  const SizedBox(height: 8),

                  // SHOP
                  Text(
                    "Shop: ${shop?["name"] ?? ""}",
                    style: AppTextStyles.bodyLarge,
                  ),

                  const SizedBox(height: 6),

                  // QUANTITY
                  Text(
                    "Quantity: ${item["quantity"]}",
                    style: AppTextStyles.bodyLarge,
                  ),

                  const SizedBox(height: 6),

                  // PRICE
                  Text(
                    "Price: Rs ${item["price"]}",
                    style: AppTextStyles.bodyLarge,
                  ),

                  const SizedBox(height: 10),

                  // STATUS
                  Row(
                    children: [
                      Text("Status:", style: AppTextStyles.bodyLarge),

                      const SizedBox(width: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: statusColor(item["status"]).withOpacity(0.15),

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Text(
                          item["status"],

                          style: TextStyle(
                            color: statusColor(item["status"]),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ACTIONS
                  if (item["status"] != "delivered" &&
                      item["status"] != "cancelled")
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,

                      children: [
                        ElevatedButton(
                          onPressed: () {
                            updateItemStatus(
                              itemId: item["id"],
                              status: "processing",
                            );
                          },

                          child: const Text("Processing"),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            updateItemStatus(
                              itemId: item["id"],
                              status: "shipped",
                            );
                          },

                          child: const Text("Shipped"),
                        ),

                        ElevatedButton(
                          onPressed: () {
                            updateItemStatus(
                              itemId: item["id"],
                              status: "delivered",
                            );
                          },

                          child: const Text("Delivered"),
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),

                          onPressed: () {
                            updateItemStatus(
                              itemId: item["id"],
                              status: "cancelled",
                            );
                          },

                          child: const Text("Cancel"),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }).toList(),
        ],
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
                  // ACTIVE
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

                  // HISTORY
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
