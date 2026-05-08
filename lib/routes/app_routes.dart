import 'package:frontend/screens/buyer/dashboard/buyer_dashboard_screen.dart';
import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';
import '../screens/splash_screen.dart';
import '../middleware/auth_middleware.dart';
import '../screens/auth/register_screen.dart';
import '../screens/admin_screens/dashboard/admin_dashboard.dart';

class AppRoutes {
  static const splash = "/";
  static const login = "/login";
  static const register = "/register";
  static const dashboard = "/dashboard";
  static const adminDashboard = "/admin-dashboard";

  static final routes = [
    GetPage(name: splash, page: () => SplashScreen()),

    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: register, page: () => RegisterScreen()),
    GetPage(
      name: dashboard,
      page: () => const DashboardScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: adminDashboard, page: () => const AdminDashboard()),
  ];
}
