// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/themes.dart';
import '../../models/product_model.dart';
import '../../widgets/bottom_nav.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Product p = Get.arguments as Product;

    return Scaffold(
      bottomNavigationBar: const BottomNav(currentIndex: 1),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppDecorations.iconButton,
                        child: Icon(Icons.arrow_back,
                            color: AppColors.darkGreen, size: 24),
                      ),
                    ),
                    Text('Product Detail',
                        style: AppTextStyles.heading3),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // ── Content ──────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: p.image != null
                            ? Image.network(
                                'http://10.0.2.2/sheezabackend/public/storage/${p.image}',
                                width: double.infinity,
                                height: 250,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _noImage(),
                              )
                            : _noImage(),
                      ),
                      const SizedBox(height: 20),

                      // Name + Category
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppDecorations.card,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: AppTextStyles.heading2),
                            const SizedBox(height: 4),
                            Text(p.category.toUpperCase(),
                                style: AppTextStyles.bodySmall),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Rs. ${p.price}',
                                    style: AppTextStyles.heading3.copyWith(
                                        color: AppColors.golden)),
                                Text('Stock: ${p.stock} kg',
                                    style: AppTextStyles.bodyMedium),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: AppDecorations.card,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description',
                                style: AppTextStyles.heading4),
                            const SizedBox(height: 8),
                            Text(p.description,
                                style: AppTextStyles.bodyLarge),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Widget _noImage() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.rice_bowl, size: 60, color: AppColors.darkGreen),
    );
  }
}