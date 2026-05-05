import 'package:flutter/material.dart';
import 'package:frontend/screens/create_shop_screen.dart';
import 'package:frontend/screens/admin_screens/analytics/analytics_screen.dart';
import 'package:frontend/screens/admin_screens/notifications/admin_notifications_screen.dart';
import 'package:frontend/screens/admin_screens/search/admin_search_results_screen.dart';
import 'package:frontend/screens/admin_screens/settings/admin_settings_screen.dart';
import 'package:frontend/screens/admin_screens/shops/approved_shops_screen.dart';
import 'package:frontend/screens/admin_screens/orders/orders_management_screen.dart';
import 'package:frontend/screens/admin_screens/payments/payments_screen.dart';
import 'package:frontend/screens/admin_screens/reports/reports_screen.dart';
import 'package:frontend/screens/admin_screens/users/user_management_screen.dart';
import '../../../core/utils/themes.dart';
import '../shops/shop_approvals_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          centerTitle: true,

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),

              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateShopScreen()),
                  );
                },

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Container(
                      width: 38,
                      height: 38,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.darkGreen,
                      ),

                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text("Add Shop", style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ),

            /// Settings
            Padding(
              padding: const EdgeInsets.only(right: 12),

              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminSettingsScreen(),
                    ),
                  );
                },

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Container(
                      width: 38,
                      height: 38,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),

                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text("Settings", style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),

              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminNotificationsScreen(),
                    ),
                  );
                },

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Container(
                      width: 38,
                      height: 38,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),

                      child: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text("Alerts", style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        ),

        // FIXED: scrollable body
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text("Admin Controls", style: AppTextStyles.heading2),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: quickStatCard("Users", "1240")),

                    const SizedBox(width: 12),

                    Expanded(child: quickStatCard("Orders", "520")),
                  ],
                ),

                const SizedBox(height: 12),

                quickStatCard("Revenue", "Rs 2.3M"),

                const SizedBox(height: 25),
                TextField(
                  onSubmitted: (value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminSearchResultsScreen(query: value),
                      ),
                    );
                  },

                  decoration: InputDecoration(
                    hintText: "Search users, sellers, shops, orders...",

                    prefixIcon: const Icon(Icons.search),

                    filled: true,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                const SizedBox(height: 25),

                adminCard(
                  title: "Analytics",
                  subtitle: "Platform insights",
                  icon: Icons.analytics,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AnalyticsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Pending Shops
                adminCard(
                  title: "Seller Approvals",
                  subtitle: "Approve shops and verify sellers",
                  icon: Icons.store_mall_directory,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ShopApprovalsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Approved Shops
                adminCard(
                  title: "Approved Shops",
                  subtitle: "Manage active shops",
                  icon: Icons.verified,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ApprovedShopsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Users
                adminCard(
                  title: "Users",
                  subtitle: "View all users",
                  icon: Icons.people,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserManagementScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Market Prices
                adminCard(
                  title: "Market Prices",
                  subtitle: "Manage rice prices",
                  icon: Icons.bar_chart,
                  onTap: () {},
                ),

                const SizedBox(height: 20),

                // Orders
                adminCard(
                  title: "Orders",
                  subtitle: "Manage customer orders",
                  icon: Icons.shopping_cart,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrdersManagementScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Payments
                adminCard(
                  title: "Payments",
                  subtitle: "Commission and payouts",
                  icon: Icons.payments,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaymentsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // feedback
                adminCard(
                  title: "Reports",
                  subtitle: "Feedback and complaints",
                  icon: Icons.report_problem,

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportsScreen()),
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget adminCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppDecorations.card,

        child: Row(
          children: [
            Icon(icon, size: 36, color: AppColors.darkGreen),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.heading4),

                  const SizedBox(height: 4),

                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }

  Widget quickStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: AppDecorations.card,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(title, style: AppTextStyles.heading4),

          const SizedBox(height: 8),

          Text(value, style: AppTextStyles.heading3),
        ],
      ),
    );
  }
}
