import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AdminService {
  final String baseUrl = "http://127.0.0.1:8000/api";

  final box = GetStorage();

  // =========================
  // TOKEN HEADER
  // =========================

  Map<String, String> get headers => {
    "Accept": "application/json",
    "Authorization": "Bearer ${box.read('token')}",
  };

  // =========================
  // CREATE SELLER + SHOP
  // =========================

  Future<Map<String, dynamic>> createSeller({
    required String name,
    required String email,
    required String password,
    required String shopName,
    required String ownerName,
    required String phone,
    required String address,
    required String cnic,
    required String description,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/admin/create-seller"),
    );

    // =========================
    // HEADERS
    // =========================

    request.headers.addAll(headers);

    // =========================
    // TEXT FIELDS
    // =========================

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;

    request.fields['shop_name'] = shopName;
    request.fields['owner_name'] = ownerName;
    request.fields['phone'] = phone;
    request.fields['address'] = address;
    request.fields['cnic'] = cnic;
    request.fields['description'] = description;

    // =========================
    // IMAGE   (CNIC Image )
    // =========================

    // =========================
    // SEND REQUEST
    // =========================

    var response = await request.send();

    var responseData = await response.stream.bytesToString();

    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: $responseData");

    return jsonDecode(responseData);
  }

  // =========================
  // PENDING SHOPS
  // =========================

  Future<List<dynamic>> getPendingShops() async {
    final response = await http.get(
      Uri.parse("$baseUrl/pending-shops"),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // =========================
  // APPROVED SHOPS
  // =========================

  Future<List<dynamic>> getApprovedShops() async {
    final response = await http.get(
      Uri.parse("$baseUrl/approved-shops"),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // =========================
  // APPROVE SHOP
  // =========================

  Future<Map<String, dynamic>> approveShop(int shopId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/shops/$shopId/approve"),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // =========================
  // REJECT SHOP
  // =========================

  Future<Map<String, dynamic>> rejectShop(int shopId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/shops/$shopId"),
      headers: headers,
    );

    return jsonDecode(response.body);
  }
}
