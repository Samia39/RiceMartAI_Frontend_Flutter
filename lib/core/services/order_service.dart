import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class OrderService {
  final box = GetStorage();
  final String baseUrl = "http://127.0.0.1:8000/api";

  // =========================
  // CHECKOUT API CALL
  // =========================
  Future<Map<String, dynamic>> checkout({
    required String customerName,
    required String phone,
    required String address,
    required String paymentMethod,
    required List cart,
    // File? paymentProof,
    dynamic paymentProof, // Change to dynamic to avoid import issues
  }) async {
    try {
      final token = box.read("token");

      // =========================
      // MULTIPART REQUEST
      // =========================
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/checkout"),
      );

      // =========================
      // HEADERS
      // =========================
      request.headers['Authorization'] = 'Bearer $token';

      request.headers['Accept'] = 'application/json';

      // =========================
      // FIELDS
      // =========================
      request.fields['customer_name'] = customerName;

      request.fields['phone'] = phone;

      request.fields['address'] = address;

      request.fields['payment_method'] = paymentMethod;

      request.fields['city'] = '';

      // =========================
      // CART
      // =========================
      for (int i = 0; i < cart.length; i++) {
        request.fields['cart[$i][product_id]'] = cart[i]['product_id']
            .toString();
        request.fields['cart[$i][quantity]'] = cart[i]['quantity'].toString();
      }

      // =========================
      // PAYMENT SCREENSHOT
      // =========================
      if (!kIsWeb && paymentProof != null) {
        request.files.add(
          await http.MultipartFile.fromPath('payment_proof', paymentProof.path),
        );
      }

      // =========================
      // SEND REQUEST
      // =========================
      final response = await request.send();

      final responseData = await response.stream.bytesToString();

      final data = jsonDecode(responseData);

      return data;
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // =========================
  // GET MY ORDERS
  // =========================
  Future<List> getMyOrders() async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("$baseUrl/my-orders"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      return data["orders"];
    }

    return [];
  }

  // =========================
  // GET SELLER ORDERS
  // =========================
  Future<List> fetchSellerOrders() async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("$baseUrl/seller-orders"),

      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      return data["orders"];
    } else {
      return [];
    }
  }

  // =========================
  // UPDATE ITEM STATUS
  // =========================
  Future<Map<String, dynamic>> updateItemStatus({
    required int itemId,
    required String status,
  }) async {
    final token = box.read("token");

    final response = await http.put(
      Uri.parse("$baseUrl/seller/order-item/$itemId/status"),

      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },

      body: jsonEncode({"status": status}),
    );

    final data = jsonDecode(response.body);

    return data;
  }

  // order detail screen
  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("$baseUrl/my-orders"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      final orders = data["orders"];

      return orders.firstWhere((o) => o["id"] == orderId);
    }

    throw Exception("Order not found");
  }

  // Active Orders
  Future<List> getActiveOrders() async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("$baseUrl/active-orders"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      return data["orders"];
    }

    return [];
  }

  // Order History
  Future<List> getOrderHistory() async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("$baseUrl/order-history"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      return data["orders"];
    }

    return [];
  }

  // =========================
  // ADMIN ALL ORDERS
  // =========================
  Future<List> getAdminOrders() async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("$baseUrl/admin/orders"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      return data["orders"];
    }

    return [];
  }

  // =========================
  // ADMIN UPDATE ITEM STATUS
  // =========================
  Future<Map<String, dynamic>> adminUpdateItemStatus({
    required int itemId,
    required String status,
  }) async {
    final token = box.read("token");

    final response = await http.put(
      Uri.parse("$baseUrl/admin/order-item/$itemId/status"),

      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },

      body: jsonEncode({"status": status}),
    );

    return jsonDecode(response.body);
  }

  // =========================
  // ADMIN PAYMENTS
  // =========================
  Future<List> getAdminPayments() async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("$baseUrl/admin/payments"),

      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    final data = jsonDecode(response.body);

    if (data["success"] == true) {
      return data["payments"];
    }

    return [];
  }

  // =========================
  // UPDATE PAYMENT STATUS
  // =========================
  Future<Map<String, dynamic>> updatePaymentStatus({
    required int orderId,
    required String paymentStatus,
  }) async {
    final token = box.read("token");

    final response = await http.put(
      Uri.parse("$baseUrl/admin/orders/$orderId/payment-status"),

      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },

      body: jsonEncode({"payment_status": paymentStatus}),
    );

    return jsonDecode(response.body);
  }
}
