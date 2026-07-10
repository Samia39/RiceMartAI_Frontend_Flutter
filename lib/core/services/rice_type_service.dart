import 'dart:convert';

import 'package:http/http.dart' as http;

class RiceTypeService {
  final String baseUrl = "http://127.0.0.1:8000/api";

  Future<List<Map<String, dynamic>>> fetchRiceTypes() async {
    final response = await http.get(Uri.parse("$baseUrl/rice-types"));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }
}
