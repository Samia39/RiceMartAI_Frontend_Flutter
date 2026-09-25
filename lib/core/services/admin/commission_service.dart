import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../constants/app_icons.dart';

class CommissionService {
  final box = GetStorage();
  final String baseUrl = BaseUrl.url;

  Future<double?> getCurrentCommission() async {
    final token = box.read("token");
    final response = await http.get(
      Uri.parse("$baseUrl/admin/commission"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
    final data = jsonDecode(response.body);
    if (data["success"] == true) {
      return double.tryParse(data["current_percentage"].toString());
    }
    return null;
  }

  Future<List> getCommissionHistory() async {
    final token = box.read("token");
    final response = await http.get(
      Uri.parse("$baseUrl/admin/commission/history"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
    final data = jsonDecode(response.body);
    return data["success"] == true ? data["history"] : [];
  }

  Future<Map<String, dynamic>> updateCommission(double percentage) async {
    final token = box.read("token");
    final response = await http.post(
      Uri.parse("$baseUrl/admin/commission"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"percentage": percentage}),
    );
    return jsonDecode(response.body);
  }
}
