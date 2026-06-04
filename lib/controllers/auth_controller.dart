import 'package:frontend/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/auth_service.dart';

class AuthController extends GetxController {
  var token = ''.obs;
  var user = {}.obs;
  var roles = <String>[].obs;
  var permissions = <String>[].obs;

  var isLoading = false.obs;

  // ======================
  // LOGIN
  // ======================
  Future<void> login(String email, String password) async {
    isLoading.value = true;

    final res = await AuthService.login(email, password);

    if (res['token'] != null) {
      token.value = res['token'];

      roles.value = List<String>.from(res['roles'] ?? []);
      permissions.value = List<String>.from(res['permissions'] ?? []);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', res['token']);

      final box = GetStorage();
      box.write('token', res['token']);
      box.write('roles', res['roles']);
      box.write('permissions', res['permissions']);
      box.write('has_shop', res['has_shop']);

      // 🚀 NOW NAVIGATE (IMPORTANT)
      redirectUser(res);
    } else {
      Get.snackbar("Error", res['message'] ?? "Login failed");
    }

    isLoading.value = false;
  }

  // ======================
  // REGISTER
  // ======================
  Future<void> register(String name, String email, String password) async {
    isLoading.value = true;

    final res = await AuthService.register(name, email, password);

    if (res['token'] != null) {
      Get.snackbar("Success", "Registered successfully");
      Get.back(); // go to login
    } else {
      Get.snackbar("Error", res['message'] ?? "Register failed");
    }

    isLoading.value = false;
  }

  // ======================
  // LOAD USER (AUTO LOGIN)
  // ======================
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');

    if (savedToken == null) return;

    token.value = savedToken;

    final res = await AuthService.me(savedToken);

    user.value = res['user'] ?? {};
    roles.value = List<String>.from(res['roles'] ?? []);
    permissions.value = List<String>.from(res['permissions'] ?? []);

    final box = GetStorage();

    box.write('roles', res['roles']);
    box.write('permissions', res['permissions']);
    box.write('has_shop', res['has_shop']);
  }

  // ======================
  // HELPERS
  // ======================
  bool hasRole(String role) => roles.contains(role);

  bool hasPermission(String permission) => permissions.contains(permission);

  // ======================
  // LOGOUT
  // ======================
  Future<void> logout() async {
    token.value = '';
    user.clear();
    roles.clear();
    permissions.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Get.offAllNamed('/login');
  }

  void redirectUser(Map data) {
    final roles = List<String>.from(data['roles'] ?? []);

    if (roles.contains('admin') || roles.contains('super_admin')) {
      Get.offAllNamed(AppRoutes.adminDashboard);
    } else if (roles.contains('seller')) {
      Get.offAllNamed(AppRoutes.sellerDashboard);
    } else {
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }
}
