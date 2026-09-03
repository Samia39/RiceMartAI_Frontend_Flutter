import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../models/rice_detection_result.dart';

class RiceDetectionService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  static Future<RiceDetectionResult> detectRice(
      Uint8List imageBytes, String fileName) async {
    final uri = Uri.parse("$baseUrl/rice/detect");
    final request = http.MultipartRequest("POST", uri);
    request.headers['Accept'] = 'application/json';

    // Determine mime type from file extension (web bytes often lose this info)
    final ext = fileName.split('.').last.toLowerCase();
    final mimeSubtype = (ext == 'jpg' || ext == 'jpeg') ? 'jpeg' : 'png';

    request.files.add(
      http.MultipartFile.fromBytes(
        "image",
        imageBytes,
        filename: fileName.contains('.') ? fileName : '$fileName.jpg',
        contentType: MediaType('image', mimeSubtype),
      ),
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