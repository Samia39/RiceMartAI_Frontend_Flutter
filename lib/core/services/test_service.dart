import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class TestService {
  static Future<bool> uploadImage(XFile imageFile) async {
    try {
      // ================= IMAGE BYTES =================
      final bytes = await imageFile.readAsBytes();

      // ================= REQUEST =================
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/api/test-image'),
      );

      // ================= ADD IMAGE =================
      request.files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name),
      );

      print("REQUEST STARTED");

      // ================= SEND =================
      var response = await request.send();

      print("STATUS CODE: ${response.statusCode}");

      final responseData = await response.stream.bytesToString();

      print("RESPONSE: $responseData");

      return response.statusCode == 200;
    } catch (e) {
      print("UPLOAD ERROR: $e");

      return false;
    }
  }
}
