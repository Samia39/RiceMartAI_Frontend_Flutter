import 'dart:convert';
import 'package:frontend/core/constants/app_icons.dart';
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

      final response = await request.send();
      final body = await response.stream.bytesToString();
      return jsonDecode(body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
