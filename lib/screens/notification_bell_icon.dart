import 'package:flutter/material.dart';

/// Sirf visual widget hai (icon + red badge count).
/// Navigation/onTap parent widget (jo isay use kare) khud handle karega.
/// Usage: GestureDetector(onTap: ..., child: NotificationBellIcon(unreadCount: 3, iconColor: Colors.black))
class NotificationBellIcon extends StatelessWidget {
  final int unreadCount;
  final Color iconColor;

  const NotificationBellIcon({
    super.key,
    required this.unreadCount,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_outlined, color: iconColor, size: 20),
          if (unreadCount > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}