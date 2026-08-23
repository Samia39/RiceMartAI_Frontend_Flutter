// Path: lib/screens/admin_screens/dashboard/admin_dashboard_tab.dart
//
// Same as the last version, EXCEPT the _loadStats() parsing block —
// see the note below. This is the only functional change.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/themes.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/admin_drawer.dart';
import '../../../core/services/admin/permission_service.dart';
import '../../../core/services/admin/admin_service.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
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

  // Reads an int out of `data[key]` whether the backend sent it as a
  // real number or (like Laravel's decimal sum()) as a string —
  // avoids a runtime type crash that was silently triggering the
  // "Couldn't load dashboard stats" error banner even on a
  // successful, well-formed response.
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
          // total_revenue comes back as a STRING from the backend
          // (e.g. "19548.00") — this was the actual bug.
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
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: const AdminDrawer(),
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          centerTitle: true,
          actions: [
            if (PermissionService.hasPermission('create shop'))
              _appBarAction(
                icon: Icons.add,
                label: "Add Shop",
                color: AppColors.darkGreen,
                onTap: () => Get.toNamed(AppRoutes.addSeller),
              ),
            if (PermissionService.hasPermission('view settings'))
              _appBarAction(
                icon: Icons.settings,
                label: "Settings",
                color: Colors.blue,
                onTap: () => Get.toNamed(AppRoutes.adminSettings),
              ),
            if (PermissionService.hasPermission('view notifications'))
              _appBarAction(
                icon: Icons.notifications,
                label: "Alerts",
                color: Colors.orange,
                onTap: () => Get.toNamed(AppRoutes.adminNotifications),
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (PermissionService.hasPermission('view admin dashboard')) {
              await _loadStats();
            }
          },
          color: AppColors.darkGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
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
                  if (_hasError) _errorBanner() else _statsSection(),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // STATS SECTION
  // =========================
  Widget _statsSection() {
    if (_isLoading) {
      return Column(
        children: List.generate(
          5,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: _statSkeleton()),
                const SizedBox(width: 12),
                Expanded(child: _statSkeleton()),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: quickStatCard(
                "Users",
                "$_totalUsers",
                icon: Icons.people_alt,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: quickStatCard(
                "Sellers",
                "$_totalSellers",
                icon: Icons.storefront,
                color: AppColors.golden,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: quickStatCard(
                "Customers",
                "$_totalCustomers",
                icon: Icons.person,
                color: AppColors.lightGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: quickStatCard(
                "Total Shops",
                "$_totalShops",
                icon: Icons.store,
                color: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: quickStatCard(
                "Pending Shops",
                "$_pendingShops",
                icon: Icons.hourglass_top,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: quickStatCard(
                "Approved Shops",
                "$_approvedShops",
                icon: Icons.verified,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: quickStatCard(
                "Rejected Shops",
                "$_rejectedShops",
                icon: Icons.cancel,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: quickStatCard(
                "Orders",
                "$_totalOrders",
                icon: Icons.shopping_bag,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: quickStatCard(
                "Active Products",
                "$_activeProducts",
                icon: Icons.inventory_2,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: quickStatCard(
                "Pending Payments",
                "$_pendingPayments",
                icon: Icons.pending_actions,
                color: AppColors.info,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        quickStatCard(
          "Total Revenue",
          _formatMoney(_totalRevenue),
          icon: Icons.payments,
          color: AppColors.darkGreen,
          highlight: true,
        ),
      ],
    );
  }

  Widget _statSkeleton() {
    return Container(
      height: 80,
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

  Widget _appBarAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // =========================
  // QUICK STATS CARD
  // =========================
  Widget quickStatCard(
    String title,
    String value, {
    IconData? icon,
    Color? color,
    bool highlight = false,
  }) {
    final accent = color ?? AppColors.darkGreen;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: highlight
          ? AppDecorations.card.copyWith(
              gradient: LinearGradient(
                colors: [accent.withOpacity(0.18), accent.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            )
          : AppDecorations.card,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.heading4),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.heading3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
