// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/utils/themes.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  final _feedbackController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isSending = false;

  final List<String> _categories = [
    'General',
    'Bug Report',
    'Feature Request',
    'Performance',
    'Other',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_feedbackController.text.trim().isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter your feedback.',
        backgroundColor: AppColors.cream.withOpacity(0.95),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() => _isSending = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate API
    setState(() => _isSending = false);
    _feedbackController.clear();
    setState(() => _rating = 0);
    Get.back();
    Get.snackbar(
      'Thank You!',
      'Your feedback has been submitted.',
      backgroundColor: AppColors.cream.withOpacity(0.95),
      colorText: AppColors.darkGreen,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppDecorations.iconButton,
                        child: const Icon(Icons.arrow_back_ios_new, size: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Feedback', style: AppTextStyles.heading3),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: AppDecorations.card,
                        child: Column(
                          children: [
                            Text(
                              'Rate your experience',
                              style: AppTextStyles.heading4,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (i) {
                                final star = i + 1;
                                return GestureDetector(
                                  onTap: () => setState(() => _rating = star),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Icon(
                                      _rating >= star
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: AppColors.golden,
                                      size: 34,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Category
                      Text('Category', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((cat) {
                          final selected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = cat),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.golden.withOpacity(0.75)
                                    : AppColors.cream.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.golden
                                      : AppColors.borderGold.withOpacity(0.45),
                                ),
                              ),
                              child: Text(
                                cat,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: selected
                                      ? AppColors.cream
                                      : AppColors.darkGreen,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Message
                      Text('Your Feedback', style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      Container(
                        decoration: AppDecorations.inputField,
                        child: TextField(
                          controller: _feedbackController,
                          maxLines: 5,
                          style: AppTextStyles.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'Tell us what you think...',
                            hintStyle: AppTextStyles.hint,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isSending ? null : _submit,
                        child: _isSending
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Submit Feedback'),
                      ),
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
} // TODO Implement this library.
