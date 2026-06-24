import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // Common headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Handle API responses
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data = response.body.isNotEmpty
        ? jsonDecode(response.body)
        : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    String message = "Something went wrong";

    if (data.containsKey('message')) {
      message = data['message'].toString();
    } else if (data.containsKey('error')) {
      message = data['error'].toString();
    } else if (data.containsKey('errors')) {
      final errors = data['errors'];

      if (errors is Map) {
        message = errors.values.first.first.toString();
      }
    }

    throw Exception(message);
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // REGISTER
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _headers,
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // VERIFY OTP
  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: _headers,
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // RESEND OTP
  static Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resend-otp'),
        headers: _headers,
        body: jsonEncode({'email': email}),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // CURRENT USER
  static Future<Map<String, dynamic>> me(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // FORGOT PASSWORD
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: _headers,
        body: jsonEncode({'email': email}),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // RESET PASSWORD
  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: _headers,
        body: jsonEncode({'email': email, 'otp': otp, 'password': newPassword}),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // UPDATE PROFILE
  static Future<Map<String, dynamic>> updateProfile(
    String token, {
    String? name,
    String? email,
    String? password,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      if (name != null && name.isNotEmpty) {
        body['name'] = name;
      }

      if (email != null && email.isNotEmpty) {
        body['email'] = email;
      }

      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/update-profile'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // LOGOUT
  static Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
