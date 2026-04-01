import 'package:flutter/material.dart';
import 'package:flutter_repo/screens/login%20screen/forgot_password.dart';
import 'package:flutter_repo/screens/login%20screen/privacy_policy_screen.dart';
import 'package:flutter_repo/screens/login%20screen/terms_screen.dart';
import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/login screen/login_screen.dart';
import '../screens/register_screen.dart';
import 'package:flutter_repo/screens/dashboard_screen/dashboard.dart';
import 'package:flutter_repo/screens/dashboard_screen/create_shops.dart';
import 'package:flutter_repo/screens/dashboard_screen/add_shops.dart';
import 'package:flutter_repo/screens/dashboard_screen/profile%20screen/profile_screen.dart';
import 'package:flutter_repo/screens/dashboard_screen/admin%20screen/admin_screen.dart';
import 'package:flutter_repo/screens/dashboard_screen/ai screen/ai_detection.dart';
import 'package:flutter_repo/screens/dashboard_screen/ai screen/ai_suggestion.dart';
import 'package:flutter_repo/screens/dashboard_screen/admin screen/content_management.dart';
import '../screens/dashboard_screen/profile screen/change_password_screen.dart';
import '../screens/dashboard_screen/profile screen/notification_settings_screen.dart';

//import 'auth_middleware.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String terms = '/terms';
  static const String privacyPolicy = '/privacy-policy';
  static const String dashboard = '/dashboard';
  static const String addshops = '/add-shops';
  static const String adminscreen = '/admin-screen';
  static const String createshops = '/create-shops';
  static const String profile = '/profile';
  static const String recommendation = '/recommendation';
  static const String suggestion = '/suggestion';
  static const String contentManagement = '/content-management';
  static const String changepassword = '/change-password';
  static const String notification = '/notification';
  static final List<GetPage<dynamic>> pages = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: register, page: () => RegisterScreen()),

    GetPage(
      name: dashboard,
      page: () => DashboardScreen(),
      //  middlewares: [AuthMiddleware()],
    ),

    GetPage(name: forgotPassword, page: () => ForgotPasswordScreen()),
    GetPage(name: terms, page: () => TermsScreen()),
    GetPage(name: privacyPolicy, page: () => PrivacyPolicyScreen()),
    GetPage(name: addshops, page: () => ShopsScreen()),
    GetPage(name: adminscreen, page: () => AdminScreen()),
    GetPage(name: createshops, page: () => CreateScreen()),
    GetPage(name: profile, page: () => ProfileScreen()),
    GetPage(name: suggestion, page: () => AiRecommendationScreen()),
    GetPage(name: recommendation, page: () => AiDetectionScreen()),
    GetPage(name: contentManagement, page: () => ContentManagementScreen()),
    GetPage(name: changepassword, page: () => ChangePasswordScreen()),
    GetPage(name: notification, page: () => NotificationSettingsScreen()),
  ];
}
