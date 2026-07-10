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

  // =========================
  // ORDER / ITEM STATUS COLOR
  // (pending / processing / shipped / delivered / cancelled)
  // =========================
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

  // =========================
  // PAYMENT STATUS COLOR (pending / paid / rejected)
  // =========================
  Color paymentStatusColor(String status) {
    switch (status) {
      case "paid":
        return AppColors.success;
      case "rejected":
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  // =========================
  // "Label: value" ROW
  // =========================
  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodyMedium,
          children: [
            TextSpan(text: "$label: ", style: AppTextStyles.label),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  // =========================
  // STATUS CHIP
  // =========================
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

  Widget buildOrderList(List orders, bool isHistory) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          isHistory ? "No history found" : "No active orders",
          style: AppTextStyles.bodyLarge,
        ),
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
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 24 : 12,
                  vertical: 12,
                ),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final o = orders[index];
                  final status = o["status"].toString();
                  final paymentStatus = o["payment_status"].toString();

                  return GestureDetector(
                    onTap: () async {
                      await Get.to(
                        () => AdminOrderDetailsScreen(
                          order: o,
                          isHistory: isHistory,
                        ),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Order #: ${o["order_number"]}",
                                  style: AppTextStyles.heading4,
                                ),
                              ),
                              statusChip(status),
                            ],
                          ),

                          const SizedBox(height: 10),

                          infoRow("Customer", o["customer_name"].toString()),
                          infoRow("Phone", o["phone"].toString()),

                          const SizedBox(height: 6),

                          Text(
                            "Payment: $paymentStatus",
                            style: AppTextStyles.label.copyWith(
                              color: paymentStatusColor(paymentStatus),
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
                  children: [
                    buildOrderList(activeOrders, false),
                    buildOrderList(historyOrders, true),
                  ],
                ),
        ),
      ),
    );
  }
}
