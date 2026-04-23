import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShopService {
  static const String _baseUrl = 'localhost:8000/api';

  static Map<String, String> get _authHeaders {
    final token = GetStorage().read('token') ?? '';
    return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }

  // ─────────────────────────────────────────────────────────
  //  CREATE SHOP
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> createShop({
    required String cnicNumber,
    cnicImage,
    required String shopName,
    required String ownerName,
    required String phone,
    required String address,
    required String description,
    required List<Map<String, dynamic>> riceCategories,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/shops'),
      );

      request.headers.addAll(_authHeaders);
      request.fields['cnic_number'] = cnicNumber;
      request.fields['shop_name'] = shopName;
      request.fields['owner_name'] = ownerName;
      request.fields['phone'] = phone;
      request.fields['address'] = address;
      request.fields['description'] = description;
      request.fields['rice_categories'] = jsonEncode(riceCategories);

      request.files.add(
        await http.MultipartFile.fromPath(
          'cnic_image',
          cnicImage.path,
          filename: 'cnic_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to create shop',
      };
    } on SocketException {
      return {'success': false, 'message': 'No internet connection'};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────
  //  GET MY SHOP
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getMyShop() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/shops/my-shop'), headers: _authHeaders)
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return {'success': true, 'data': data};
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to fetch shop',
      };
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────
  //  UPDATE SHOP
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> updateShop({
    required String shopId,
    required String shopName,
    required String ownerName,
    required String phone,
    required String address,
    required String description,
    required List<Map<String, dynamic>> riceCategories,
    File? cnicImage,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST', // POST + _method=PUT for Laravel
        Uri.parse('$_baseUrl/shops/$shopId'),
      );

      request.headers.addAll(_authHeaders);
      request.fields['_method'] = 'PUT'; // Laravel method spoofing
      request.fields['shop_name'] = shopName;
      request.fields['owner_name'] = ownerName;
      request.fields['phone'] = phone;
      request.fields['address'] = address;
      request.fields['description'] = description;
      request.fields['rice_categories'] = jsonEncode(riceCategories);

      if (cnicImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'cnic_image',
            cnicImage.path,
            filename: 'cnic_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
      }

      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) return {'success': true, 'data': data};
      return {'success': false, 'message': data['message'] ?? 'Update failed'};
    } on SocketException {
      return {'success': false, 'message': 'No internet connection'};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────
  //  DELETE SHOP
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> deleteShop(String shopId) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/shops/$shopId'), headers: _authHeaders)
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': data['message'] ?? 'Delete failed'};
    } on SocketException {
      return {'success': false, 'message': 'No internet connection'};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }
}
