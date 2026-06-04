import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/login screen/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/user_dashboard.dart';
import '../screens/admin_dashboard.dart';
import '../screens/seller_dashboard.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash          = '/';
  static const String login           = '/login';
  static const String register        = '/register';
  static const String userDashboard   = '/user-dashboard';
  static const String adminDashboard  = '/admin-dashboard';
  static const String sellerDashboard = '/seller-dashboard';
  
  static final List<GetPage> pages = [
    GetPage(name: splash,          page: () => const SplashScreen()),
    GetPage(name: login,           page: () => const LoginScreen()),
    GetPage(name: register,        page: () => const RegisterScreen()),
    GetPage(name: userDashboard,   page: () => const UserDashboard()),
    GetPage(name: adminDashboard,  page: () => const AdminDashboard()),
    GetPage(name: sellerDashboard, page: () => const SellerDashboard()),
    
  ];
}