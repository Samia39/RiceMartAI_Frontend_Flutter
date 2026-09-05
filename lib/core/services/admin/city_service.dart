import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ricemart_ai/core/constants/app_icons.dart';

class CityService {
  final box = GetStorage();

  final String baseUrl = BaseUrl.url;

  // =========================
  // GET ALL CITIES
  // =========================
  Future<List> getCities() async {
    try {
      final token = box.read("token");

      final response = await http.get(
        Uri.parse("$baseUrl/admin/cities"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        return data["data"];
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // =========================
  // GET AVAILABLE CITIES
  // =========================
  Future<List> getAvailableCities() async {
    try {
      final token = box.read("token");

      final response = await http.get(
        Uri.parse("$baseUrl/admin/available-cities"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        return data["data"];
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  // =========================
  // ADD CITY
  // =========================
  Future<Map<String, dynamic>> addCity({
    required String name,
    String? code,
  }) async {
    try {
      final token = box.read("token");

      final response = await http.post(
        Uri.parse("$baseUrl/admin/cities"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"name": name, "code": code ?? ""}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // =========================
  // UPDATE CITY
  // =========================
  Future<Map<String, dynamic>> updateCity({
    required int cityId,
    required String name,
    String? code,
  }) async {
    try {
      final token = box.read("token");

      final response = await http.put(
        Uri.parse("$baseUrl/admin/cities/$cityId"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"name": name, "code": code ?? ""}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // =========================
  // DELETE CITY
  // =========================
  Future<Map<String, dynamic>> deleteCity(int cityId) async {
    try {
      final token = box.read("token");

      final response = await http.delete(
        Uri.parse("$baseUrl/admin/cities/$cityId"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // =========================
  // GET CITIES WITH DELIVERY CHARGES (public, for checkout)
  // =========================
  Future<List> getCitiesWithCharges() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/cities-with-charges"),
        headers: {"Accept": "application/json"},
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        return data["data"];
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}
