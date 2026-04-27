import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class ShopService {
  // For Android emulator use 10.0.2.2 — for real device use your PC LAN IP
  static const String _baseUrl = 'http://localhost:8000/api';

  static Map<String, String> get _authHeaders {
    final token = GetStorage().read('token') ?? '';
    return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }

  // ─────────────────────────────────────────────────────────
  //  CREATE SHOP
  //  POST /api/shops
  //  Laravel returns: { success, message, data: shop }
  //  Flutter reads:   result['success'], result['data']
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> createShop({
    required String cnicNumber,
    required Uint8List cnicImageBytes,
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

      request.files.add(
        http.MultipartFile.fromBytes(
          'cnic_image',
          cnicImageBytes,
          filename: 'cnic_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      request.fields['cnic_number'] = cnicNumber;
      request.fields['shop_name'] = shopName;
      request.fields['owner_name'] = ownerName;
      request.fields['phone'] = phone;
      request.fields['address'] = address;
      request.fields['description'] = description;
      request.fields['rice_categories'] = jsonEncode(riceCategories);

      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': body['data']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to create shop',
        'errors': body['errors'] ?? {},
      };
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────
  //  GET MY SHOP
  //  GET /api/shops/my-shop
  //  Laravel returns: { success, data: { id, shop_name, owner_name,
  //                     phone, address, description, cnic_number,
  //                     cnic_image (full URL), is_approved,
  //                     rice_categories: [{id, name, price_per_kg}] } }
  //  Flutter reads:   result['success'], result['shop']
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getMyShop() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/shops/my-shop'), headers: _authHeaders)
          .timeout(const Duration(seconds: 30));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'shop': body['data']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to fetch shop',
      };
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────
  //  GET ALL SHOPS
  //  GET /api/shops           → ShopController@index  (paginated)
  //  GET /api/shops/search?q= → ShopController@search (paginated)
  //
  //  Laravel returns:
  //    { success: true, data: { current_page, data: [ ...shops ], ... } }
  //                                            ^^^^^ shop array is HERE
  //
  //  Flutter reads:   result['success'], result['shops']  (List)
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getAllShops({String? query}) async {
    try {
      final uri = (query != null && query.isNotEmpty)
          ? Uri.parse('$_baseUrl/shops/search?q=${Uri.encodeComponent(query)}')
          : Uri.parse('$_baseUrl/shops');

      final response = await http
          .get(uri, headers: _authHeaders)
          .timeout(const Duration(seconds: 30));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // body['data']         = Laravel LengthAwarePaginator object
        // body['data']['data'] = the actual shop array
        final paginator = body['data'] as Map<String, dynamic>;
        final shops = (paginator['data'] as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        return {'success': true, 'shops': shops};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Failed to fetch shops',
      };
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────
  //  UPDATE SHOP
  //  POST /api/shops/{id}  with _method=PUT
  //  Laravel returns: { success, message, data: shop }
  //  Flutter reads:   result['success']
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> updateShop({
    required String shopId,
    required String shopName,
    required String ownerName,
    required String phone,
    required String address,
    required String description,
    required List<Map<String, dynamic>> riceCategories,
    Uint8List? cnicImageBytes, // null = keep existing image unchanged
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/shops/$shopId'),
      );
      request.headers.addAll(_authHeaders);
      request.fields['_method'] = 'PUT';
      request.fields['shop_name'] = shopName;
      request.fields['owner_name'] = ownerName;
      request.fields['phone'] = phone;
      request.fields['address'] = address;
      request.fields['description'] = description;
      request.fields['rice_categories'] = jsonEncode(riceCategories);

      if (cnicImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'cnic_image',
            cnicImageBytes,
            filename: 'cnic_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
      }

      final streamed = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'data': body['data']};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Update failed',
        'errors': body['errors'] ?? {},
      };
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────
  //  DELETE SHOP
  //  DELETE /api/shops/{id}
  //  Laravel returns: { success, message }
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> deleteShop(String shopId) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/shops/$shopId'), headers: _authHeaders)
          .timeout(const Duration(seconds: 30));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'message': body['message'] ?? 'Delete failed'};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }
}
