import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ricemart_ai/core/services/shop_service.dart';
import '../../../core/utils/themes.dart';
import 'approved_shop_detail_screen.dart';
import 'shop_details_screen.dart';

class AdminShopsTab extends StatefulWidget {
  const AdminShopsTab({super.key});

  @override
  State<AdminShopsTab> createState() => _AdminShopsTabState();
}

class _AdminShopsTabState extends State<AdminShopsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  List<Map<String, dynamic>> _pending = [];
  List<Map<String, dynamic>> _approved = [];
  List<Map<String, dynamic>> _rejected = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _token => GetStorage().read("token") ?? "";

  Future<void> _loadAll() async {
    setState(() => _loading = true);

    try {
      final results = await Future.wait([
        ShopService().fetchPendingShops(token: _token),
        ShopService().fetchApprovedShops(),
        ShopService().fetchRejectedShops(token: _token),
      ]);

      setState(() {
        _pending = results[0];
        _approved = results[1];
        _rejected = results[2];
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "approved":
        return AppColors.success;
      case "rejected":
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "approved":
        return Icons.verified;
      case "rejected":
        return Icons.cancel;
      default:
        return Icons.hourglass_top;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Shops"),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.golden,
            labelColor: AppColors.darkGreen,
            unselectedLabelColor: AppColors.darkGreen.withOpacity(0.5),
            labelStyle: AppTextStyles.label,
            unselectedLabelStyle: AppTextStyles.labelMuted,
            tabs: [
              Tab(text: "Pending (${_pending.length})"),
              Tab(text: "Approved (${_approved.length})"),
              Tab(text: "Rejected (${_rejected.length})"),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _shopList(_pending, emptyText: "No pending approvals"),
                  _shopList(_approved, emptyText: "No approved shops"),
                  _shopList(_rejected, emptyText: "No rejected shops"),
                ],
              ),
      ),
    );
  }

  Widget _shopList(
    List<Map<String, dynamic>> shops, {
    required String emptyText,
  }) {
    if (shops.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAll,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 40,
                      color: AppColors.iconMuted,
                    ),
                    const SizedBox(height: 10),
                    Text(emptyText, style: AppTextStyles.bodyLarge),
                  ],
                ),
              ),
            ),
          ),
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
              onRefresh: _loadAll,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 24 : 14,
                  vertical: 14,
                ),
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  final shop = shops[index];
                  final status = (shop["status"] ?? "pending").toString();

                  return _ShopCard(
                    shop: shop,
                    statusColor: _statusColor(status),
                    statusIcon: _statusIcon(status),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => status == "approved"
                              ? ApprovedShopDetailScreen(shop: shop)
                              : ShopDetailsScreen(
                                  shop: shop,
                                  readOnly: status != "pending",
                                ),
                        ),
                      );

                      if (result == true) _loadAll();
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// =========================
// SHOP CARD
// =========================
class _ShopCard extends StatelessWidget {
  final Map<String, dynamic> shop;
  final Color statusColor;
  final IconData statusIcon;
  final VoidCallback onTap;

  const _ShopCard({
    required this.shop,
    required this.statusColor,
    required this.statusIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = (shop["status"] ?? "pending").toString();

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop["shop_name"]?.toString() ?? "-",
                    style: AppTextStyles.heading4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Owner: ${shop["owner_name"] ?? "-"}",
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Phone: ${shop["phone"] ?? "-"}",
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Chip(
                  label: Text(
                    status.toUpperCase(),
                    style: AppTextStyles.label.copyWith(
                      color: statusColor,
                      fontSize: 11,
                    ),
                  ),
                  backgroundColor: statusColor.withOpacity(0.15),
                  side: BorderSide(color: statusColor.withOpacity(0.45)),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                const SizedBox(height: 6),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.iconMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
