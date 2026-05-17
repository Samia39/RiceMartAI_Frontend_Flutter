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
  // =========================
  // ALL ORDERS
  // =========================
  List orders = [];

  // ACTIVE ORDERS
  List activeOrders = [];

  // HISTORY ORDERS
  List historyOrders = [];

  bool isLoading = true;

  late TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);

    fetchSellerOrders();
  }

  // =========================
  // FETCH SELLER ORDERS
  // =========================
  Future<void> fetchSellerOrders() async {
    try {
      final data = await OrderService().fetchSellerOrders();

      // =========================
      // ACTIVE ORDERS
      // =========================
      final active = data.where((item) {
        return item["status"] != "delivered" && item["status"] != "cancelled";
      }).toList();

      // =========================
      // HISTORY ORDERS
      // =========================
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
      final data = await OrderService().updateItemStatus(
        itemId: itemId,
        status: status,
      );

      // REFRESH ORDERS
      fetchSellerOrders();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data["message"])));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // =========================
  // ORDER CARD
  // =========================
  Widget orderCard(dynamic item) {
    final product = item["product"];

    final order = item["order"];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(16),

      decoration: AppDecorations.card,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // PRODUCT NAME
          Text(product["name"] ?? "", style: AppTextStyles.heading4),

          const SizedBox(height: 12),

          // ORDER ID
          Text("Order ID: ${order["id"]}", style: AppTextStyles.bodyLarge),

          const SizedBox(height: 8),

          // QUANTITY
          Text("Quantity: ${item["quantity"]}", style: AppTextStyles.bodyLarge),

          const SizedBox(height: 8),

          // PRICE
          Text("Price: Rs ${item["price"]}", style: AppTextStyles.bodyLarge),

          const SizedBox(height: 8),

          // STATUS
          Text("Status: ${item["status"]}", style: AppTextStyles.bodyLarge),

          const SizedBox(height: 8),

          // PAYMENT STATUS
          Text(
            "Payment: ${order["payment_status"]}",
            style: AppTextStyles.bodyLarge,
          ),

          const SizedBox(height: 18),

          // =========================
          // BUTTONS ONLY FOR ACTIVE
          // =========================
          if (item["status"] != "delivered" && item["status"] != "cancelled")
            Wrap(
              spacing: 10,
              runSpacing: 10,

              children: [
                ElevatedButton(
                  onPressed: () {
                    updateItemStatus(itemId: item["id"], status: "processing");
                  },

                  child: const Text("Processing"),
                ),

                ElevatedButton(
                  onPressed: () {
                    updateItemStatus(itemId: item["id"], status: "shipped");
                  },

                  child: const Text("Shipped"),
                ),

                ElevatedButton(
                  onPressed: () {
                    updateItemStatus(itemId: item["id"], status: "delivered");
                  },

                  child: const Text("Delivered"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                  onPressed: () {
                    updateItemStatus(itemId: item["id"], status: "cancelled");
                  },

                  child: const Text("Cancel"),
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
                  // =========================
                  // ACTIVE ORDERS
                  // =========================
                  activeOrders.isEmpty
                      ? const Center(child: Text("No active orders"))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),

                          itemCount: activeOrders.length,

                          itemBuilder: (context, index) {
                            return orderCard(activeOrders[index]);
                          },
                        ),

                  // =========================
                  // HISTORY
                  // =========================
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
