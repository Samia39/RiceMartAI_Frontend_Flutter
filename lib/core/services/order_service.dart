import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'cart_service.dart';

class OrderService {
  final box = GetStorage();
  final String baseUrl = "http://127.0.0.1:8000/api";

  // =========================
  // CHECKOUT API CALL
  // =========================
  Future<Map<String, dynamic>> checkout() async {
    final token = box.read("token");

    // GET CART
    final cart = CartService().getCart();

    if (cart.isEmpty) {
      return {"success": false, "message": "Cart is empty"};
    }

    // FORMAT CART FOR BACKEND
    final formattedCart = cart.map((item) {
      return {"id": item["id"], "quantity": item["quantity"]};
    }).toList();

    // API REQUEST
    final response = await http.post(
      Uri.parse("$baseUrl/checkout"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"cart": formattedCart}),
    );

    final data = jsonDecode(response.body);

    return data;
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
}
