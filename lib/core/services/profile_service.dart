import 'package:get_storage/get_storage.dart';
import '../../../core/services/auth_service.dart';

class ProfileService {
  final _box = GetStorage();

  String get token => _box.read('token') ?? '';

  // ── Parse role from list ─────────────────────────────────
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

  // ── Fetch authenticated user ─────────────────────────────
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

  // ── Update profile ───────────────────────────────────────
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
  }

  // ── Logout ───────────────────────────────────────────────
  void clearSession() {
    _box.erase();
  }
}