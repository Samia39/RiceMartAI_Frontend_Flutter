import 'package:flutter/material.dart';
import 'notification_screen.dart';

/// Har dashboard k AppBar mein ye widget use karein.
/// Usage: NotificationBellIcon(unreadCount: _unreadCount, iconColor: AppColors.darkGreen)
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_outlined, color: iconColor, size: 22),
            if (unreadCount > 0)
              Positioned(
                right: -4,
                top: -4,
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
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}