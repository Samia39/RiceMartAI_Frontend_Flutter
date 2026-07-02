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
}
