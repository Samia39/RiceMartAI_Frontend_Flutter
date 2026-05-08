import 'dart:convert';
import 'package:http/http.dart' as http;

class RiceService {
  final String baseUrl = "http://127.0.0.1:8000/api";

  Future<Map<String, dynamic>> addRice({
    required String token,
    required int shopId,
    required String name,
    required String price,
    required String stock,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/rice-categories"),

      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "shop_id": shopId,
        "name": name,
        "price": price,
        "stock": stock,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<List<Map<String, dynamic>>> fetchShopRice({
    required String token,
    required int shopId,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/shop-rice/$shopId"),

      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }

  Future deleteRice({required String token, required int riceId}) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/rice-categories/$riceId"),

      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    return jsonDecode(response.body);
  }

  Future updateRice({
    required String token,
    required int riceId,
    required String price,
    required String stock,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/rice/$riceId"),

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
