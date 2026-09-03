import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/rice_detection_result.dart';

class RiceDetectionService {
  // ⚠️ Apna Laravel backend ka URL yahan lagayein
  // Android Emulator: http://10.0.2.2:8000/api
  // Real phone (same WiFi): http://192.168.x.x:8000/api (apne PC ka IP)
  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<RiceDetectionResult> detectRice(File imageFile) async {
    final uri = Uri.parse("$baseUrl/rice/detect");
    final request = http.MultipartRequest("POST", uri);

    request.files.add(
      await http.MultipartFile.fromPath("image", imageFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return RiceDetectionResult.fromJson(data['data']);
    } else {
      throw Exception("Server error (${response.statusCode}): ${response.body}");
    }
  }
}