import 'package:flutter/material.dart';
import '../core/services/rice_recommendation_service.dart';
import '../models/rice_recommendation.dart';
import 'user_dashboard.dart'; // AppColors, AppGradients, AppTextStyles

class RiceRecommendationScreen extends StatefulWidget {
  const RiceRecommendationScreen({super.key});

  @override
  State<RiceRecommendationScreen> createState() =>
      _RiceRecommendationScreenState();
}

class _RiceRecommendationScreenState extends State<RiceRecommendationScreen> {
  bool _isLoading = false;
  String? _error;
  List<RiceRecommendation> _results = [];
  String? _selectedUseCase;

  final List<Map<String, dynamic>> _useCases = [
    {'key': 'biryani', 'label': 'Biryani', 'icon': Icons.dinner_dining},
    {'key': 'daily', 'label': 'Daily Cooking', 'icon': Icons.restaurant},
    {'key': 'diet', 'label': 'Diet / Health', 'icon': Icons.spa_outlined},
    {'key': 'dessert', 'label': 'Dessert', 'icon': Icons.icecream_outlined},
  ];

  Future<void> _getRecommendation(String useCase) async {
    setState(() {
      _selectedUseCase = useCase;
      _isLoading = true;
      _error = null;
      _results = [];
    });
    try {
      final results = await RiceRecommendationService.getRecommendation(useCase);
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Recommendation failed: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 16, 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cream.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.borderGold.withOpacity(0.50)),
                        ),
                        child: Icon(Icons.arrow_back,
                            color: AppColors.darkGreen, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      "Rice Recommendation",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Aap rice kis liye use karna chahte hain?",
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Ek option select karein, hum best rice suggest karenge",
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 16),

                      // Use-case selection grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: _useCases.map((uc) {
                          final selected = _selectedUseCase == uc['key'];
                          return GestureDetector(
                            onTap: () => _getRecommendation(uc['key']),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.lightGreen.withOpacity(0.45)
                                    : AppColors.cardFill,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.darkGreen
                                      : AppColors.cardBorder,
                                  width: selected ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(uc['icon'], color: AppColors.darkGreen, size: 28),
                                  const SizedBox(height: 8),
                                  Text(uc['label'],
                                      style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      if (_isLoading)
                        Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: AppColors.darkGreen),
                              const SizedBox(height: 10),
                              Text("Finding best rice for you...",
                                  style: AppTextStyles.labelMuted),
                            ],
                          ),
                        ),

                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.error.withOpacity(0.4)),
                          ),
                          child: Text(_error!,
                              style: TextStyle(color: AppColors.darkGreen)),
                        ),

                      ..._results.map((r) => _buildResultCard(r)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(RiceRecommendation result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.recommend, color: AppColors.darkGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(result.category, style: AppTextStyles.heading3),
              ),
            ],
          ),
          Divider(color: AppColors.divider, height: 24),
          _detailRow(Icons.local_fire_department_outlined, "Cooking Time",
              result.cookingTime),
          const SizedBox(height: 10),
          _detailRow(Icons.restaurant_menu, "Commonly Used For", result.commonUses),
          const SizedBox(height: 10),
          _detailRow(Icons.info_outline, "Description", result.description),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.iconMuted, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}