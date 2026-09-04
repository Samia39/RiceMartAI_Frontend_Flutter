import 'dart:convert';
import 'package:ricemart_ai/core/constants/app_icons.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class PayoutService {
  final box = GetStorage();
  final String baseUrl = BaseUrl.url;

  Future<List> getPayouts() async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("$baseUrl/admin/payouts"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final data = jsonDecode(response.body);
    if (data["success"] == true) return data["payouts"];
    return [];
  }

  Future<Map<String, dynamic>> payPayout({
    required int payoutId,
    required String payoutMethod,
    required String transactionId,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    try {
      final token = box.read("token");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/admin/payouts/$payoutId/pay"),
      );

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields['payout_method'] = payoutMethod;
      request.fields['transaction_id'] = transactionId;

      request.files.add(
        http.MultipartFile.fromBytes('proof', imageBytes, filename: fileName),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw Exception(
            "Request timed out. Check your connection and try again.",
          );
        },
      );

      final body = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode >= 500) {
        return {
          "success": false,
          "message":
              "Server error (${streamedResponse.statusCode}). Please try again.",
        };
      }

      return jsonDecode(body);
    } catch (e) {
      return {
        "success": false,
        "message": e is Exception
            ? e.toString().replaceFirst("Exception: ", "")
            : "Something went wrong. Please try again.",
      };
    }
  }

  // Seller see their payouts

  Future<List> getSellerPayouts() async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("$baseUrl/seller/payouts"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final data = jsonDecode(response.body);
    if (data["success"] == true) return data["payouts"];
    return [];
  }
}
