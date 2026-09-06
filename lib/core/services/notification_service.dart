import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../models/app_notification_model.dart';

class NotificationService {
  // ⚠️ Chrome/Web testing k liye 127.0.0.1 theek hai.
  // Real phone pe test karte waqt apne PC ka IP (jaise 192.168.1.11) use karein.
  static const String baseUrl = "http://127.0.0.1:8000/api";
  static const String reverbHost = "127.0.0.1";
  static const int reverbPort = 8080;
  static const String reverbKey = "pgfhbcq6axprlwvndujo"; // .env REVERB_APP_KEY

  static WebSocketChannel? _channel;
  static StreamSubscription? _subscription;

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

  /// Reverb se seedha WebSocket connect karke real-time notifications sunna.
  /// [userId] currently login user hai.
  /// [onNotification] callback har baar chalega jab nayi notification aayegi.
  static void connectAndListen({
    required int userId,
    required Function(Map<String, dynamic>) onNotification,
  }) {
    final wsUrl =
        'ws://$reverbHost:$reverbPort/app/$reverbKey?protocol=7&client=flutter&version=1.0';

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _subscription = _channel!.stream.listen((message) {
      final decoded = jsonDecode(message);
      final event = decoded['event'];

      // Connection establish hote hi channel subscribe karein
      if (event == 'pusher:connection_established') {
        final subscribeMsg = jsonEncode({
          'event': 'pusher:subscribe',
          'data': {'channel': 'notifications.$userId'},
        });
        _channel!.sink.add(subscribeMsg);
      }

      // Hamara custom event jo Laravel se broadcast hota hai
      if (event == 'new-notification') {
        final data = jsonDecode(decoded['data']);
        onNotification(data);
      }
    }, onError: (e) {
      // Connection error - silently ignore ya debug print karein
    });
  }

  static void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
  }
}