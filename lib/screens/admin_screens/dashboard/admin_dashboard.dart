import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/themes.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/admin_drawer.dart';
import '../../../core/services/permission_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

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
            // =========================
            // ADD SHOP
            // =========================
            if (PermissionService.hasPermission('create shop'))
              Padding(
                padding: const EdgeInsets.only(right: 12),

                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.addSeller);
                  },

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Container(
                        width: 38,
                        height: 38,

                        decoration: const BoxDecoration(
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

            // =========================
            // SETTINGS
            // =========================
            if (PermissionService.hasPermission('view settings'))
              Padding(
                padding: const EdgeInsets.only(right: 12),

                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.adminSettings);
                  },

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Container(
                        width: 38,
                        height: 38,

                        decoration: const BoxDecoration(
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

            // =========================
            // NOTIFICATIONS
            // =========================
            if (PermissionService.hasPermission('view notifications'))
              Padding(
                padding: const EdgeInsets.only(right: 12),

                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.adminNotifications);
                  },

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Container(
                        width: 38,
                        height: 38,

                        decoration: const BoxDecoration(
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

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text("Admin Controls", style: AppTextStyles.heading2),

              const SizedBox(height: 20),

              // =========================
              // QUICK STATS
              // =========================
              if (PermissionService.hasPermission('view dashboard'))
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

              // =========================
              // SEARCH
              // =========================
              if (PermissionService.hasPermission('view users') ||
                  PermissionService.hasPermission('view shops') ||
                  PermissionService.hasPermission('view orders'))
                TextField(
                  onSubmitted: (value) {
                    Get.toNamed(AppRoutes.adminSearch, arguments: value);
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

              // =========================
              // ANALYTICS
              // =========================
              if (PermissionService.hasPermission('view analytics'))
                adminCard(
                  title: "Analytics",
                  subtitle: "Platform insights",
                  icon: Icons.analytics,

                  onTap: () {
                    Get.toNamed(AppRoutes.analytics);
                  },
                ),

              const SizedBox(height: 20),

              // =========================
              // SELLER APPROVALS
              // =========================
              if (PermissionService.hasPermission('approve shops'))
                adminCard(
                  title: "Seller Approvals",
                  subtitle: "Approve shops and verify sellers",
                  icon: Icons.store_mall_directory,

                  onTap: () {
                    Get.toNamed(AppRoutes.sellerApprovals);
                  },
                ),

              const SizedBox(height: 20),

              // =========================
              // APPROVED SHOPS
              // =========================
              if (PermissionService.hasPermission('view shops'))
                adminCard(
                  title: "Approved Shops",
                  subtitle: "Manage active shops",
                  icon: Icons.verified,

                  onTap: () {
                    Get.toNamed(AppRoutes.approvedShops);
                  },
                ),

              const SizedBox(height: 20),

              // =========================
              // REPORTS
              // =========================
              if (PermissionService.hasPermission('manage reports'))
                adminCard(
                  title: "Reports",
                  subtitle: "Feedback and complaints",
                  icon: Icons.report_problem,

                  onTap: () {
                    Get.toNamed(AppRoutes.reports);
                  },
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // ADMIN CARD
  // =========================
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

  // =========================
  // QUICK STATS CARD
  // =========================
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
