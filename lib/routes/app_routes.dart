// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_repo/screens/login%20screen/forgot_password.dart';
import 'package:flutter_repo/screens/login%20screen/privacy_policy_screen.dart';
import 'package:flutter_repo/screens/login%20screen/terms_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/login screen/login_screen.dart';
import '../screens/register_screen.dart';
import 'package:flutter_repo/screens/dashboard_screen/dashboard.dart';
import 'package:flutter_repo/screens/dashboard_screen/create_shops.dart';
import 'package:flutter_repo/screens/dashboard_screen/my_shop.dart';
import 'package:flutter_repo/screens/dashboard_screen/profile%20screen/profile_screen.dart';
import 'package:flutter_repo/screens/dashboard_screen/admin%20screen/admin_screen.dart';
import 'package:flutter_repo/screens/dashboard_screen/ai screen/ai_detection.dart';
import 'package:flutter_repo/screens/dashboard_screen/ai screen/ai_suggestion.dart';
import 'package:flutter_repo/screens/dashboard_screen/admin screen/content_management.dart';
import '../screens/dashboard_screen/profile screen/change_password_screen.dart';
import '../screens/dashboard_screen/profile screen/notification_settings_screen.dart';
import 'package:flutter_repo/screens/dashboard_screen/cart_screen.dart';
import 'package:flutter_repo/screens/dashboard_screen/chat_screen.dart';
import 'package:flutter_repo/screens/dashboard_screen/profile screen/my_orders_screen.dart';
import 'package:flutter_repo/screens/dashboard_screen/profile screen/privacy_security_screen.dart';
import 'package:flutter_repo/screens/dashboard_screen/profile screen/feedback_screen.dart';
import 'package:flutter_repo/screens/dashboard_screen/profile screen/edit_profile_screen.dart';
import 'auth_middleware.dart';

class AppRoutes {
  // ── Authentication Routes ───────────────────────────────────
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String terms = '/terms';
  static const String privacyPolicy = '/privacy-policy';

  // ── Dashboard & Main Routes ────────────────────────────────
  static const String dashboard = '/dashboard';
  static const String shops = '/shops';
  static const String cart = '/cart';
  static const String chat = '/chat';
  static const String notifications = '/notifications';

  // ── Dashboard Tab Routes ───────────────────────────────────
  static const String addshops = '/add-shops';
  static const String createshops = '/create-shops';
  static const String myShop = '/my-shop';
  static const String profile = '/profile';
  static const String adminscreen = '/admin-screen';

  // ── AI Feature Routes ──────────────────────────────────────
  static const String aiDetection = '/ai-detection';
  static const String aiRecommendation = '/ai-recommendation';

  // ── Sub-routes (Profile) ───────────────────────────────────
  static const String changepassword = '/change-password';
  static const String notification = '/notification';
  static const String contentManagement = '/content-management';
  static const String myOrders = '/my-orders';
  static const String privacySecurity = '/privacy-security';
  static const String feedback = '/feedback';
  static const String editProfile = '/edit-profile';

  // ── AI Aliases (for backward compatibility) ────────────────
  static const String recommendation = '/recommendation';
  static const String suggestion = '/suggestion';

  // ────────────────────────────────────────────────────────────
  //  PAGE DEFINITIONS
  // ────────────────────────────────────────────────────────────
  static final List<GetPage<dynamic>> pages = [
    // ── Auth Pages ──────────────────────────────────────────
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: register, page: () => RegisterScreen()),
    GetPage(name: forgotPassword, page: () => ForgotPasswordScreen()),
    GetPage(name: terms, page: () => TermsScreen()),
    GetPage(name: privacyPolicy, page: () => PrivacyPolicyScreen()),

    // ── Main Dashboard (with Auth middleware) ───────────────
    GetPage(
      name: dashboard,
      page: () => DashboardScreen(),
      middlewares: [AuthMiddleware()],
    ),

    // ── Dashboard Tab Pages ────────────────────────────────
    GetPage(name: addshops, page: () => CreateShopScreen()),
    GetPage(name: shops, page: () => MyShopScreen()),
    GetPage(name: createshops, page: () => CreateShopScreen()),
    GetPage(name: myShop, page: () => MyShopScreen()),
    GetPage(name: profile, page: () => ProfileScreen()),
    GetPage(name: adminscreen, page: () => AdminScreen()),

    // ── AI Feature Pages ───────────────────────────────────
    GetPage(name: aiDetection, page: () => AiDetectionScreen()),
    GetPage(name: recommendation, page: () => AiDetectionScreen()),
    GetPage(name: aiRecommendation, page: () => AiRecommendationScreen()),
    GetPage(name: suggestion, page: () => AiRecommendationScreen()),

    // ── Main Action Pages ──────────────────────────────────
    GetPage(name: cart, page: () => CartScreen()),
    GetPage(name: chat, page: () => ChatScreen()),
    GetPage(name: notifications, page: () => ContentManagementScreen()),

    // ── Profile Sub-routes ─────────────────────────────────
    GetPage(name: changepassword, page: () => ChangePasswordScreen()),
    GetPage(name: notification, page: () => NotificationSettingsScreen()),
    GetPage(name: contentManagement, page: () => ContentManagementScreen()),
    GetPage(name: myOrders, page: () => MyOrdersScreen()),
    GetPage(name: privacySecurity, page: () => PrivacySecurityScreen()),
    GetPage(name: feedback, page: () => FeedbackScreen()),
    GetPage(name: editProfile, page: () => EditProfileScreen()),
  ];
}