import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_repo/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // ✅ FIXED: Simple 3 second delay then go to login
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5A8A6E), Color(0xFF9D7E3F)],
          ),
        ),
        child: Stack(
          children: [
            // Animated rice falling
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: RiceFallPainter(_controller.value),
                );
              },
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomPaint(
                    size: const Size(120, 80),
                    painter: WheatPainter(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Rice Mart',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 56,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF1A2820),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'AI Detection and Suggestion',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1A2820),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 80),
                  const Text(
                    'Loading.....',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1A2820),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RiceGrain {
  double x, y, speed, size;
  RiceGrain(this.x, this.y, this.speed, this.size);
}

class RiceFallPainter extends CustomPainter {
  final double animation;
  static final List<RiceGrain> grains = _generateGrains();

  RiceFallPainter(this.animation);

  static List<RiceGrain> _generateGrains() {
    final random = Random(42);
    return List.generate(150, (index) {
      return RiceGrain(
        random.nextDouble() * 400,
        random.nextDouble() * 900,
        0.3 + random.nextDouble() * 0.7,
        2.0 + random.nextDouble() * 2.5,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeCap = StrokeCap.round;

    for (var grain in grains) {
      double yPos =
          (grain.y + (animation * size.height * grain.speed)) % size.height;
      double xPos = (grain.x * size.width / 400);
      paint.strokeWidth = grain.size;
      canvas.drawLine(
        Offset(xPos, yPos),
        Offset(xPos - 1, yPos + grain.size * 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(RiceFallPainter oldDelegate) => true;
}

class WheatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A2820)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      double xOffset = size.width / 4 + (i * size.width / 4);

      final stemPaint = Paint()
        ..color = const Color(0xFF1A2820)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(xOffset, size.height);
      path.quadraticBezierTo(
        xOffset - 5,
        size.height * 0.6,
        xOffset,
        size.height * 0.2,
      );
      canvas.drawPath(path, stemPaint);

      for (int j = 0; j < 8; j++) {
        double yPos = size.height - (j * size.height / 10);
        double leafLength = 12 - (j * 0.5);

        final leftLeaf = Path();
        leftLeaf.moveTo(xOffset, yPos);
        leftLeaf.quadraticBezierTo(
          xOffset - leafLength,
          yPos - 4,
          xOffset - leafLength + 2,
          yPos - 8,
        );
        canvas.drawPath(leftLeaf, paint);

        final rightLeaf = Path();
        rightLeaf.moveTo(xOffset, yPos);
        rightLeaf.quadraticBezierTo(
          xOffset + leafLength,
          yPos - 4,
          xOffset + leafLength - 2,
          yPos - 8,
        );
        canvas.drawPath(rightLeaf, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
