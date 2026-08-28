import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class CourierChargeService {
  final box = GetStorage();

  final String baseUrl = "http://ricemart.sandbox.pk/api";

  // =========================
  // GET ALL COURIER CHARGES
  // =========================
  Future<List> getCourierCharges() async {
    try {
      final token = box.read("token");

      final response = await http.get(
        Uri.parse("$baseUrl/admin/courier-charges"),
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
  // ADD COURIER CHARGE
  // =========================
  Future<Map<String, dynamic>> addCourierCharge({
    required int cityId,
    required String charge,
  }) async {
    try {
      final token = box.read("token");

      final response = await http.post(
        Uri.parse("$baseUrl/admin/courier-charges"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"city_id": cityId, "charge": charge}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // =========================
  // UPDATE COURIER CHARGE
  // =========================
  Future<Map<String, dynamic>> updateCourierCharge({
    required int chargeId,
    required int cityId,
    required String charge,
  }) async {
    try {
      final token = box.read("token");

      final response = await http.put(
        Uri.parse("$baseUrl/admin/courier-charges/$chargeId"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"city_id": cityId, "charge": charge}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // =========================
  // DELETE COURIER CHARGE
  // =========================
  Future<Map<String, dynamic>> deleteCourierCharge(int chargeId) async {
    try {
      final token = box.read("token");

      final response = await http.delete(
        Uri.parse("$baseUrl/admin/courier-charges/$chargeId"),
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
}
