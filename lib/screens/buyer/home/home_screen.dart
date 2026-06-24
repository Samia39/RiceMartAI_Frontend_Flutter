import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/utils/themes.dart';
import 'ai_detection_screen.dart';
import 'ai_recommendation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final userName = box.read("name") ?? "User"; // 👈 read from storage

    return Scaffold(
      body: Container(
        decoration: AppDecorations.gradientBackground,

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= TITLE =================
                  Text(
                    "Rice Mart",
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.cream,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ================= WELCOME CARD =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: AppDecorations.card,

                    child: Row(
                      children: [
                        // Rice Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            "https://images.unsplash.com/photo-1516684732162-798a0062be99",
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 18),

                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome 👋",
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.darkGreen.withOpacity(0.75),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                userName,
                                style: AppTextStyles.heading2,
                              ), // 👈 dynamic name

                              const SizedBox(height: 6),

                              Text(
                                "Explore Smart Rice AI",
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  Text(
                    "Features",
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.cream,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ================= AI DETECTION =================
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AIDetectionScreen(),
                        ),
                      );
                    },

                    child: featureCard(
                      icon: Icons.camera_alt_rounded,
                      title: "AI Rice Category Detection",
                      subtitle: "Upload rice image and detect category",
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ================= RECOMMENDATION =================
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AiRecommendationScreen(),
                        ),
                      );
                    },

                    child: featureCard(
                      icon: Icons.recommend_rounded,
                      title: "Rice Recommendation",
                      subtitle: "Get smart rice recommendations",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.card,

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: AppDecorations.iconButton,
            child: Icon(icon, size: 30, color: AppColors.darkGreen),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.heading4.copyWith(fontSize: 16),
                ),

                const SizedBox(height: 6),

                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.darkGreen.withOpacity(0.7),
            size: 18,
          ),
        ],
      ),
    );
  }
}
