import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

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

  // =========================
  // GET USERS
  // =========================

  Future<List<dynamic>> getUsers() async {
    final response = await http.get(
      Uri.parse("$baseUrl/users"),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // =========================
  // GET ROLES
  // =========================

  Future<List<dynamic>> getRoles() async {
    final response = await http.get(
      Uri.parse("$baseUrl/roles"),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // for user mangenment module

  // =========================
  // CREATE USER
  // =========================

  Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users"),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    return jsonDecode(response.body);
  }

  // =========================
  // UPDATE USER
  // =========================

  Future<Map<String, dynamic>> updateUser({
    required int id,
    required String name,
    required String email,
    required String role,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/users/$id"),
      headers: {...headers, 'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'role': role}),
    );

    return jsonDecode(response.body);
  }

  // =========================
  // DELETE USER
  // =========================

  Future<Map<String, dynamic>> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/users/$id"),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // for user management module
  // =========================
  // GET ROLES
  // =========================

  Future<List<dynamic>> getRolesManagement() async {
    final response = await http.get(
      Uri.parse("$baseUrl/roles-management"),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // =========================
  // CREATE ROLE
  // =========================

  Future<Map<String, dynamic>> createRole(String name) async {
    final response = await http.post(
      Uri.parse("$baseUrl/roles-management"),
      headers: {...headers, "Content-Type": "application/json"},
      body: jsonEncode({"name": name}),
    );

    return jsonDecode(response.body);
  }

  // =========================
  // UPDATE ROLE
  // =========================

  Future<Map<String, dynamic>> updateRole(int id, String name) async {
    final response = await http.put(
      Uri.parse("$baseUrl/roles-management/$id"),
      headers: {...headers, "Content-Type": "application/json"},
      body: jsonEncode({"name": name}),
    );

    return jsonDecode(response.body);
  }

  // =========================
  // DELETE ROLE
  // =========================

  Future<Map<String, dynamic>> deleteRole(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/roles-management/$id"),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // =========================
  // GET PERMISSIONS
  // =========================
  Future<List<dynamic>> getPermissions() async {
    final response = await http.get(
      Uri.parse("$baseUrl/permissions"),
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  // =========================
  // GET ROLE PERMISSIONS
  // =========================

  Future<List<dynamic>> getRolePermissions(int roleId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/roles-management/$roleId/permissions"),
      headers: headers,
    );

    final data = jsonDecode(response.body);
    return data['permissions'];
  }

  // =========================
  // ASSIGN PERMISSIONS
  // =========================
  Future<Map<String, dynamic>> assignPermissions({
    required int roleId,
    required List<int> permissions,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/assign-permissions"),
      headers: {...headers, "Content-Type": "application/json"},
      body: jsonEncode({"role_id": roleId, "permissions": permissions}),
    );

    return jsonDecode(response.body);
  }
}
