import 'dart:typed_data';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../constants/app_icons.dart';
import 'package:http_parser/http_parser.dart';

class ProductService {
  final String baseUrl = BaseUrl.url;

  // =========================
  // FETCH ACTIVE CATEGORIES
  // =========================
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final response = await http.get(
      Uri.parse("$baseUrl/rice-categories"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }

  // =========================
  // ADD PRODUCT (with optional image bytes — web + mobile safe)
  // =========================
  Future<Map<String, dynamic>> addProduct({
    required String token,
    required int shopId,
    required int riceCategoryId,
    required String name,
    required String price,
    required String stock,
    required Uint8List imageBytes,
    String imageName = 'product.jpg',
  }) async {
    final uri = Uri.parse("$baseUrl/products");
    final request = http.MultipartRequest("POST", uri);

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    request.fields['shop_id'] = shopId.toString();
    request.fields['rice_category_id'] = riceCategoryId.toString();
    request.fields['name'] = name;
    request.fields['price'] = price;
    request.fields['stock'] = stock;

    final ext = imageName.split('.').last.toLowerCase();

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageName,
        contentType: MediaType('image', ext == 'jpg' ? 'jpeg' : ext),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {"message": "Something went wrong"};
    }
  }

  // =========================
  // FETCH SHOP PRODUCTS
  // =========================
  Future<List<Map<String, dynamic>>> fetchShopProducts({
    required int shopId,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/shop-products/$shopId"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }

  // =========================
  // FETCH ALL PRODUCTS
  // =========================
  Future<List<Map<String, dynamic>>> fetchAllProducts() async {
    final response = await http.get(
      Uri.parse("$baseUrl/all-products"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }

  // =========================
  // DELETE PRODUCT
  // =========================
  Future deleteProduct({required String token, required int productId}) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/products/$productId"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    return jsonDecode(response.body);
  }

  // =========================
  // UPDATE PRODUCT (with optional new image bytes)
  // =========================
  Future updateProduct({
    required String token,
    required int productId,
    required String price,
    required String stock,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    // ✅ Using POST + _method=PUT so multipart file upload works
    // (Laravel doesn't parse multipart bodies on native PUT requests)
    final uri = Uri.parse("$baseUrl/products/$productId");
    final request = http.MultipartRequest("POST", uri);

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    request.fields['_method'] = 'PUT';
    request.fields['price'] = price;
    request.fields['stock'] = stock;

    if (imageBytes != null) {
      final fileName = imageName ?? 'product.jpg';
      final ext = fileName.split('.').last.toLowerCase();

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: fileName,
          contentType: MediaType('image', ext == 'jpg' ? 'jpeg' : ext),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {"message": "Something went wrong"};
    }
  }

  // =========================
  // HELPER: Build full image URL from stored path
  // =========================
  static String? getImageUrl(Map<String, dynamic> product) {
    final raw = product["image"];
    if (raw == null || raw.toString().trim().isEmpty) return null;

    final str = raw.toString().trim();
    if (str.startsWith("http://") || str.startsWith("https://")) {
      return str;
    }

    // ✅ Strip trailing "/api" (or any trailing path) from baseUrl
    // so we get just the host, e.g. "http://127.0.0.1:8000"
    final host = BaseUrl.url.replaceAll(RegExp(r'/api/?$'), '');

    return "$host/storage/$str";
  }
}
