import 'package:flutter/material.dart';
import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen>
    with SingleTickerProviderStateMixin {
  List orders = [];
  List activeOrders = [];
  List historyOrders = [];

  bool isLoading = true;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    fetchSellerOrders();
  }

  Future<void> fetchSellerOrders() async {
    try {
      final data = await OrderService().fetchSellerOrders();

      final active = data.where((item) {
        return item["status"] != "delivered" && item["status"] != "cancelled";
      }).toList();

      final history = data.where((item) {
        return item["status"] == "delivered" || item["status"] == "cancelled";
      }).toList();

      setState(() {
        orders = data;
        activeOrders = active;
        historyOrders = history;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> updateItemStatus({
    required int itemId,
    required String status,
  }) async {
    try {
      final data = await OrderService().updateItemStatus(
        itemId: itemId,
        status: status,
      );

      await fetchSellerOrders();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data["message"])));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // ✅ FIXED HERE (INSIDE STATE CLASS)
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

  Widget orderCard(dynamic item) {
    final product = item["product"];
    final order = item["order"];

    final status = (item["status"] ?? "").toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product["name"] ?? "", style: AppTextStyles.heading4),

          const SizedBox(height: 12),

          Text("Order ID: ${order["id"]}", style: AppTextStyles.bodyLarge),

          const SizedBox(height: 8),

          Text(
            "Customer: ${order["user"]?["name"] ?? "Unknown"}",
            style: AppTextStyles.bodyLarge,
          ),

          const SizedBox(height: 8),

          Text("Quantity: ${item["quantity"]}", style: AppTextStyles.bodyLarge),

          const SizedBox(height: 8),

          Text("Price: Rs ${item["price"]}", style: AppTextStyles.bodyLarge),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor(status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Payment: ${order["payment_status"]}",
            style: AppTextStyles.bodyLarge,
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (status == "pending") ...[
                ElevatedButton(
                  onPressed: () => updateItemStatus(
                    itemId: item["id"],
                    status: "processing",
                  ),
                  child: const Text("Processing"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () =>
                      updateItemStatus(itemId: item["id"], status: "cancelled"),
                  child: const Text("Cancel"),
                ),
              ],

              if (status == "processing") ...[
                ElevatedButton(
                  onPressed: () =>
                      updateItemStatus(itemId: item["id"], status: "shipped"),
                  child: const Text("Shipped"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () =>
                      updateItemStatus(itemId: item["id"], status: "cancelled"),
                  child: const Text("Cancel"),
                ),
              ],

              if (status == "shipped") ...[
                ElevatedButton(
                  onPressed: () =>
                      updateItemStatus(itemId: item["id"], status: "delivered"),
                  child: const Text("Delivered"),
                ),
              ],

              if (status == "delivered")
                const Text(
                  "Order Delivered",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              if (status == "cancelled")
                const Text(
                  "Order Cancelled",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
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
          title: const Text("Seller Orders"),
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
                  activeOrders.isEmpty
                      ? const Center(child: Text("No active orders"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: activeOrders.length,
                          itemBuilder: (context, index) {
                            return orderCard(activeOrders[index]);
                          },
                        ),

                  historyOrders.isEmpty
                      ? const Center(child: Text("No history orders"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: historyOrders.length,
                          itemBuilder: (context, index) {
                            return orderCard(historyOrders[index]);
                          },
                        ),
                ],
              ),
      ),
    );
  }
}
