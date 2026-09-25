import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../constants/app_icons.dart';

class CategoryService {
  final String baseUrl = BaseUrl.url;

  // =========================
  // FETCH ALL CATEGORIES (admin — active + inactive)
  // =========================
  Future<List<Map<String, dynamic>>> fetchAllCategories() async {
    final response = await http.get(
      Uri.parse("$baseUrl/all-rice-categories"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }

  // =========================
  // CREATE CATEGORY
  // =========================
  Future<Map<String, dynamic>> createCategory({
    required String token,
    required String name,
    Uint8List? imageBytes,
    String imageName = 'category.jpg',
  }) async {
    final uri = Uri.parse("$baseUrl/rice-categories");
    final request = http.MultipartRequest("POST", uri);

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    request.fields['name'] = name;

    if (imageBytes != null) {
      final ext = imageName.split('.').last.toLowerCase();

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName,
          contentType: MediaType('image', ext == 'jpg' ? 'jpeg' : ext),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {"message": "Something went wrong"};
    }
  }

  // =========================
  // UPDATE CATEGORY (name and/or image)
  // =========================
  Future<Map<String, dynamic>> updateCategory({
    required String token,
    required int categoryId,
    String? name,
    Uint8List? imageBytes,
    String imageName = 'category.jpg',
  }) async {
    final uri = Uri.parse("$baseUrl/rice-categories/$categoryId");
    final request = http.MultipartRequest("POST", uri);

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    request.fields['_method'] = 'PUT';

    if (name != null) {
      request.fields['name'] = name;
    }

    if (imageBytes != null) {
      final ext = imageName.split('.').last.toLowerCase();

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageName,
          contentType: MediaType('image', ext == 'jpg' ? 'jpeg' : ext),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {"message": "Something went wrong"};
    }
  }

  // =========================
  // TOGGLE STATUS
  // =========================
  Future<Map<String, dynamic>> updateStatus({
    required String token,
    required int categoryId,
    required bool status,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/rice-categories/$categoryId/status"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"status": status}),
    );

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {"message": "Something went wrong"};
    }
  }
}
