import 'package:flutter/material.dart';
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

    try {
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
        box.write('name', res['user']?['name'] ?? ''); // ✅ safe null check
        box.write('email', res['user']?['email'] ?? ''); // ✅ save email too

        redirectUser(res);
      } else {
        Get.snackbar(
          "Login Failed",
          res['message'] ?? "Invalid credentials",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Login Failed",
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ======================
  // REGISTER
  // ======================
  Future<void> register(String name, String email, String password) async {
    isLoading.value = true;

    try {
      final res = await AuthService.register(name, email, password);

      if (res['token'] != null) {
        Get.snackbar(
          "Success",
          "Registered successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back();
      } else {
        Get.snackbar(
          "Register Failed",
          res['message'] ?? "Registration failed",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Register Failed",
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ======================
  // LOAD USER (AUTO LOGIN)
  // ======================
  Future<void> loadUser() async {
    try {
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
      box.write(
        'name',
        res['user']?['name'] ?? '',
      ); // ✅ refresh name on app restart
      box.write(
        'email',
        res['user']?['email'] ?? '',
      ); // ✅ refresh email on app restart
    } catch (e) {
      await logout();
    }
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

    final box = GetStorage();
    box.erase();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Get.offAllNamed('/login');
  }

  // ======================
  // REDIRECT
  // ======================
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