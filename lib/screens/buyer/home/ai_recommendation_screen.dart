import 'package:flutter/material.dart';
import 'package:frontend/screens/buyer/home/recommendation_result_screen.dart';
import 'package:get/get.dart';

import '../../../core/utils/themes.dart';
import '../../../core/services/ai_recommendation_service.dart';

class AiRecommendationScreen extends StatefulWidget {
  const AiRecommendationScreen({super.key});

  @override
  State<AiRecommendationScreen> createState() => _AiRecommendationScreenState();
}

class _AiRecommendationScreenState extends State<AiRecommendationScreen> {
  final TextEditingController _queryController = TextEditingController();
  bool _isLoading = false;

  // Quick suggestion chips
  final List<String> _suggestions = [
    "Sella Rice",
    "Basmati Rice",
    "Biryani Rice",
    "Brown Rice",
    "Jasmine Rice",
    "Parboiled Rice",
  ];

  // =========================
  // SEARCH
  // =========================
  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      Get.snackbar("Error", "Please enter a rice type or dish name");
      return;
    }

    setState(() => _isLoading = true);

    final result = await AiRecommendationService().getRecommendation(
      query: query.trim(),
    );

    setState(() => _isLoading = false);

    if (result.containsKey("error")) {
      Get.snackbar(
        "Error",
        result["error"],
        backgroundColor: AppColors.error.withOpacity(0.15),
      );
      return;
    }

    Get.to(
      () => AiRecommendationResultScreen(query: query.trim(), result: result),
      transition: Transition.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("AI Rice Advisor")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Banner ────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.darkGreen.withOpacity(0.85),
                      AppColors.lightGreen.withOpacity(0.70),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.borderGold.withOpacity(0.50),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.cream.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.cream,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "AI Rice Advisor",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.cream,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Ask about any rice type or dish. Get detailed info, uses, recipes, and matching products from our shop.",
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.cream.withOpacity(0.88),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Search Label ───────────────────────────────────
              Text("What are you looking for?", style: AppTextStyles.heading3),
              const SizedBox(height: 6),
              Text(
                "Enter a rice type (e.g. Sella Rice) or a dish (e.g. Biryani)",
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 16),

              // ── Search Field ───────────────────────────────────
              Container(
                decoration: AppDecorations.card,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      decoration: AppDecorations.inputField,
                      child: TextField(
                        controller: _queryController,
                        style: AppTextStyles.bodyLarge,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _search,
                        decoration: InputDecoration(
                          hintText: "e.g. Sella Rice, Biryani, Brown Rice...",
                          hintStyle: AppTextStyles.hint,
                          prefixIcon: const Icon(
                            Icons.rice_bowl_outlined,
                            color: AppColors.darkGreen,
                          ),
                          suffixIcon: _queryController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _queryController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Search Button ──────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => _search(_queryController.text),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.darkGreen,
                                ),
                              )
                            : const Icon(Icons.auto_awesome, size: 18),
                        label: Text(
                          _isLoading ? "Analyzing..." : "Get AI Recommendation",
                          style: AppTextStyles.button,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Quick Suggestions ──────────────────────────────
              Text("Quick Suggestions", style: AppTextStyles.heading4),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _suggestions.map((s) {
                  return GestureDetector(
                    onTap: () {
                      _queryController.text = s;
                      setState(() {});
                      _search(s);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: AppDecorations.pill,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.grain,
                            size: 14,
                            color: AppColors.golden,
                          ),
                          const SizedBox(width: 6),
                          Text(s, style: AppTextStyles.label),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // ── How it works ───────────────────────────────────
              Text("How It Works", style: AppTextStyles.heading4),
              const SizedBox(height: 12),
              _howItWorksStep(
                icon: Icons.search,
                title: "1. Enter Rice or Dish",
                desc:
                    "Type any rice variety like Sella, Basmati, or a dish like Biryani.",
              ),
              const SizedBox(height: 10),
              _howItWorksStep(
                icon: Icons.auto_awesome,
                title: "2. AI Analysis",
                desc:
                    "Our AI powered by GPT analyzes the rice type, its uses, nutritional value, and cooking methods.",
              ),
              const SizedBox(height: 10),
              _howItWorksStep(
                icon: Icons.store,
                title: "3. Shop Products",
                desc:
                    "We match the recommendation with available products in our shop for you.",
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // HOW IT WORKS STEP WIDGET
  // =========================
  Widget _howItWorksStep({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.golden.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.golden, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label),
                const SizedBox(height: 4),
                Text(desc, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}
