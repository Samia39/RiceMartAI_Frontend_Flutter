import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class ShopService {
  static const String _baseUrl = 'http://localhost:8000/api';

  static Map<String, String> get _authHeaders {
    final token = GetStorage().read('token') ?? '';
    return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  CREATE SHOP
  //  POST /api/shops  (multipart)
  //
  //  rice_categories  →  JSON string: [{name, price_per_kg, stock_kg}, ...]
  //  rice_image_0..N  →  one file field per category (if image chosen)
  // ─────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> createShop({
    required String cnicNumber,
    required Uint8List cnicImageBytes,
    required String shopName,
    required String ownerName,
    required String phone,
    required String address,
    required String description,
    // Each map: { 'name', 'price_per_kg', 'stock_kg', 'imageBytes': Uint8List? }
    required List<Map<String, dynamic>> riceCategories,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/shops'),
      );
      request.headers.addAll(_authHeaders);

      // CNIC image
      request.files.add(
        http.MultipartFile.fromBytes(
          'cnic_image',
          cnicImageBytes,
          filename: 'cnic_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      // Scalar fields
      request.fields['cnic_number'] = cnicNumber;
      request.fields['shop_name'] = shopName;
      request.fields['owner_name'] = ownerName;
      request.fields['phone'] = phone;
      request.fields['address'] = address;
      request.fields['description'] = description;

      // Build JSON list (without imageBytes — that goes as a file)
      final categoriesJson = riceCategories
          .map(
            (cat) => {
              'name': cat['name'],
              'price_per_kg': cat['price_per_kg'],
              'stock_kg': cat['stock_kg'] ?? 0,
            },
          )
          .toList();
      request.fields['rice_categories'] = jsonEncode(categoriesJson);

      // One file per category  →  rice_image_0, rice_image_1, ...
      for (int i = 0; i < riceCategories.length; i++) {
        final bytes = riceCategories[i]['imageBytes'] as Uint8List?;
        if (bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'rice_image_$i',
              bytes,
              filename:
                  'rice_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          );
        }
      }

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

  // ─────────────────────────────────────────────────────────────────────────
  //  GET MY SHOP
  //  GET /api/shops/my-shop
  // ─────────────────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────────────
  //  GET ALL SHOPS
  //  GET /api/shops | /api/shops/search?q=
  // ─────────────────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────────────
  //  UPDATE SHOP
  //  POST /api/shops/{id}  (with _method=PUT)
  //
  //  rice_categories →  JSON: [{name, price_per_kg, stock_kg,
  //                              existing_image?}]
  //                     existing_image = raw storage path (NOT full URL),
  //                     sent when the user did NOT pick a new image so the
  //                     backend can keep the old file.
  //  rice_image_N    →  new image bytes (only when user re-picked)
  //  cnicImageBytes  →  null = keep existing
  //  cnicNumber      →  null = keep existing
  // ─────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> updateShop({
    required String shopId,
    required String shopName,
    required String ownerName,
    required String phone,
    required String address,
    required String description,
    // Each map: { 'name', 'price_per_kg', 'stock_kg',
    //             'imageBytes': Uint8List?,   ← new pick
    //             'existingImage': String? }  ← raw storage path kept
    required List<Map<String, dynamic>> riceCategories,
    Uint8List? cnicImageBytes,
    String? cnicNumber,
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

      if (cnicNumber != null) {
        request.fields['cnic_number'] = cnicNumber;
      }

      if (cnicImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'cnic_image',
            cnicImageBytes,
            filename: 'cnic_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
      }

      // Build JSON list
      final categoriesJson = riceCategories.map((cat) {
        final map = <String, dynamic>{
          'name': cat['name'],
          'price_per_kg': cat['price_per_kg'],
          'stock_kg': cat['stock_kg'] ?? 0,
        };
        // Pass raw storage path so backend can retain old image
        if (cat['existingImage'] != null) {
          map['existing_image'] = cat['existingImage'];
        }
        return map;
      }).toList();
      request.fields['rice_categories'] = jsonEncode(categoriesJson);

      // Attach new images
      for (int i = 0; i < riceCategories.length; i++) {
        final bytes = riceCategories[i]['imageBytes'] as Uint8List?;
        if (bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'rice_image_$i',
              bytes,
              filename:
                  'rice_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          );
        }
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

  // ─────────────────────────────────────────────────────────────────────────
  //  DELETE SHOP
  //  DELETE /api/shops/{id}
  // ─────────────────────────────────────────────────────────────────────────
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
