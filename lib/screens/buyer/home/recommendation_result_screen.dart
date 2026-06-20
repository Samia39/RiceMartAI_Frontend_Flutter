import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/themes.dart';
import '../../../routes/app_routes.dart';

class AiRecommendationResultScreen extends StatelessWidget {
  final String query;
  final Map<String, dynamic> result;

  const AiRecommendationResultScreen({
    super.key,
    required this.query,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final aiData = result["ai"] as Map<String, dynamic>? ?? {};
    final products = result["products"] as List<dynamic>? ?? [];

    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("AI Recommendation")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Query Badge ────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.borderGold.withOpacity(0.50),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search, size: 15, color: AppColors.golden),
                    const SizedBox(width: 6),
                    Text(
                      "Results for: $query",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ── Rice Overview Card ─────────────────────────────
              if (aiData["overview"] != null)
                _sectionCard(
                  icon: Icons.info_outline,
                  title: "Overview",
                  child: Text(
                    aiData["overview"] ?? "",
                    style: AppTextStyles.bodyLarge,
                  ),
                ),

              const SizedBox(height: 14),

              // ── Rice Type & Origin ─────────────────────────────
              if (aiData["rice_type"] != null || aiData["origin"] != null)
                _sectionCard(
                  icon: Icons.grain,
                  title: "Rice Details",
                  child: Column(
                    children: [
                      if (aiData["rice_type"] != null)
                        _detailRow("Type", aiData["rice_type"]),
                      if (aiData["origin"] != null)
                        _detailRow("Origin", aiData["origin"]),
                      if (aiData["grain_size"] != null)
                        _detailRow("Grain Size", aiData["grain_size"]),
                      if (aiData["texture"] != null)
                        _detailRow("Texture", aiData["texture"]),
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              // ── Best Uses ──────────────────────────────────────
              if (aiData["best_uses"] != null)
                _sectionCard(
                  icon: Icons.restaurant_menu,
                  title: "Best Uses",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildBulletList(aiData["best_uses"]),
                  ),
                ),

              const SizedBox(height: 14),

              // ── Nutritional Info ───────────────────────────────
              if (aiData["nutrition"] != null)
                _sectionCard(
                  icon: Icons.health_and_safety_outlined,
                  title: "Nutritional Value",
                  child: Text(
                    aiData["nutrition"] ?? "",
                    style: AppTextStyles.bodyLarge,
                  ),
                ),

              const SizedBox(height: 14),

              // ── Recipe ─────────────────────────────────────────
              if (aiData["recipe"] != null)
                _sectionCard(
                  icon: Icons.menu_book_outlined,
                  title: "How to Cook",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (aiData["recipe"]["name"] != null)
                        Text(
                          aiData["recipe"]["name"],
                          style: AppTextStyles.heading4,
                        ),
                      const SizedBox(height: 10),
                      if (aiData["recipe"]["ingredients"] != null) ...[
                        Text(
                          "Ingredients",
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.golden,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ..._buildBulletList(aiData["recipe"]["ingredients"]),
                        const SizedBox(height: 12),
                      ],
                      if (aiData["recipe"]["steps"] != null) ...[
                        Text(
                          "Steps",
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.golden,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ..._buildNumberedList(aiData["recipe"]["steps"]),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              // ── Storage Tips ───────────────────────────────────
              if (aiData["storage_tips"] != null)
                _sectionCard(
                  icon: Icons.inventory_2_outlined,
                  title: "Storage Tips",
                  child: Text(
                    aiData["storage_tips"] ?? "",
                    style: AppTextStyles.bodyLarge,
                  ),
                ),

              const SizedBox(height: 24),

              // ── Available Products ─────────────────────────────
              Row(
                children: [
                  const Icon(Icons.store, color: AppColors.golden, size: 22),
                  const SizedBox(width: 8),
                  Text("Available in Our Shop", style: AppTextStyles.heading3),
                ],
              ),
              const SizedBox(height: 12),

              if (products.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppDecorations.card,
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.store_mall_directory_outlined,
                          size: 40,
                          color: AppColors.darkGreen.withOpacity(0.35),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No matching products found in our shop currently.",
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...products.map((product) {
                  final p = product as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      // Navigate to ShopDetailsScreen, same arguments shape
                      // it already reads from elsewhere in the app
                      // (id, shop_name, owner_name, phone, address, description).
                      Get.toNamed(
                        AppRoutes.shopDetails,
                        arguments: {
                          "id": p["shop_id"],
                          "shop_name": p["shop_name"] ?? "",
                          "owner_name": p["owner_name"] ?? "",
                          "phone": p["shop_phone"] ?? "",
                          "address": p["shop_address"] ?? "",
                          "description": p["shop_description"] ?? "",
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: AppDecorations.card,
                      child: Row(
                        children: [
                          // Icon container
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.golden.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.rice_bowl,
                              color: AppColors.golden,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p["name"] ?? "",
                                  style: AppTextStyles.heading4,
                                ),
                                const SizedBox(height: 4),
                                if (p["category_name"] != null)
                                  Text(
                                    p["category_name"],
                                    style: AppTextStyles.bodySmall,
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _infoBadge(
                                      "Rs ${p["price"]} / kg",
                                      Icons.currency_rupee,
                                      AppColors.golden,
                                    ),
                                    const SizedBox(width: 8),
                                    _infoBadge(
                                      "${p["stock"]} kg",
                                      Icons.inventory,
                                      AppColors.lightGreen,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Shop info
                          Column(
                            children: [
                              if (p["shop_name"] != null) ...[
                                const Icon(
                                  Icons.store,
                                  size: 14,
                                  color: AppColors.lightGreen,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p["shop_name"],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.lightGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                              ],
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: AppColors.darkGreen.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // SECTION CARD WIDGET
  // =========================
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.golden.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.golden, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.heading4),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // =========================
  // DETAIL ROW
  // =========================
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(color: AppColors.golden),
            ),
          ),
          const Text(": ", style: AppTextStyles.bodyLarge),
          Expanded(child: Text(value, style: AppTextStyles.bodyLarge)),
        ],
      ),
    );
  }

  // =========================
  // BULLET LIST
  // =========================
  List<Widget> _buildBulletList(dynamic items) {
    if (items is List) {
      return items.map<Widget>((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Icon(Icons.circle, size: 6, color: AppColors.golden),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(item.toString(), style: AppTextStyles.bodyLarge),
              ),
            ],
          ),
        );
      }).toList();
    }
    return [Text(items.toString(), style: AppTextStyles.bodyLarge)];
  }

  // =========================
  // NUMBERED LIST
  // =========================
  List<Widget> _buildNumberedList(dynamic items) {
    if (items is List) {
      return items.asMap().entries.map<Widget>((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.golden.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "${entry.key + 1}",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.golden,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.value.toString(),
                  style: AppTextStyles.bodyLarge,
                ),
              ),
            ],
          ),
        );
      }).toList();
    }
    return [Text(items.toString(), style: AppTextStyles.bodyLarge)];
  }

  // =========================
  // INFO BADGE
  // =========================
  Widget _infoBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Extension for AppTextStyles to allow copyWith on const styles
extension TextStyleExtension on TextStyle {
  TextStyle copyWith({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      color: color ?? this.color,
      fontSize: fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}
