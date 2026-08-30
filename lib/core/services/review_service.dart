import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../constants/app_icons.dart';

class ReviewService {
  final box = GetStorage();

  static const String baseUrl = BaseUrl.url;

  Future<bool> submitReview({
    required int orderItemId,
    required int rating,
    String? review,
  }) async {
    final token = box.read("token");

    final response = await http.post(
      Uri.parse("$baseUrl/shop-review"),

      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},

      body: {
        "order_item_id": orderItemId.toString(),

        "rating": rating.toString(),

        "review": review ?? "",
      },
    );

    if (response.statusCode == 201) {
      return true;
    }

    print(response.body);

    return false;
  }

  // =========================
  // GET SHOP REVIEWS (seller: own shop, admin: any shop)
  // =========================
  Future<Map<String, dynamic>> getShopReviews(int shopId) async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("$baseUrl/shops/$shopId/reviews"),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    return {
      "success": false,
      "reviews": [],
      "average_rating": 0,
      "total_reviews": 0,
    };
  }
}
