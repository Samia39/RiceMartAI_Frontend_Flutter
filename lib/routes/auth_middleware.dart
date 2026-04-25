import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // We must use a synchronous check — load the token synchronously via
    // a flag that is pre-loaded at app startup (see main.dart tip below).
    // For simplicity, we check synchronously using GetStorage or a cached value.
    // If you prefer SharedPreferences, initialise the flag in main.dart like:
    //
    //   final prefs = await SharedPreferences.getInstance();
    //   final loggedIn = prefs.getString('auth_token')?.isNotEmpty ?? false;
    //   runApp(MyApp(isLoggedIn: loggedIn));
    //
    // Then pass isLoggedIn into the middleware or a controller.
    //
    // For a quick solution that works without extra setup:
    return null; // let AuthController handle redirect after async check
  }
}

/// Drop this mixin on any screen that requires authentication.
/// Call [checkAuth] in initState.
mixin AuthCheck on State<StatefulWidget> {
  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isEmpty) {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}