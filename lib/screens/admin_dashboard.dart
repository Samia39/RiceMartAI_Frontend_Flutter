// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/utils/themes.dart';
import '../core/services/auth_service.dart';
import '../widgets/app_drawer.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final user = AuthService.getCurrentUser();

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context, user),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppDecorations.iconButton,
                        child: Icon(Icons.menu,
                            color: AppColors.darkGreen, size: 24),
                      ),
                    ),
                    Text('Admin Dashboard',
                        style: AppTextStyles.heading3),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // ── Admin Controls Title ──────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Admin Controls',
                    style: AppTextStyles.heading2),
              ),
              const SizedBox(height: 16),

              // ── Revenue Card ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cream.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.borderGold.withOpacity(0.45)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Revenue',
                          style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 4),
                      Text('Rs 2.3M',
                          style: AppTextStyles.heading2),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Search Bar ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: AppDecorations.inputField,
                  child: TextField(
                    style: AppTextStyles.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Search users, sellers, shops, orders...',
                      hintStyle: AppTextStyles.hint,
                      prefixIcon: Icon(Icons.search,
                          color: AppColors.iconMuted),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Seller Approvals Button ───────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => Get.toNamed('/admin-shops'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cream.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.borderGold.withOpacity(0.45)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.darkGreen.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.store,
                              color: AppColors.darkGreen, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Seller Approvals',
                                  style: AppTextStyles.heading4),
                              Text('Approve shops and verify sellers',
                                  style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: AppColors.iconMuted),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Payments Button ───────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cream.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.borderGold.withOpacity(0.45)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.darkGreen.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.account_balance_wallet,
                              color: AppColors.darkGreen, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Payments',
                                  style: AppTextStyles.heading4),
                              Text('Commission and payouts',
                                  style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: AppColors.iconMuted),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, Map user) {
    return Drawer(
      width: 285,
      backgroundColor: Colors.transparent,
      child: Container(
        color: AppColors.cream,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 54, 20, 22),
              color: AppColors.darkGreen,
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cream.withOpacity(0.20),
                      border: Border.all(
                          color: AppColors.borderGold, width: 2),
                    ),
                    child: Icon(Icons.admin_panel_settings,
                        color: AppColors.cream, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['name'] ?? 'Admin',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.cream,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          )),
                      Text('Admin',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.cream.withOpacity(0.70),
                            fontSize: 12,
                          )),
                    ],
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerTile(Icons.dashboard_outlined, 'Dashboard',
                      onTap: () {
                    Navigator.pop(context);
                    Get.offNamed('/admin-dashboard');
                  }),
                  _drawerTile(Icons.pending_outlined, 'Pending Shops',
                      onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/admin-shops',
                        arguments: 'pending');
                  }),
                  _drawerTile(Icons.check_circle_outline, 'Approved Shops',
                      onTap: () {
                    Navigator.pop(context);
                    Get.toNamed('/admin-shops',
                        arguments: 'approved');
                  }),
                  _drawerTile(Icons.shopping_bag_outlined, 'Orders',
                      onTap: () => Navigator.pop(context)),
                  _drawerExpansion(
                    Icons.people_outline,
                    'User Management',
                    [
                      _drawerSubTile(Icons.person_outline, 'Users', () {
                        Navigator.pop(context);
                      }),
                      _drawerSubTile(Icons.badge_outlined, 'Roles', () {
                        Navigator.pop(context);
                      }),
                      _drawerSubTile(
                          Icons.lock_outline, 'Assign Permissions', () {
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                  _drawerTile(Icons.bar_chart_outlined, 'Reports',
                      onTap: () => Navigator.pop(context)),
                  _drawerTile(Icons.settings_outlined, 'Settings',
                      onTap: () => Navigator.pop(context)),
                ],
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () async {
                  await AuthService.logout();
                  Get.offAllNamed('/login');
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.error.withOpacity(0.30)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.logout,
                          color: AppColors.error, size: 22),
                      const SizedBox(width: 12),
                      Text('Logout',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.error,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerTile(IconData icon, String label,
      {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkGreen, size: 22),
      title: Text(label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.darkGreen,
          )),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }

  Widget _drawerExpansion(
      IconData icon, String label, List<Widget> children) {
    return Theme(
      data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.darkGreen, size: 22),
        title: Text(label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGreen,
            )),
        iconColor: AppColors.darkGreen,
        collapsedIconColor: AppColors.darkGreen,
        children: children,
      ),
    );
  }

  Widget _drawerSubTile(
      IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkGreen.withOpacity(0.65), size: 20),
      title: Text(label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: AppColors.darkGreen.withOpacity(0.85),
          )),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
    );
  }
}