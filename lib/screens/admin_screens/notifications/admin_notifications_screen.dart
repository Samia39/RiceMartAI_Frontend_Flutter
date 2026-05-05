import 'package:flutter/material.dart';
import '../../../core/utils/themes.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  List<Map<String, String>> notifications = [
    {"title": "New Shop Approval Request", "time": "5 mins ago"},

    {"title": "Fraud Complaint Reported", "time": "20 mins ago"},

    {"title": "Payout Request Pending", "time": "1 hour ago"},
  ];

  void clearNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Notification cleared")));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Admin Notifications")),

        body: ListView.builder(
          padding: const EdgeInsets.all(18),

          itemCount: notifications.length,

          itemBuilder: (context, index) {
            var item = notifications[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 15),

              padding: const EdgeInsets.all(16),

              decoration: AppDecorations.card,

              child: Row(
                children: [
                  const Icon(Icons.notifications, size: 34),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(item["title"]!, style: AppTextStyles.heading4),

                        const SizedBox(height: 5),

                        Text(item["time"]!),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      clearNotification(index);
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
