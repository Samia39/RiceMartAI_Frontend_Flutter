import 'package:flutter/material.dart';
import '../../../core/utils/themes.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Analytics Dashboard")),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text("Platform Overview", style: AppTextStyles.heading2),

              const SizedBox(height: 20),

              statCard("Total Users", "1,240", Icons.people),

              const SizedBox(height: 15),

              statCard("Registered Shops", "146", Icons.store),

              const SizedBox(height: 15),

              statCard("Total Orders", "520", Icons.shopping_cart),

              const SizedBox(height: 15),

              statCard("Revenue", "Rs 2.3M", Icons.payments),

              const SizedBox(height: 25),

              Text("Top Rice Categories", style: AppTextStyles.heading3),

              const SizedBox(height: 15),

              categoryCard("Super Basmati", "320 Orders"),

              categoryCard("Brown Rice", "180 Orders"),

              categoryCard("IRRI Rice", "140 Orders"),

              const SizedBox(height: 25),

              Text("Pending Actions", style: AppTextStyles.heading3),

              const SizedBox(height: 15),

              statCard("Pending Shop Approvals", "12", Icons.pending_actions),

              const SizedBox(height: 15),

              statCard("Open Complaints", "5", Icons.report_problem),

              const SizedBox(height: 25),

              Text("Recent Activity", style: AppTextStyles.heading3),

              const SizedBox(height: 15),

              activityCard("New seller registered", "2 mins ago"),

              activityCard("Shop approved", "15 mins ago"),

              activityCard("Order completed", "1 hour ago"),
            ],
          ),
        ),
      ),
    );
  }

  Widget statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: AppDecorations.card,

      child: Row(
        children: [
          Icon(icon, size: 36),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(title, style: AppTextStyles.heading4),

                const SizedBox(height: 6),

                Text(value, style: AppTextStyles.heading3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryCard(String name, String orders) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: AppDecorations.card,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(name, style: AppTextStyles.heading4),

          Text(orders),
        ],
      ),
    );
  }

  Widget activityCard(String title, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: AppDecorations.card,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(title, style: AppTextStyles.heading4),

          Text(time),
        ],
      ),
    );
  }
}
