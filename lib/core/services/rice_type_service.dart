import 'dart:convert';

import 'package:http/http.dart' as http;
import '../constants/app_icons.dart';

class RiceTypeService {
  static const String baseUrl = BaseUrl.url;

  Future<List<Map<String, dynamic>>> fetchRiceTypes() async {
    final response = await http.get(Uri.parse("$baseUrl/rice-types"));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }
}
