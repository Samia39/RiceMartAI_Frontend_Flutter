import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_icons.dart';

class AuthService {
  static const baseUrl = BaseUrl.url;

  // Common headers used on every request so Laravel always treats us as an
  // API client and returns JSON (never a redirect) on validation errors.
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── Safe JSON decode with debug visibility ───────────────
  static dynamic _safeDecode(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception(
        'Empty response from server (status ${response.statusCode})',
      );
    }
    try {
      return jsonDecode(response.body);
    } catch (e) {
      // Check the browser console for the real body while debugging
      print(
        '⚠️ Non-JSON response (status ${response.statusCode}): ${response.body}',
      );
      throw Exception(
        'Server returned an invalid response (status ${response.statusCode})',
      );
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _safeDecode(response);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message']);
    }
  }

  // REGISTER
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _jsonHeaders,
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final data = _safeDecode(response);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message']);
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    final data = _safeDecode(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message']);
    }
  }

  static Future<Map<String, dynamic>> resendOtp(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resend-otp'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email}),
    );

    final data = _safeDecode(response);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message']);
    }
  }

  // ME (VERY IMPORTANT)
  static Future<Map<String, dynamic>> me(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    final data = _safeDecode(response);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Session invalid. Please log in again.',
      );
    }
  }

  // FORGOT PASSWORD - sends OTP
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email}),
    );

    final data = _safeDecode(response);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message']);
    }
  }

  // RESET PASSWORD - verifies OTP and updates password
  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'otp': otp, 'password': newPassword}),
    );

    final data = _safeDecode(response);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message']);
    }
  }

  // UPDATE PROFILE - edit name, and optionally email/password
  static Future<Map<String, dynamic>> updateProfile(
    String token, {
    required String name,
    String? email,
    String? password,
    String? passwordConfirmation,
  }) async {
    final Map<String, dynamic> body = {'name': name};

    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    }

    if (password != null && password.isNotEmpty) {
      body['password'] = password;
      body['password_confirmation'] = passwordConfirmation ?? password;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/update-profile'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final data = _safeDecode(response);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to update profile');
    }
  }

  // LOGOUT - revokes the token on the server too, not just locally
  static Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      final data = _safeDecode(response);
      throw Exception(data['message'] ?? 'Logout failed');
    }
  }
}
