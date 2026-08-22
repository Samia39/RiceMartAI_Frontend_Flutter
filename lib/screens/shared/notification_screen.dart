import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/services/notification_service.dart';
import '../../core/services/order_service.dart';
import '../../core/utils/themes.dart';
import '../../routes/app_routes.dart';

// Role-specific order detail screens — each expects a different shape,
// so we can't just push one generic screen with an order_id.
import '../buyer/orders/order_details_screen.dart';
import '../seller/order/seller_order_details_screen.dart';
import '../admin_screens/orders/admin_order_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  final _orderService = OrderService();
  final _box = GetStorage();

  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;
  bool isNavigating = false; // prevents double-taps while we fetch

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    final data = await _service.fetchNotifications();
    setState(() {
      notifications = data;
      isLoading = false;
    });
  }

  Future<void> _markAllRead() async {
    final ok = await _service.markAllAsRead();
    if (ok) {
      setState(() {
        for (var n in notifications) {
          n['is_read'] = true;
        }
      });
    }
  }

  // =========================
  // ROLE HELPER
  // (matches the "role" key already stored at login — same source
  // PermissionService/dashboards read from)
  // =========================
  String get _role => (_box.read('role') ?? '').toString().toLowerCase();

  bool get _isAdmin => _role == 'admin' || _role == 'super_admin';
  bool get _isSeller => _role == 'seller';

  // =========================
  // MAIN TAP HANDLER
  // =========================
  Future<void> _onTapNotification(Map<String, dynamic> n) async {
    if (n['is_read'] != true) {
      final ok = await _service.markAsRead(n['id']);
      if (ok && mounted) setState(() => n['is_read'] = true);
    }

    final type = n['type']?.toString() ?? '';
    final data = Map<String, dynamic>.from(n['data'] ?? {});

    switch (type) {
      case 'chat_message':
        _openChat(data);
        break;

      case 'order_placed':
      case 'order_status':
      case 'payment_status':
      case 'payment_release':
        await _openOrder(data);
        break;

      case 'shop_pending':
        // Only admins get this type — send them to the approvals queue
        Get.toNamed(AppRoutes.sellerApprovals);
        break;

      case 'shop_status':
        // Only sellers get this type — send them to their own shop
        Get.toNamed(AppRoutes.myShop);
        break;

      default:
        // Unknown/future type — do nothing beyond marking as read
        break;
    }
  }

  // =========================
  // CHAT — conversation_id is enough, ChatScreen falls back to
  // "Chat" as the title if other_name isn't supplied.
  // =========================
  void _openChat(Map<String, dynamic> data) {
    final conversationId = data['conversation_id'];
    if (conversationId == null) return;

    Get.toNamed(AppRoutes.chat, arguments: {"conversation_id": conversationId});
  }

  // =========================
  // ORDER — fetch the right list for the current role, find the
  // matching record, then push the role-specific detail screen.
  //
  // NOTE: firstWhereOrNull below is an EXTENSION METHOD (defined at the
  // bottom of this file) — it's called directly on the list itself,
  // e.g. `myList.firstWhereOrNull(test)`, never as `SomeName(myList)...`.
  // =========================
  Future<void> _openOrder(Map<String, dynamic> data) async {
    final orderId = data['order_id'];
    if (orderId == null || isNavigating) return;

    setState(() => isNavigating = true);

    try {
      if (_isAdmin) {
        final active = await _orderService.getAdminOrders();
        final history = await _orderService.getAdminOrderHistory();
        final all = [...active, ...history];

        final found = all.firstWhereOrNull((o) => o['id'] == orderId);

        if (found != null) {
          await Get.to(
            () => AdminOrderDetailsScreen(
              order: found,
              isHistory: history.any((o) => o['id'] == orderId),
            ),
          );
        } else {
          Get.snackbar("Not found", "This order could not be loaded.");
        }
      } else if (_isSeller) {
        final items = await _orderService.fetchSellerOrders();

        // Notification stores order_id, but the seller screen needs an
        // order ITEM — pick the first item belonging to that order.
        final found = items.firstWhereOrNull(
          (i) => i['order']?['id'] == orderId,
        );

        if (found != null) {
          await Get.to(() => SellerOrderDetailScreen(item: found));
        } else {
          Get.snackbar("Not found", "This order could not be loaded.");
        }
      } else {
        // Buyer
        final active = await _orderService.getActiveOrders();
        final history = await _orderService.getOrderHistory();
        final all = [...active, ...history];

        final found = all.firstWhereOrNull((o) => o['id'] == orderId);

        if (found != null) {
          await Get.toNamed(AppRoutes.orderDetails, arguments: found);
        } else {
          Get.snackbar("Not found", "This order could not be loaded.");
        }
      }
    } finally {
      if (mounted) setState(() => isNavigating = false);
    }
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'order_placed':
      case 'order_status':
        return Icons.shopping_bag_rounded;
      case 'payment_status':
      case 'payment_release':
        return Icons.payments_rounded;
      case 'shop_status':
      case 'shop_pending':
        return Icons.storefront_rounded;
      case 'chat_message':
        return Icons.chat_bubble_rounded;
      case 'review':
        return Icons.star_rounded;
      case 'low_stock':
        return Icons.inventory_2_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: Text(
              "Mark all read",
              style: TextStyle(color: AppColors.darkGreen.withOpacity(0.85)),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.darkGreen),
            )
          : notifications.isEmpty
          ? Center(
              child: Text(
                "No notifications yet",
                style: AppTextStyles.bodyMedium,
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.darkGreen,
              child: ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  final isRead = n['is_read'] == true;

                  return ListTile(
                    onTap: () => _onTapNotification(n),
                    tileColor: isRead
                        ? null
                        : AppColors.darkGreen.withOpacity(0.06),
                    leading: CircleAvatar(
                      backgroundColor: isRead
                          ? AppColors.darkGreen.withOpacity(0.05)
                          : AppColors.darkGreen.withOpacity(0.15),
                      child: Icon(
                        _iconForType(n['type']),
                        color: isRead
                            ? AppColors.iconMuted
                            : AppColors.darkGreen,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      n['title'] ?? '',
                      style: TextStyle(
                        color: AppColors.darkGreen,
                        fontWeight: isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      n['body'] ?? '',
                      style: AppTextStyles.bodySmall,
                    ),
                    trailing: Text(
                      _timeAgo(n['created_at']),
                      style: TextStyle(fontSize: 11, color: AppColors.hintText),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// firstWhereOrNull is already provided by package:get (GetX), imported
// at the top of this file — no need to define it here.
