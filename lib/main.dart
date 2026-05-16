import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/utils/themes.dart';
import 'screens/splash_screen.dart';
import 'screens/login screen/login_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Rice Mart',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash',    page: () => const SplashScreen()),
        GetPage(name: '/login',     page: () => const LoginScreen()),
        GetPage(name: '/register',  page: () => const RegisterScreen()),
        // TODO: add more routes as you build more screens
        // GetPage(name: '/dashboard',       page: () => const DashboardScreen()),
        // GetPage(name: '/forgot-password', page: () => const ForgotPasswordScreen()),
      ],
    );
  }
}