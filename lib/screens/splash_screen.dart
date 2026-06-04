import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../core/utils/themes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int dotCount = 0;
  Timer? _timer;
  final box = GetStorage();
  final AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();

    // 🔄 START DOT ANIMATION (this was missing ❌ before)
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount + 1) % 4; // 0 → 3 dots loop
      });
    });

    // ⏳ NAVIGATION AFTER 3 SEC
    Future.delayed(const Duration(seconds: 3), () async {
      var token = box.read('token');

      if (token == null) {
        Get.offNamed(AppRoutes.login);
        return;
      }

      await authController.loadUser();

      final roles = authController.roles;

      if (roles.contains('admin') || roles.contains('super_admin')) {
        Get.offNamed(AppRoutes.adminDashboard);
        return;
      }

      if (roles.contains('seller')) {
        Get.offNamed(AppRoutes.sellerDashboard);
        return;
      }

      Get.offNamed(AppRoutes.dashboard);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground, // 🌈 use theme gradient

      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              // 🖼️ Logo
              Image.asset('assets/images/logo.png', height: 180),

              const SizedBox(height: 10),

              // 🏷️ App Name
              Text(
                "RiceMart",
                style: AppTextStyles.heading1.copyWith(fontSize: 28),
              ),

              const SizedBox(height: 8),

              // ✨ Tagline
              Text(
                "Quality Rice, Trusted Sellers",
                style: AppTextStyles.bodyMedium,
              ),

              const SizedBox(height: 40),

              // 🔄 Loading text with animation
              Text(
                "Loading${"." * dotCount}",
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.darkGreen,
                ),
              ),

              const SizedBox(height: 10),

              // 📊 Progress bar
              SizedBox(width: 200, child: const LinearProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
