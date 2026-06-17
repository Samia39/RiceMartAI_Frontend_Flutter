import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../models/shop_model.dart';

class ShopService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static final _box = GetStorage();

  // Token GetStorage se lo
  static String? _getToken() => _box.read('token');

  // Sab approved shops
  static Future<List<Shop>> getAllShops() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/shops'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['shops'] as List)
            .map((e) => Shop.fromJson(e))
            .toList();
      }
    } catch (e) {}
    return [];
  }

  // Single shop with products
  static Future<Shop?> getShop(int id) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/shops/$id'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return Shop.fromJson(data['shop']);
      }
    } catch (e) {}
    return null;
  }

  // Seller ki shop
  static Future<Shop?> getMyShop() async {
    try {
      final token = _getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/seller/shop'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return Shop.fromJson(data['shop']);
      }
    } catch (e) {}
    return null;
  }

  // Shop banao
  static Future<Map<String, dynamic>> createShop({
    required String name,
    required String ownerName,
    required String phone,
    required String address,
    required String description,
    required String cnicNumber,
  }) async {
    try {
      final token = _getToken();
      final res = await http.post(
        Uri.parse('$baseUrl/shops'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'owner_name': ownerName,
          'phone': phone,
          'address': address,
          'description': description,
          'cnic_number': cnicNumber,
        }),
      );

      final data = jsonDecode(res.body);
      return {
        'success': res.statusCode == 201,
        'message': data['message'] ?? 'Something went wrong',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error!',
      };
    }
  }

  // Shop update
  static Future<bool> updateShop({
    required int id,
    required String name,
    required String description,
    required String address,
  }) async {
    try {
      final token = _getToken();
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
    } catch (e) {
      return false;
    }
  }

  // Admin — sab shops
  static Future<List<Shop>> getAdminShops() async {
    try {
      final token = _getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/admin/shops'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['shops'] as List)
            .map((e) => Shop.fromJson(e))
            .toList();
      }
    } catch (e) {}
    return [];
  }

  // Admin approve/reject
  static Future<bool> updateStatus(int id, String status) async {
    try {
      final token = _getToken();
      final res = await http.put(
        Uri.parse('$baseUrl/admin/shops/$id/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}