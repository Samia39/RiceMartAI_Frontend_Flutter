import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../constants/app_icons.dart';

class TestService {
  static const String baseUrl = BaseUrl.url;
  static Future<Map<String, dynamic>> uploadImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/test-image'),
      );

      request.files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name),
      );

      var response = await request.send();
      final responseData = await response.stream.bytesToString();
      final json = jsonDecode(responseData);

      if (response.statusCode == 200 && json['success'] == true) {
        return {'success': true, 'data': json['data']};
      }

      return {'success': false, 'message': json['message'] ?? 'Upload failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
