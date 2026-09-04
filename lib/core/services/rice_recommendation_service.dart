import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/rice_recommendation.dart';

class RiceRecommendationService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  static Future<List<RiceRecommendation>> getRecommendation(String useCase) async {
    final uri = Uri.parse("$baseUrl/rice/recommend?use_case=$useCase");

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((e) => RiceRecommendation.fromJson(e)).toList();
    } else {
      throw Exception("Server error (${response.statusCode}): ${response.body}");
    }
  }
}