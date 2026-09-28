import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/auth_service.dart';

class ProfileService {
  final _box = GetStorage();

  String get token => _box.read('token') ?? '';

  dynamic _safeDecode(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception(
        'Empty response from server (status ${response.statusCode})',
      );
    }
    try {
      return jsonDecode(response.body);
    } catch (e) {
      print(
        'Non-JSON response (status ${response.statusCode}): ${response.body}',
      );
      throw Exception(
        'Server returned an invalid response (status ${response.statusCode})',
      );
    }
  }

  String parseRole(dynamic apiRoles) {
    if (apiRoles != null && apiRoles is List && apiRoles.isNotEmpty) {
      final first = apiRoles[0];
      return first is Map ? first['name'].toString() : first.toString();
    }

    final storedRoles = _box.read('roles');
    if (storedRoles is List && storedRoles.isNotEmpty) {
      final first = storedRoles[0];
      return first is Map ? first['name'].toString() : first.toString();
    }

    return 'customer';
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final data = await AuthService.me(token);
    final user = data['user'] ?? data;

    final String name = user['name'] ?? '';
    final String email = user['email'] ?? '';
    final String role = parseRole(user['roles'] ?? data['roles']);
    final bool isVerified =
        (user['is_verified'] == 1 || user['is_verified'] == true);
    final bool hasShop =
        (user['has_shop'] == 1 || user['has_shop'] == true) ||
        (_box.read('has_shop') ?? false);

    return {
      'name': name,
      'email': email,
      'role': role,
      'is_verified': isVerified,
      'has_shop': hasShop,
    };
  }

  Future<void> updateProfile({
    required String name,
    String? email,
    String? password,
  }) async {
    await AuthService.updateProfile(
      token,
      name: name,
      email: email,
      password: password,
    );

    await _box.write('name', name);
    if (email != null && email.isNotEmpty) {
      await _box.write('email', email);
    }
  }

  Future<void> requestAccountDeletion() async {
    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/delete-account/request'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = _safeDecode(response);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Something went wrong');
    }
  }

  Future<void> confirmAccountDeletion(String otp) async {
    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/delete-account/confirm'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'otp': otp}),
    );

    final data = _safeDecode(response);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Something went wrong');
    }
  }
}
