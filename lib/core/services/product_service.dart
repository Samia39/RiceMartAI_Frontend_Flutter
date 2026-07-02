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
  // ADD PRODUCT
  // =========================
  Future<Map<String, dynamic>> addProduct({
    required String token,
    required int shopId,
    required int riceCategoryId,
    required String name,
    required String price,
    required String stock,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/products"),

      headers: {
        "Authorization": "Bearer $token",

        "Accept": "application/json",

        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "shop_id": shopId,

        "rice_category_id": riceCategoryId,

        "name": name,

        "price": price,

        "stock": stock,
      }),
    );

    return jsonDecode(response.body);
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
  // UPDATE PRODUCT
  // =========================
  Future updateProduct({
    required String token,
    required int productId,
    required String price,
    required String stock,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/products/$productId"),

      headers: {
        "Authorization": "Bearer $token",

        "Accept": "application/json",

        "Content-Type": "application/json",
      },

      body: jsonEncode({"price": price, "stock": stock}),
    );

    return jsonDecode(response.body);
  }
}
