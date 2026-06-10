import 'package:flutter/material.dart';
import 'package:frontend/screens/seller/order/seller_order_details_screen.dart';
import 'package:get/get.dart';

import '../../../core/services/order_service.dart';
import '../../../core/utils/themes.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen>
    with SingleTickerProviderStateMixin {
  final OrderService service = OrderService();

  List items = [];
  List activeItems = [];
  List historyItems = [];

  bool isLoading = true;
  late TabController tabController;

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

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);

    try {
      final data = await service.fetchSellerOrders();

      final active = data
          .where(
            (i) => i["status"] != "delivered" && i["status"] != "cancelled",
          )
          .toList();

      final history = data
          .where(
            (i) => i["status"] == "delivered" || i["status"] == "cancelled",
          )
          .toList();

      setState(() {
        items = data;
        activeItems = active;
        historyItems = history;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> updateStatus(int itemId, String status) async {
    final res = await service.updateItemStatus(itemId: itemId, status: status);

    Get.snackbar(
      res["success"] == true ? "Success" : "Error",
      res["message"] ?? "",
    );

    fetchOrders();
  }

  Widget buildItemCard(dynamic item) {
    final product = item["product"];
    final order = item["order"];

    return GestureDetector(
      onTap: () {
        Get.to(() => SellerOrderDetailScreen(item: item));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product["name"]),
            Text("Order #: ${order["order_number"]}"),
            Text("Status: ${item["status"]}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.green,
          child: TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: "Active"),
              Tab(text: "History"),
            ],
          ),
        ),

        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: tabController,
                  children: [
                    ListView(
                      padding: const EdgeInsets.all(12),
                      children: activeItems
                          .map((e) => buildItemCard(e))
                          .toList(),
                    ),

                    ListView(
                      padding: const EdgeInsets.all(12),
                      children: historyItems
                          .map((e) => buildItemCard(e))
                          .toList(),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
