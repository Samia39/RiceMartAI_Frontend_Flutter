import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/app_icons.dart';

class NotificationService {
  final box = GetStorage();
  final String baseUrl = BaseUrl.url;

  Map<String, String> get _headers => {
    "Authorization": "Bearer ${box.read("token")}",
    "Accept": "application/json",
  };

  // =========================
  // FETCH NOTIFICATIONS (paginated list -> we just take the "data" page)
  // =========================
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/notifications"),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        return List<Map<String, dynamic>>.from(data["notifications"]["data"]);
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // =========================
  // UNREAD COUNT (for the bell badge)
  // =========================
  Future<int> fetchUnreadCount() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/notifications/unread-count"),
        headers: _headers,
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        return data["unread_count"] ?? 0;
      }

      return 0;
    } catch (e) {
      return 0;
    }
  }

  // =========================
  // MARK ONE AS READ
  // =========================
  Future<bool> markAsRead(int id) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/notifications/$id/read"),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      return data["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // =========================
  // MARK ALL AS READ
  // =========================
  Future<bool> markAllAsRead() async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/notifications/mark-all-read"),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      return data["success"] == true;
    } catch (e) {
      return false;
    }
  }
}
