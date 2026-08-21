import 'package:flutter/material.dart';

import '../../../core/services/admin/payout_service.dart';
import '../../../core/utils/themes.dart';

class SellerPayoutsScreen extends StatefulWidget {
  const SellerPayoutsScreen({super.key});

  @override
  State<SellerPayoutsScreen> createState() => _SellerPayoutsScreenState();
}

class _SellerPayoutsScreenState extends State<SellerPayoutsScreen>
    with SingleTickerProviderStateMixin {
  final PayoutService service = PayoutService();
  late TabController tabController;

  List payouts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    fetchPayouts();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> fetchPayouts() async {
    setState(() => isLoading = true);
    final data = await service.getSellerPayouts();
    setState(() {
      payouts = data;
      isLoading = false;
    });
  }

  Color statusColor(String status) {
    switch (status) {
      case "ready":
        return AppColors.info;
      case "paid":
        return AppColors.success;
      default:
        return AppColors.warning;
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

  String statusMessage(String status) {
    switch (status) {
      case "pending":
        return "Waiting for the customer to confirm they received their order.";
      case "ready":
        return "Confirmed by the customer — admin will send your payment soon.";
      default:
        return "";
    }
  }

  Widget buildCard(dynamic payout) {
    final order = payout["order"] ?? {};
    final status = payout["status"].toString();

    return Container(
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
                  "Order #: ${order["order_number"] ?? "-"}",
                  style: AppTextStyles.heading4,
                ),
              ),
              statusChip(status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Gross: Rs ${payout["gross_amount"]}",
            style: AppTextStyles.bodySmall,
          ),
          Text(
            "Commission (5%): Rs ${payout["commission_amount"]}",
            style: AppTextStyles.bodySmall,
          ),
          Text(
            "You'll receive: Rs ${payout["net_amount"]}",
            style: AppTextStyles.heading4,
          ),

          if (status == "paid") ...[
            const SizedBox(height: 10),
            Text(
              "Paid via ${payout["payout_method"] ?? "-"} · ${payout["transaction_id"] ?? "-"}",
              style: AppTextStyles.bodySmall,
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              statusMessage(status),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.labelSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildList(String status) {
    final filtered = payouts.where((p) => p["status"] == status).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text("Nothing here", style: AppTextStyles.bodyLarge),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: RefreshIndicator(
              onRefresh: fetchPayouts,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 24 : 12,
                  vertical: 12,
                ),
                children: filtered.map((p) => buildCard(p)).toList(),
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("My Payouts"),
          bottom: TabBar(
            controller: tabController,
            indicatorColor: AppColors.golden,
            labelColor: AppColors.darkGreen,
            unselectedLabelColor: AppColors.darkGreen.withOpacity(0.5),
            labelStyle: AppTextStyles.label,
            unselectedLabelStyle: AppTextStyles.labelMuted,
            isScrollable: true,
            tabs: const [
              Tab(text: "Awaiting"),
              Tab(text: "Ready"),
              Tab(text: "Paid"),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: tabController,
                children: [
                  buildList("pending"),
                  buildList("ready"),
                  buildList("paid"),
                ],
              ),
      ),
    );
  }
}
