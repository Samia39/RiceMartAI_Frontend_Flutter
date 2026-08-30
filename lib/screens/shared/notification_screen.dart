import 'package:flutter/material.dart';
import '../seller/payout/SellerPayoutsScreen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/services/notification_service.dart';
import '../../core/services/order_service.dart';
import '../../core/services/shop_service.dart';
import '../../core/utils/themes.dart';
import '../../routes/app_routes.dart';

import '../buyer/orders/order_details_screen.dart';
import '../seller/order/seller_order_details_screen.dart';
import '../admin_screens/orders/admin_order_details_screen.dart';

import '../admin_screens/complaints/admin_complaint_detail_screen.dart';
import '../buyer/complaints/customer_complaint_detail_screen.dart';
import '../seller/complaints/seller_complaint_detail_screen.dart';

import '..//admin_screens/payout/admin_payouts_screen.dart';
import '../admin_screens/shops/approved_shop_detail_screen.dart';

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
  bool isNavigating = false;

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
  // FIX: login/loadUser save the key as 'roles' (plural, a LIST —
  // e.g. ["admin"] or ["seller"]), never a singular 'role' string.
  // Reading 'role' below always returned null, so _isAdmin/_isSeller
  // were silently broken for everyone except a literal "full access"
  // permission match. Read the actual 'roles' list instead.
  //
  // Normalized to ignore spacing/casing/underscore differences
  // ("Super Admin", "super-admin", "SuperAdmin" all match), plus a
  // fallback check against cached permissions (mirrors the backend's
  // `$user->can('full access')` check for super admin).
  // =========================

  List<String> get _rawRoles {
    final stored = _box.read('roles');
    if (stored is List) {
      return stored.map((r) => r.toString().toLowerCase().trim()).toList();
    }
    return [];
  }

  List<String> get _normalizedRoles =>
      _rawRoles.map((r) => r.replaceAll(RegExp(r'[\s_-]'), '')).toList();

  bool get _hasFullAccessPermission {
    final permissions = _box.read('permissions');

    if (permissions is List) {
      return permissions
          .map((p) => p.toString().toLowerCase())
          .contains('full access');
    }

    return false;
  }

  bool get _isAdmin =>
      _normalizedRoles.contains('admin') ||
      _normalizedRoles.contains('superadmin') ||
      _hasFullAccessPermission;

  bool get _isSeller => _normalizedRoles.contains('seller');

  // =========================
  // MAIN TAP HANDLER
  // =========================

  Future<void> _onTapNotification(Map<String, dynamic> n) async {
    if (n['is_read'] != true) {
      final ok = await _service.markAsRead(n['id']);

      if (ok && mounted) {
        setState(() => n['is_read'] = true);
      }
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
        await _openOrder(data);
        break;

      case 'payment_release':
      case 'payout_paid':
        _openPayouts();
        break;

      case 'shop_pending':
        Get.toNamed(AppRoutes.sellerApprovals);
        break;

      case 'shop_status':
        Get.toNamed(AppRoutes.myShop);
        break;

      case 'complaint':
        _openComplaint(data);
        break;

      case 'review':
        await _openReview(data);
        break;

      default:
        break;
    }
  }

  void _openChat(Map<String, dynamic> data) {
    final conversationId = data['conversation_id'];

    if (conversationId == null) return;

    Get.toNamed(AppRoutes.chat, arguments: {"conversation_id": conversationId});
  }

  void _openComplaint(Map<String, dynamic> data) {
    final complaintId = data['complaint_id'];

    if (complaintId == null) return;

    final recipientRole = data['recipient_role']
        ?.toString()
        .toLowerCase()
        .trim();

    if (recipientRole == 'admin') {
      Get.to(() => AdminComplaintDetailScreen(complaintId: complaintId as int));
    } else if (recipientRole == 'seller') {
      Get.to(
        () => SellerComplaintDetailScreen(complaintId: complaintId as int),
      );
    } else if (recipientRole == 'customer') {
      Get.to(
        () => CustomerComplaintDetailScreen(complaintId: complaintId as int),
      );
    } else if (_isAdmin) {
      Get.to(() => AdminComplaintDetailScreen(complaintId: complaintId as int));
    } else if (_isSeller) {
      Get.to(
        () => SellerComplaintDetailScreen(complaintId: complaintId as int),
      );
    } else {
      Get.to(
        () => CustomerComplaintDetailScreen(complaintId: complaintId as int),
      );
    }
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

        final found = items.firstWhereOrNull(
          (i) => i['order']?['id'] == orderId,
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

        final found = all.firstWhereOrNull((o) => o['id'] == orderId);

        if (found != null) {
          await Get.toNamed(AppRoutes.orderDetails, arguments: found);
        } else {
          Get.snackbar("Not found", "This order could not be loaded.");
        }
      }
    } finally {
      if (mounted) {
        setState(() => isNavigating = false);
      }
    }
  }

  void _openPayouts() {
    if (_isAdmin) {
      Get.to(() => const AdminPayoutsScreen());
    } else if (_isSeller) {
      Get.to(() => const SellerPayoutsScreen());
    }
  }

  // =========================
  // REVIEW — seller goes to their own shop (which now shows its
  // reviews section); admin/super_admin goes to that specific shop's
  // detail screen, matched by shop_id from the notification payload.
  // =========================
  Future<void> _openReview(Map<String, dynamic> data) async {
    final shopId = data['shop_id'];

    if (shopId == null) return;

    if (_isSeller) {
      Get.toNamed(AppRoutes.myShop);
      return;
    }

    if (_isAdmin) {
      if (isNavigating) return;
      setState(() => isNavigating = true);

      try {
        final shops = await ShopService().fetchApprovedShops();

        final found = shops.firstWhereOrNull(
          (s) => s['id'].toString() == shopId.toString(),
        );

        if (found != null) {
          await Get.to(() => ApprovedShopDetailScreen(shop: found));
        } else {
          Get.snackbar("Not found", "This shop could not be loaded.");
        }
      } finally {
        if (mounted) {
          setState(() => isNavigating = false);
        }
      }
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
        return Icons.payments_rounded;

      case 'payment_release':
      case 'payout_paid':
        return Icons.account_balance_wallet_rounded;

      case 'shop_status':
      case 'shop_pending':
        return Icons.storefront_rounded;

      case 'chat_message':
        return Icons.chat_bubble_rounded;

      case 'complaint':
        return Icons.report_problem_rounded;

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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cream.withOpacity(0.35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 42,
                        color: AppColors.iconMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text("No notifications yet", style: AppTextStyles.heading4),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifications[index];
                    final isRead = n['is_read'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: AppDecorations.card.copyWith(
                        color: isRead
                            ? AppColors.cream.withOpacity(0.16)
                            : AppColors.cream.withOpacity(0.32),
                        border: Border.all(
                          color: isRead
                              ? AppColors.borderGold.withOpacity(0.25)
                              : AppColors.borderGold.withOpacity(0.6),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _onTapNotification(n),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isRead
                                        ? AppColors.darkGreen.withOpacity(0.08)
                                        : AppColors.golden.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(12),
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
                                                        ? FontWeight.w500
                                                        : FontWeight.w700,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                                                color: AppColors.golden,
                                                shape: BoxShape.circle,
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
                                        style: AppTextStyles.bodySmall.copyWith(
                                          fontSize: 10.5,
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
    );
  }
}
