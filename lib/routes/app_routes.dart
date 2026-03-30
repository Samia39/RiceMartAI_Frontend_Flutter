import 'package:flutter/material.dart';
import 'package:flutter_repo/screens/login%20screen/forgot_password.dart';
import 'package:flutter_repo/screens/login%20screen/privacy_policy_screen.dart';
import 'package:flutter_repo/screens/login%20screen/terms_screen.dart';
import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/login screen/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/dashboard_screen.dart';
import 'auth_middleware.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String forgotPassword = '/forgot-password';
  static const String terms = '/terms';
  static const String privacyPolicy = '/privacy-policy';

  static final List<GetPage<dynamic>> pages = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: register, page: () => RegisterScreen()),
    GetPage(
      name: dashboard,
      page: () => DashboardScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: forgotPassword, page: () => ForgotPasswordScreen()),
    GetPage(name: terms, page: () => TermsScreen()),
    GetPage(name: privacyPolicy, page: () => PrivacyPolicyScreen()),
  ];
}
