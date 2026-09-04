// Path: lib/screens/admin_screens/dashboard/admin_dashboard_tab.dart
//
// NAV REFACTOR: this screen no longer owns its own Scaffold/AppBar/
// Drawer — those moved to AdminHomeShell so they stay visible on every
// bottom-nav tab instead of disappearing on Shops/Orders/Payments.
// This widget now returns only the body content.

import 'package:flutter/material.dart';
import '../../../core/utils/themes.dart';
import '../../../core/services/admin/permission_service.dart';
import '../../../core/services/admin/admin_service.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlight;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.highlight = false,
  });
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  final AdminService _adminService = AdminService();

  bool _isLoading = true;
  bool _hasError = false;

  int _totalUsers = 0;
  int _totalSellers = 0;
  int _totalCustomers = 0;
  int _totalShops = 0;
  int _pendingShops = 0;
  int _approvedShops = 0;
  int _rejectedShops = 0;
  int _totalOrders = 0;
  num _totalRevenue = 0;
  int _activeProducts = 0;
  int _pendingPayments = 0;

  @override
  void initState() {
    super.initState();
    if (PermissionService.hasPermission('view admin dashboard')) {
      _loadStats();
    } else {
      _isLoading = false;
    }
  }

  int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  num _asNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await _adminService.getAdminDashboardStats();

      if (response['success'] == true) {
        final data = response['data'];

        setState(() {
          _totalUsers = _asInt(data['total_users']);
          _totalSellers = _asInt(data['total_sellers']);
          _totalCustomers = _asInt(data['total_customers']);
          _totalShops = _asInt(data['total_shops']);
          _pendingShops = _asInt(data['pending_shops']);
          _approvedShops = _asInt(data['approved_shops']);
          _rejectedShops = _asInt(data['rejected_shops']);
          _totalOrders = _asInt(data['total_orders']);
          _totalRevenue = _asNum(data['total_revenue']);
          _activeProducts = _asInt(data['active_products']);
          _pendingPayments = _asInt(data['pending_payments']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String _formatMoney(num value) {
    final str = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromRight = str.length - i;
      buffer.write(str[i]);
      if (posFromRight > 1 && (posFromRight - 1) % 3 == 0) {
        buffer.write(',');
      }
    }
    return "Rs $buffer";
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if (PermissionService.hasPermission('view admin dashboard')) {
          await _loadStats();
        }
      },
      color: AppColors.darkGreen,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isNarrow = width < 360;
          final isWide = width >= 600;

          final horizontalPadding = isNarrow ? 14.0 : (isWide ? 28.0 : 20.0);
          final crossAxisCount = isWide ? 3 : 2;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Admin Controls", style: AppTextStyles.heading2),
                const SizedBox(height: 6),
                Text(
                  "Overview of the whole platform",
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 20),

                if (PermissionService.hasPermission('view admin dashboard'))
                  if (_hasError)
                    _errorBanner()
                  else
                    _statsSection(
                      crossAxisCount: crossAxisCount,
                      isNarrow: isNarrow,
                    ),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statsSection({required int crossAxisCount, required bool isNarrow}) {
    if (_isLoading) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isNarrow ? 1.4 : 1.7,
        ),
        itemBuilder: (_, __) => _statSkeleton(),
      );
    }

    final items = <_StatItem>[
      _StatItem(
        title: "Users",
        value: "$_totalUsers",
        icon: Icons.people_alt,
        color: AppColors.darkGreen,
      ),
      _StatItem(
        title: "Sellers",
        value: "$_totalSellers",
        icon: Icons.storefront,
        color: AppColors.golden,
      ),
      _StatItem(
        title: "Customers",
        value: "$_totalCustomers",
        icon: Icons.person,
        color: AppColors.lightGreen,
      ),
      _StatItem(
        title: "Total Shops",
        value: "$_totalShops",
        icon: Icons.store,
        color: AppColors.info,
      ),
      _StatItem(
        title: "Pending Shops",
        value: "$_pendingShops",
        icon: Icons.hourglass_top,
        color: AppColors.warning,
      ),
      _StatItem(
        title: "Approved Shops",
        value: "$_approvedShops",
        icon: Icons.verified,
        color: AppColors.success,
      ),
      _StatItem(
        title: "Rejected Shops",
        value: "$_rejectedShops",
        icon: Icons.cancel,
        color: AppColors.error,
      ),
      _StatItem(
        title: "Orders",
        value: "$_totalOrders",
        icon: Icons.shopping_bag,
        color: AppColors.warning,
      ),
      _StatItem(
        title: "Active Products",
        value: "$_activeProducts",
        icon: Icons.inventory_2,
        color: AppColors.success,
      ),
      _StatItem(
        title: "Pending Payments",
        value: "$_pendingPayments",
        icon: Icons.pending_actions,
        color: AppColors.info,
      ),
    ];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isNarrow ? 1.4 : 1.7,
          ),
          itemBuilder: (_, i) => quickStatCard(items[i], isNarrow: isNarrow),
        ),
        const SizedBox(height: 12),
        quickStatCard(
          _StatItem(
            title: "Total Revenue",
            value: _formatMoney(_totalRevenue),
            icon: Icons.payments,
            color: AppColors.darkGreen,
            highlight: true,
          ),
          isNarrow: isNarrow,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _statSkeleton() {
    return Container(
      decoration: AppDecorations.card,
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }

  Widget _errorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Couldn't load dashboard stats.",
              style: AppTextStyles.bodyMedium,
            ),
          ),
          TextButton(onPressed: () => _loadStats(), child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget quickStatCard(
    _StatItem item, {
    required bool isNarrow,
    bool fullWidth = false,
  }) {
    final accent = item.color;
    final cardPadding = isNarrow ? 12.0 : 16.0;
    final iconBoxPadding = isNarrow ? 8.0 : 10.0;
    final iconSize = isNarrow ? 18.0 : 20.0;

    final card = Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.all(cardPadding),
      decoration: item.highlight
          ? AppDecorations.card.copyWith(
              gradient: LinearGradient(
                colors: [accent.withOpacity(0.18), accent.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            )
          : AppDecorations.card,
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(iconBoxPadding),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: accent, size: iconSize),
          ),
          SizedBox(width: isNarrow ? 8 : 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.heading4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(item.value, style: AppTextStyles.heading3, maxLines: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return fullWidth ? card : SizedBox.expand(child: card);
  }
}
