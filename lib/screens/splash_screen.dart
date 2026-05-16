// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/themes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed('/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBackground,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rice wheat icon
              SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(painter: _WheatPainter()),
              ),
              const SizedBox(height: 24),

              Text('Rice Mart', style: AppTextStyles.splashTitle),
              const SizedBox(height: 8),

              Text('AI Detection and Suggestion',
                  style: AppTextStyles.splashSubtitle),
              const SizedBox(height: 70),

              Text('Loading.....', style: AppTextStyles.splashLoading),
              const SizedBox(height: 18),

              SizedBox(
                width: 160,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.darkGreen.withOpacity(0.15),
                  color: AppColors.darkGreen,
                  minHeight: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = AppColors.darkGreen
      ..style = PaintingStyle.fill;

    final stalkPaint = Paint()
      ..color = AppColors.darkGreen
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final List<Offset> stalks = [
      Offset(size.width * 0.28, size.height * 0.95),
      Offset(size.width * 0.50, size.height * 0.95),
      Offset(size.width * 0.72, size.height * 0.95),
    ];
    final List<Offset> tips = [
      Offset(size.width * 0.18, size.height * 0.12),
      Offset(size.width * 0.50, size.height * 0.04),
      Offset(size.width * 0.82, size.height * 0.12),
    ];

    for (int i = 0; i < 3; i++) {
      canvas.drawLine(stalks[i], tips[i], stalkPaint);
      final dx = tips[i].dx - stalks[i].dx;
      final dy = tips[i].dy - stalks[i].dy;

      for (int j = 1; j <= 4; j++) {
        final t = j / 5.0;
        final bx = stalks[i].dx + dx * t;
        final by = stalks[i].dy + dy * t;

        final p1 = Path()
          ..moveTo(bx, by)
          ..quadraticBezierTo(bx - 13, by - 9, bx - 9, by - 19)
          ..quadraticBezierTo(bx - 3, by - 9, bx, by);
        canvas.drawPath(p1, leafPaint);

        final p2 = Path()
          ..moveTo(bx, by)
          ..quadraticBezierTo(bx + 13, by - 9, bx + 9, by - 19)
          ..quadraticBezierTo(bx + 3, by - 9, bx, by);
        canvas.drawPath(p2, leafPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}