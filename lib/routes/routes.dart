import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/login screen/login_screen.dart';
import '../screens/register_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';

  static final List<GetPage> pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
  ];
}