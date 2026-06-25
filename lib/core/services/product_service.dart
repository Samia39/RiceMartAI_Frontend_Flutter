import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../models/product_model.dart';

class ProductService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static final _box = GetStorage();
  static String? _getToken() => _box.read('token');

  // Seller ke products
  static Future<List<ProductModel>> getMyProducts() async {
    try {
      final token = _getToken();
      final res = await http.get(
        Uri.parse('$baseUrl/seller/products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['products'] as List)
            .map((e) => ProductModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('getMyProducts error: $e');
    }
    return [];
  }

  // Product add karo
  static Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    File? image,
  }) async {
    try {
      final token = _getToken();
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
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));
      }

      final streamedRes = await request.send();
      final res = await http.Response.fromStream(streamedRes);
      final data = jsonDecode(res.body);

      return {
        'success': res.statusCode == 201,
        'message': data['message'] ?? 'Kuch masla hua',
      };
    } catch (e) {
      print('addProduct error: $e');
      return {'success': false, 'message': 'Network error!'};
    }
  }

  // Product delete karo
  static Future<bool> deleteProduct(int id) async {
    try {
      final token = _getToken();
      final res = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}