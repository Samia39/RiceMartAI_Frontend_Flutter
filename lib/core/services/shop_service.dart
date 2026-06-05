import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/shop_model.dart';

class ShopService {
  static const String baseUrl = 'http://localhost/sheezabackend/public/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Sab approved shops
  static Future<List<Shop>> getAllShops() async {
    final res = await http.get(Uri.parse('$baseUrl/shops'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['shops'] as List)
          .map((e) => Shop.fromJson(e))
          .toList();
    }
    return [];
  }

  // Single shop with products
  static Future<Shop?> getShop(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/shops/$id'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return Shop.fromJson(data['shop']);
    }
    return null;
  }

  // Seller ki shop
  static Future<Shop?> getMyShop() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/seller/shop'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return Shop.fromJson(data['shop']);
    }
    return null;
  }

  // Shop banao
  static Future<bool> createShop({
    required String name,
    required String description,
    required String address,
  }) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/shops'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'address': address,
      }),
    );
    return res.statusCode == 201;
  }

  // Shop update karo
  static Future<bool> updateShop({
    required int id,
    required String name,
    required String description,
    required String address,
  }) async {
    final token = await _getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/shops/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'address': address,
      }),
    );
    return res.statusCode == 200;
  }

  // Admin — sab shops
  static Future<List<Shop>> getAdminShops() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/admin/shops'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['shops'] as List)
          .map((e) => Shop.fromJson(e))
          .toList();
    }
    return [];
  }

  // Admin approve/reject
  static Future<bool> updateStatus(int id, String status) async {
    final token = await _getToken();
    final res = await http.put(
      Uri.parse('$baseUrl/admin/shops/$id/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': status}),
    );
    return res.statusCode == 200;
  }
}