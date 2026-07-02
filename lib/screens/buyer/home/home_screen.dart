import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/utils/themes.dart';
import '../../../core/services/product_service.dart';
import '../../../routes/app_routes.dart';
import 'ai_detection_screen.dart';
import 'ai_recommendation_screen.dart';
import '../rice/all_rice_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> productList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final data = await ProductService().fetchAllProducts();
    setState(() {
      // only take first 15
      productList = data.take(15).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final userName = box.read("name") ?? "User";

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
                              Text(userName, style: AppTextStyles.heading2),
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

                  // ================= FEATURES TITLE =================
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

                  const SizedBox(height: 35),

                  // ================= PRODUCTS SECTION =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Products",
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.cream,
                        ),
                      ),
                      // SEE ALL BUTTON
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AllRiceScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cream.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.cream.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            "See All Products",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.cream,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ================= HORIZONTAL PRODUCT LIST =================
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : productList.isEmpty
                      ? Center(
                          child: Text(
                            "No products available",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.cream,
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 210,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: productList.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final product = productList[index];
                              return GestureDetector(
                                onTap: () {
                                  Get.toNamed(
                                    AppRoutes.riceDetails,
                                    arguments: product,
                                  );
                                },
                                child: Container(
                                  width: 155,
                                  decoration: BoxDecoration(
                                    color: AppColors.cream,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // PRODUCT IMAGE PLACEHOLDER
                                      Container(
                                        height: 100,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: AppColors.darkGreen
                                              .withOpacity(0.1),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(18),
                                              ),
                                        ),
                                        child: const Icon(
                                          Icons.rice_bowl,
                                          size: 48,
                                          color: AppColors.darkGreen,
                                        ),
                                      ),

                                      // PRODUCT INFO
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product["name"] ?? "",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles.heading4
                                                  .copyWith(fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              product["rice_category"]?["name"] ??
                                                  "",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                    color: Colors.grey[600],
                                                    fontSize: 11,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Rs ${product["price"]}/KG",
                                              style: AppTextStyles.heading4
                                                  .copyWith(
                                                    color: AppColors.darkGreen,
                                                    fontSize: 14,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                  const SizedBox(height: 30),
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
