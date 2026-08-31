import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/services/notification_service.dart';
import '/routes/app_routes.dart';

/// Drop this anywhere (an AppBar's actions, a title Row, etc.).
/// It polls the unread count every 30s while mounted, shows a red badge,
/// and opens NotificationsScreen on tap (refreshing the badge on return).
class NotificationBell extends StatefulWidget {
  final Color iconColor;
  final double size;

  /// Optional override if you want custom navigation instead of the
  /// default named-route push to NotificationsScreen.
  final VoidCallback? onTap;

  const NotificationBell({
    super.key,
    this.iconColor = Colors.white,
    this.size = 26,
    this.onTap,
  });

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _service = NotificationService();
  int unreadCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();

    // Keeps the badge current while the screen is open, without needing
    // a websocket/push setup.
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadUnreadCount(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _service.fetchUnreadCount();
    if (mounted) setState(() => unreadCount = count);
  }

  Future<void> _handleTap() async {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    // Converted from Navigator.push(MaterialPageRoute(...)) to the named
    // route so AuthMiddleware actually runs for it.
    await Get.toNamed(AppRoutes.notifications);

    // Refresh badge in case items were read/marked-all on that screen.
    _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_rounded,
            color: widget.iconColor,
            size: widget.size,
          ),
          onPressed: _handleTap,
        ),
        if (unreadCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  unreadCount > 99 ? "99+" : "$unreadCount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
