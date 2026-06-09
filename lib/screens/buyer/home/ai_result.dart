// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../core/utils/themes.dart';

class AIResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const AIResultScreen({super.key, required this.result});

  Color _qualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'good':
        return AppColors.success;
      case 'average':
        return AppColors.warning;
      case 'poor':
        return AppColors.error;
      default:
        return AppColors.lightGreen;
    }
  }

  IconData _qualityIcon(String quality) {
    switch (quality.toLowerCase()) {
      case 'good':
        return Icons.verified;
      case 'average':
        return Icons.info_outline;
      case 'poor':
        return Icons.warning_amber_rounded;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isRice = result['is_rice'] ?? false;
    final String riceType = result['rice_type'] ?? 'Unknown';
    final String quality = result['quality'] ?? 'unknown';
    final int score = (result['quality_score'] ?? 0).toInt();
    final double confidence = ((result['confidence'] ?? 0) * 100).toDouble();
    final List observations = result['observations'] ?? [];
    final List defects = result['defects'] ?? [];
    final String reasoning = result['reasoning'] ?? '';
    final String recommendation = result['recommendation'] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Detection Result')),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBackground,

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ═══════════════ HEADER CARD ═══════════════
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isRice ? Icons.grain : Icons.hide_image_outlined,
                        color: AppColors.cream,
                        size: 36,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRice ? 'Rice Detected ✓' : 'No Rice Found',
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.cream,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Confidence: ${confidence.toStringAsFixed(0)}%',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.cream.withOpacity(0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ═══════════════ RICE TYPE + QUALITY ═══════════════
                if (isRice) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _infoTile(
                          'Rice Type',
                          riceType,
                          Icons.spa_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoTile(
                          'Quality',
                          quality.toUpperCase(),
                          _qualityIcon(quality),
                          valueColor: _qualityColor(quality),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Score bar ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppDecorations.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Quality Score', style: AppTextStyles.label),
                            Text(
                              '$score / 100',
                              style: AppTextStyles.label.copyWith(
                                color: _qualityColor(quality),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: score / 100,
                            minHeight: 14,
                            backgroundColor: AppColors.darkGreen.withOpacity(
                              0.10,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _qualityColor(quality),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],

                // ═══════════════ OBSERVATIONS ═══════════════
                if (observations.isNotEmpty) ...[
                  _sectionCard(
                    title: 'Observations',
                    icon: Icons.visibility_outlined,
                    items: observations.map((e) => e.toString()).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // ═══════════════ DEFECTS ═══════════════
                if (defects.isNotEmpty) ...[
                  _sectionCard(
                    title: 'Defects Found',
                    icon: Icons.bug_report_outlined,
                    items: defects.map((e) => e.toString()).toList(),
                    dotColor: AppColors.error,
                    iconColor: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                ],

                // ═══════════════ REASONING ═══════════════
                if (reasoning.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: AppDecorations.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.psychology_outlined,
                              size: 16,
                              color: AppColors.darkGreen,
                            ),
                            const SizedBox(width: 6),
                            Text('AI Reasoning', style: AppTextStyles.label),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(reasoning, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ═══════════════ RECOMMENDATION ═══════════════
                if (recommendation.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.golden.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.golden.withOpacity(0.45),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.golden,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recommendation',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.golden,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                recommendation,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ═══════════════ SCAN AGAIN BUTTON ═══════════════
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Scan Another Image'),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════ HELPERS ═══════════════

  Widget _infoTile(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: AppColors.labelSecondary),
              const SizedBox(width: 5),
              Text(label, style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.heading4.copyWith(
              color: valueColor ?? AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<String> items,
    Color? dotColor,
    Color? iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor ?? AppColors.darkGreen),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTextStyles.label.copyWith(
                  color: iconColor ?? AppColors.darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dotColor ?? AppColors.darkGreen.withOpacity(0.50),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: AppTextStyles.bodyMedium)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
