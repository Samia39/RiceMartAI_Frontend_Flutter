import 'dart:convert';

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
  // =========================
  String get _role => (_box.read('role') ?? '').toString().toLowerCase();

  bool get _isAdmin => _role == 'admin' || _role == 'super_admin';
  bool get _isSeller => _role == 'seller';

  // =========================
  // SAFE DATA EXTRACTION
  // Handles the case where the backend's `data` column comes back as
  // an already-decoded Map (correct, if AppNotification casts it to
  // `array`) OR as a raw JSON string (happens if that cast is missing
  // or bypassed). Previously `Map<String,dynamic>.from(n['data'])`
  // would throw on a String and silently kill navigation — this never
  // throws, it just returns {} if it truly can't parse anything.
  // =========================
  Map<String, dynamic> _extractData(dynamic raw) {
    if (raw == null) return {};
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        // not valid JSON — fall through to {}
      }
    }
    return {};
  }

  // =========================
  // MAIN TAP HANDLER
  // =========================
  Future<void> _onTapNotification(Map<String, dynamic> n) async {
    if (n['is_read'] != true) {
      final ok = await _service.markAsRead(n['id']);
      if (ok && mounted) setState(() => n['is_read'] = true);
    }

    final type = n['type']?.toString() ?? '';
    final data = _extractData(n['data']);

    try {
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
          Get.toNamed(AppRoutes.sellerApprovals);
          break;

        case 'shop_status':
          Get.toNamed(AppRoutes.myShop);
          break;

        default:
          break;
      }
    } catch (e) {
      // Previously any error here (e.g. a bad cast) failed completely
      // silently. Now the user at least sees something went wrong.
      if (mounted) {
        Get.snackbar("Couldn't open notification", e.toString());
      }
    }
  }

  void _openChat(Map<String, dynamic> data) {
    final conversationId = data['conversation_id'];
    if (conversationId == null) return;

    Get.toNamed(AppRoutes.chat, arguments: {"conversation_id": conversationId});
  }

  Future<void> _openOrder(Map<String, dynamic> data) async {
    final orderId = data['order_id'];
    if (orderId == null || isNavigating) return;

    setState(() => isNavigating = true);

    try {
      if (_isAdmin) {
        final active = await _orderService.getAdminOrders();
        final history = await _orderService.getAdminOrderHistory();
        final all = [...active, ...history];

        final found = all.firstWhereOrNull((o) => '${o['id']}' == '$orderId');

        if (found != null) {
          await Get.to(
            () => AdminOrderDetailsScreen(
              order: found,
              isHistory: history.any((o) => '${o['id']}' == '$orderId'),
            ),
          );
        } else {
          Get.snackbar("Not found", "This order could not be loaded.");
        }
      } else if (_isSeller) {
        final items = await _orderService.fetchSellerOrders();

        final found = items.firstWhereOrNull(
          (i) => '${i['order']?['id']}' == '$orderId',
        );

        if (found != null) {
          await Get.to(() => SellerOrderDetailScreen(item: found));
        } else {
          Get.snackbar("Not found", "This order could not be loaded.");
        }
      } else {
        final active = await _orderService.getActiveOrders();
        final history = await _orderService.getOrderHistory();
        final all = [...active, ...history];

        final found = all.firstWhereOrNull((o) => '${o['id']}' == '$orderId');

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            style: AppButtonStyles.ghost,
            child: Text(
              "Mark all read",
              style: AppTextStyles.button.copyWith(
                color: AppColors.darkGreen,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.darkGreen),
                )
              : notifications.isEmpty
              ? Center(
                  child: Text(
                    "No notifications yet",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.darkGreen,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.darkGreen,
                  backgroundColor: AppColors.cream,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      final isRead = n['is_read'] == true;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _onTapNotification(n),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? AppColors.cardFill
                                    : AppColors.cream.withOpacity(0.45),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isRead
                                      ? AppColors.cardBorder
                                      : AppColors.golden.withOpacity(0.65),
                                  width: isRead ? 1 : 1.4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.darkGreen.withOpacity(
                                      0.06,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Unread dot in golden, matches dashboard accent
                                  Container(
                                    width: 44,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isRead
                                          ? AppColors.lightGreen.withOpacity(
                                              0.18,
                                            )
                                          : AppColors.golden.withOpacity(0.25),
                                      border: Border.all(
                                        color: isRead
                                            ? AppColors.borderGold.withOpacity(
                                                0.4,
                                              )
                                            : AppColors.golden,
                                        width: isRead ? 1 : 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      _iconForType(n['type']),
                                      color: isRead
                                          ? AppColors.iconMuted
                                          : AppColors.darkGreen,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                n['title'] ?? '',
                                                style: AppTextStyles.label
                                                    .copyWith(
                                                      fontWeight: isRead
                                                          ? FontWeight.w600
                                                          : FontWeight.w800,
                                                    ),
                                              ),
                                            ),
                                            if (!isRead)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                margin: const EdgeInsets.only(
                                                  left: 6,
                                                ),
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.golden,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          n['body'] ?? '',
                                          style: AppTextStyles.bodySmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _timeAgo(n['created_at']),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.hintText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

// firstWhereOrNull is already provided by package:get (GetX), imported
// at the top of this file — no need to define it here.
