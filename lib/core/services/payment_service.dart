import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/app_icons.dart';

class PaymentService {
  final box = GetStorage();
  final String baseUrl = BaseUrl.url;

  // =========================
  // GET PAYMENT SETTINGS (EasyPaisa / JazzCash numbers)
  // Used on the checkout screen so the admin can update these
  // numbers from the backend without an app update.
  // =========================
  Future<Map<String, dynamic>?> getPaymentSettings() async {
    try {
      final token = box.read("token");

      final response = await http.get(
        Uri.parse("$baseUrl/payment-settings"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        return data["settings"];
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // =========================
  // ADMIN UPDATE PAYMENT SETTINGS
  // =========================
  Future<Map<String, dynamic>> adminUpdatePaymentSettings({
    required String easypaisaNumber,
    String? easypaisaAccountName,
    required String jazzcashNumber,
    String? jazzcashAccountName,
  }) async {
    try {
      final token = box.read("token");

      final response = await http.post(
        Uri.parse("$baseUrl/admin/payment-settings"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "easypaisa_number": easypaisaNumber,
          "easypaisa_account_name": easypaisaAccountName,
          "jazzcash_number": jazzcashNumber,
          "jazzcash_account_name": jazzcashAccountName,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

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

  // =========================
  // CREATE STRIPE PAYMENT INTENT
  // Called from the checkout screen when the user picks "Card".
  // Returns the clientSecret needed to open Stripe's payment sheet.
  // =========================
  Future<Map<String, dynamic>> createStripePaymentIntent({
    required int orderId,
  }) async {
    try {
      final token = box.read("token");

      final response = await http.post(
        Uri.parse("$baseUrl/stripe/create-intent"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"order_id": orderId}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
