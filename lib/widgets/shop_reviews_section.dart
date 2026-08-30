import 'package:flutter/material.dart';
import '../core/services/review_service.dart';
import '../core/utils/themes.dart';

class ShopReviewsSection extends StatefulWidget {
  final int shopId;

  const ShopReviewsSection({super.key, required this.shopId});

  @override
  State<ShopReviewsSection> createState() => _ShopReviewsSectionState();
}

class _ShopReviewsSectionState extends State<ShopReviewsSection> {
  bool isLoading = true;
  List<dynamic> reviews = [];
  double averageRating = 0;
  int totalReviews = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ReviewService().getShopReviews(widget.shopId);

    if (!mounted) return;

    setState(() {
      reviews = data["reviews"] ?? [];
      averageRating = (data["average_rating"] ?? 0).toDouble();
      totalReviews = data["total_reviews"] ?? 0;
      isLoading = false;
    });
  }

  Widget _starRow(num rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.round() ? Icons.star : Icons.star_border,
          size: size,
          color: AppColors.golden,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Reviews ($totalReviews)", style: AppTextStyles.heading4),
        const SizedBox(height: 10),

        // =========================
        // AVERAGE RATING SUMMARY
        // =========================
        if (totalReviews > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: AppDecorations.card,
            child: Row(
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _starRow(averageRating, size: 18),
                    const SizedBox(height: 2),
                    Text(
                      "Based on $totalReviews review${totalReviews == 1 ? '' : 's'}",
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),

        // =========================
        // INDIVIDUAL REVIEWS
        // =========================
        if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: AppDecorations.card,
            child: Text("No reviews yet", style: AppTextStyles.bodySmall),
          )
        else
          Column(
            children: reviews.map((r) {
              final customerName = r["customer"]?["name"] ?? "Customer";
              final rating = r["rating"] ?? 0;
              final reviewText = r["review"]?.toString() ?? "";

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: AppDecorations.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(customerName, style: AppTextStyles.label),
                        _starRow(rating),
                      ],
                    ),
                    if (reviewText.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(reviewText, style: AppTextStyles.bodyMedium),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
