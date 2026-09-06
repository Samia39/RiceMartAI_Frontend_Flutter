import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../../models/app_notification_model.dart';

// NOTE: 'notifications.{userId}' ab ek PUBLIC channel hai (PrivateChannel nahi),
// isliye subscribe karte waqt 'private-' prefix ki zaroorat nahi.

class NotificationService {
  // ⚠️ Chrome/Web testing k liye 127.0.0.1 theek hai.
  // Real phone pe test karte waqt apne PC ka IP (jaise 192.168.1.11) use karein.
  static const String baseUrl = "http://127.0.0.1:8000/api";
  static const String reverbHost = "127.0.0.1";
  static const int reverbPort = 8080;
  static const String reverbKey = "pgfhbcq6axprlwvndujo"; // .env REVERB_APP_KEY

  static PusherChannelsFlutter? _pusher;

  /// Naye notifications get karein (list + unread count)
  static Future<Map<String, dynamic>> fetchNotifications(String token) async {
    final uri = Uri.parse("$baseUrl/notifications");
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data']['data'] ?? [];
      return {
        'unread_count': data['unread_count'] ?? 0,
        'notifications':
            list.map((e) => AppNotificationModel.fromJson(e)).toList(),
      };
    } else {
      throw Exception("Failed to load notifications: ${response.body}");
    }
  }

  static Future<void> markAsRead(String token, int id) async {
    await http.put(
      Uri.parse("$baseUrl/notifications/$id/read"),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Reverb se connect karke real-time notifications sunna shuru karein.
  /// [userId] wahi user hai jo currently login hai.
  /// [onNotification] callback har baar chalega jab nayi notification aayegi.
  static Future<void> connectAndListen({
    required int userId,
    required Function(Map<String, dynamic>) onNotification,
  }) async {
    _pusher = PusherChannelsFlutter.getInstance();

    await _pusher!.init(
      apiKey: reverbKey,
      cluster: 'mt1', // Reverb k liye ye value use hoti hai, ignored effectively
      useTLS: false,
      host: reverbHost,
      wsPort: reverbPort,
      wssPort: reverbPort,
      onEvent: (event) {
        if (event.eventName == 'new-notification') {
          final data = jsonDecode(event.data);
          onNotification(data);
        }
      },
    );

    await _pusher!.connect();
    await _pusher!.subscribe(channelName: 'notifications.$userId');
  }

  static Future<void> disconnect() async {
    await _pusher?.disconnect();
  }
}