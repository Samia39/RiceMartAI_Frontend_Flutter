// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class AuthService {
  AuthService._();

  // ── Base URL — apna Laravel URL yahan daalo ──────────────────
static const String _baseUrl = 'http://127.0.0.1:8000/api';

  static final _box = GetStorage();

  // ── Token helpers ────────────────────────────────────────────
  static String? getToken()          => _box.read('token');
  static bool   isLoggedIn()         => getToken() != null;
  static Future<void> clearToken()   async => await _box.remove('token');

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept':       'application/json',
    if (getToken() != null) 'Authorization': 'Bearer ${getToken()}',
  };

  // ────────────────────────────────────────────────────────────
  //  LOGIN
  // ────────────────────────────────────────────────────────────
  /// Returns null on success, error message string on failure.
  static Future<String?> login({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: _headers,
        body: jsonEncode({
          'username': username,
          'email':    email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _box.write('token', data['token']);
        await _box.write('user',  jsonEncode(data['user'] ?? {}));
        return null; // success
      }

      return data['message'] ?? 'Login failed.';
    } catch (e) {
      return 'Network error. Please check your connection.';
    }
  }

  // ────────────────────────────────────────────────────────────
  //  REGISTER
  // ────────────────────────────────────────────────────────────
  /// Returns null on success, error message string on failure.
  static Future<String?> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: _headers,
        body: jsonEncode({
          'name':                  fullName,
          'username':              username,
          'email':                 email,
          'password':              password,
          'password_confirmation': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return null; // success
      }

      // Laravel validation errors
      if (response.statusCode == 422) {
        final errors = data['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          final firstError = errors.values.first;
          return firstError is List ? firstError.first : firstError.toString();
        }
      }

      return data['message'] ?? 'Registration failed.';
    } catch (e) {
      return 'Network error. Please check your connection.';
    }
  }

  // ────────────────────────────────────────────────────────────
  //  LOGOUT
  // ────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: _headers,
      );
    } catch (_) {}
    await clearToken();
  }

  // ────────────────────────────────────────────────────────────
  //  GET CURRENT USER
  // ────────────────────────────────────────────────────────────
  static Map<String, dynamic> getCurrentUser() {
    final user = _box.read('user');
    if (user == null) return {};
    return jsonDecode(user);
  }
}