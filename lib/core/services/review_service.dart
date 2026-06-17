import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ReviewService {
  final box = GetStorage();

  final String baseUrl = "http://127.0.0.1:8000/api";

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
}
