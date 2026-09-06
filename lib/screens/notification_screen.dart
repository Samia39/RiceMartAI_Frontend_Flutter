import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/services/notification_service.dart';
import '../models/app_notification_model.dart';
import 'user_dashboard.dart'; // AppColors, AppGradients, AppTextStyles

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<AppNotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final token = AuthService.getToken() ?? '';
      final result = await NotificationService.fetchNotifications(token);
      setState(() {
        _notifications = result['notifications'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "$e";
        _isLoading = false;
      });
    }
  }

  Future<void> _markRead(AppNotificationModel n) async {
    if (n.isRead) return;
    final token = AuthService.getToken() ?? '';
    await NotificationService.markAsRead(token, n.id);
    _loadNotifications();
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'chat_message':
        return Icons.chat_bubble_outline;
      case 'shop_created':
        return Icons.storefront_outlined;
      case 'shop_approved':
        return Icons.check_circle_outline;
      case 'shop_rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 16, 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cream.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.borderGold.withOpacity(0.50)),
                        ),
                        child: Icon(Icons.arrow_back,
                            color: AppColors.darkGreen, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      "Notifications",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: AppColors.darkGreen))
                    : _error != null
                        ? Center(
                            child: Text(_error!,
                                style: TextStyle(color: AppColors.darkGreen)))
                        : _notifications.isEmpty
                            ? Center(
                                child: Text("Koi notification nahi hai",
                                    style: AppTextStyles.labelMuted))
                            : RefreshIndicator(
                                onRefresh: _loadNotifications,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _notifications.length,
                                  itemBuilder: (context, index) {
                                    final n = _notifications[index];
                                    return GestureDetector(
                                      onTap: () => _markRead(n),
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: n.isRead
                                              ? AppColors.cardFill
                                              : AppColors.lightGreen.withOpacity(0.35),
                                          borderRadius: BorderRadius.circular(16),
                                          border:
                                              Border.all(color: AppColors.cardBorder),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(_iconFor(n.type),
                                                color: AppColors.darkGreen),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(n.title,
                                                      style: AppTextStyles.heading3
                                                          .copyWith(fontSize: 15)),
                                                  const SizedBox(height: 4),
                                                  Text(n.message,
                                                      style: AppTextStyles.bodySmall),
                                                ],
                                              ),
                                            ),
                                            if (!n.isRead)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                margin: const EdgeInsets.only(top: 4),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}