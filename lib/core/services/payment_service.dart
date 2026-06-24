import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  final box = GetStorage();

  final String baseUrl = "http://ricemart.sandbox.pk/api";

  // =========================
  // GET ADMIN PAYMENTS
  // =========================
  Future<List> getAdminPayments() async {
    try {
      final token = box.read("token");

      final response = await http.get(
        Uri.parse("$baseUrl/admin/payments"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        return data["payments"];
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // =========================
  // UPDATE PAYMENT STATUS
  // =========================
  Future<Map<String, dynamic>> updatePaymentStatus({
    required int paymentId,
    required String paymentStatus,
    String? rejectionReason,
  }) async {
    try {
      final token = box.read("token");

      final response = await http.put(
        Uri.parse("$baseUrl/admin/payments/$paymentId/status"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "payment_status": paymentStatus,
          if (rejectionReason != null) "rejection_reason": rejectionReason,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
