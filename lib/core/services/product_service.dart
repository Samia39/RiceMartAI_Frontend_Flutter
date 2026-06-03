import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/product_model.dart';

class ProductService {
  static const String baseUrl = 'http://10.0.2.2/sheezabackend/public/api';

  // Token get karo
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Seller ke products
  static Future<List<Product>> getMyProducts() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/seller/products'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList();
    }
    return [];
  }

  // Sab approved products
  static Future<List<Product>> getAllProducts() async {
    final res = await http.get(Uri.parse('$baseUrl/products'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList();
    }
    return [];
  }

  // Product add karo
  static Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    File? image,
  }) async {
    final token = await _getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/products'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['stock'] = stock.toString();
    request.fields['category'] = category;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final res = await request.send();
    return res.statusCode == 201;
  }

  // Product update karo
  static Future<bool> updateProduct({
    required int id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    File? image,
  }) async {
    final token = await _getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/products/$id?_method=PUT'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['stock'] = stock.toString();
    request.fields['category'] = category;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final res = await request.send();
    return res.statusCode == 200;
  }

  // Product delete karo
  static Future<bool> deleteProduct(int id) async {
    final token = await _getToken();
    final res = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.statusCode == 200;
  }

  // Admin — sab products
  static Future<List<Product>> getAdminProducts() async {
    final token = await _getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/admin/products'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['products'] as List)
          .map((e) => Product.fromJson(e))
          .toList();
    }
    return [];
  }

  // Admin — approve/reject
  static Future<bool> updateStatus(int id, String status) async {
    final token = await _getToken();
    final res = await http.put(
      Uri.parse('$baseUrl/admin/products/$id/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': status}),
    );
    return res.statusCode == 200;
  }
}