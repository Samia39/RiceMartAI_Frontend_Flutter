import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ShopService {
  final String baseUrl = "http://ricemart.sandbox.pk/api";

  // create shop
  Future<Map<String, dynamic>> createShop({
    required String token,
    required String cnic,
    required String shopName,
    required String ownerName,
    required String phone,
    required String address,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/shops"),

      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "cnic": cnic,
        "shop_name": shopName,
        "owner_name": ownerName,
        "phone": phone,
        "address": address,
        "description": description,
        "status": "pending",
        "is_approved": 0,
      }),
    );

    return jsonDecode(response.body);
  }

  // fetch pending shops for admin
  Future<List<Map<String, dynamic>>> fetchPendingShops({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/pending-shops"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }

  // approve shop
  Future approveShop({required String token, required int shopId}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/shops/$shopId/approve"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    print(response.statusCode);
    print(response.body);

    return jsonDecode(response.body);
  }

  // fetch approved shops for customers
  Future<List<Map<String, dynamic>>> fetchApprovedShops() async {
    String token = GetStorage().read("token") ?? "";

    final response = await http.get(
      Uri.parse("$baseUrl/approved-shops"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }

  Future rejectShop({required String token, required int shopId}) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/shops/$shopId"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    return jsonDecode(response.body);
  }

  // =========================
  // UPDATE SHOP
  // =========================
  Future<Map<String, dynamic>> updateShop({
    required String token,
    required int shopId,
    required String shopName,
    required String ownerName,
    required String phone,
    required String address,
    required String description,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/shops/$shopId"),

      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "shop_name": shopName,
        "owner_name": ownerName,
        "phone": phone,
        "address": address,
        "description": description,
      }),
    );

    print(response.statusCode);
    print(response.body);

    return jsonDecode(response.body);
  }

  // =========================
  // DELETE SHOP
  // =========================
  Future<Map<String, dynamic>> deleteShop({
    required String token,
    required int shopId,
  }) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/shops/$shopId/delete"),

      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    print(response.statusCode);
    print(response.body);

    return jsonDecode(response.body);
  }

  // get my shop details
  Future<Map<String, dynamic>> getMyShop(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/my-shop"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "shop": data["shop"]};
      } else {
        return {"success": false, "message": data["message"]};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
