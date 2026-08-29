import 'package:flutter/material.dart';
import 'package:ricemart_ai/screens/seller/order/seller_order_details_screen.dart';
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

  Color statusColor(String status) {
    switch (status) {
      case "processing":
        return AppColors.warning;
      case "shipped":
        return AppColors.info;
      case "delivered":
        return AppColors.success;
      case "cancelled":
        return AppColors.error;
      default:
        return AppColors.labelSecondary;
    }
  }

  Widget statusChip(String status) {
    final color = statusColor(status);

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: AppTextStyles.label.copyWith(color: color, fontSize: 11.5),
      ),
      backgroundColor: color.withOpacity(0.15),
      side: BorderSide(color: color.withOpacity(0.45)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget buildItemCard(dynamic item) {
    final product = item["product"];
    final order = item["order"];
    final status = item["status"].toString();

    return GestureDetector(
      onTap: () async {
        await Get.to(() => SellerOrderDetailScreen(item: item));
        fetchOrders();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(product["name"], style: AppTextStyles.heading4),
                ),
                statusChip(status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Order #: ${order["order_number"]}",
              style: AppTextStyles.bodyMedium,
            ),

            if (item["net_amount"] != null) ...[
              const SizedBox(height: 4),
              Text(
                "You'll receive: Rs ${item["net_amount"]}",
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildItemList(List orders) {
    if (orders.isEmpty) {
      return Center(
        child: Text("No orders found", style: AppTextStyles.bodyLarge),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: RefreshIndicator(
              onRefresh: fetchOrders,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 24 : 12,
                  vertical: 12,
                ),
                children: orders.map((e) => buildItemCard(e)).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Orders"),
            bottom: TabBar(
              controller: tabController,
              indicatorColor: AppColors.golden,
              labelColor: AppColors.darkGreen,
              unselectedLabelColor: AppColors.darkGreen.withOpacity(0.5),
              labelStyle: AppTextStyles.label,
              unselectedLabelStyle: AppTextStyles.labelMuted,
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
                    buildItemList(activeItems),
                    buildItemList(historyItems),
                  ],
                ),
        ),
      ),
    );
  }
}
