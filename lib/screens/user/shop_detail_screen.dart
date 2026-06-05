// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/themes.dart';
import '../../core/services/shop_service.dart';
import '../../models/shop_model.dart';
import '../../models/product_model.dart';
import '../../widgets/bottom_nav.dart';

class ShopDetailScreen extends StatefulWidget {
  const ShopDetailScreen({super.key});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  Shop? shop;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final id = Get.arguments as int;
    loadShop(id);
  }

  Future<void> loadShop(int id) async {
    setState(() => isLoading = true);
    shop = await ShopService.getShop(id);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : shop == null
                  ? Center(
                      child: Text('Shop nahi mili',
                          style: AppTextStyles.bodyLarge))
                  : Column(
                      children: [
                        // ── Header ────────────────────────
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: AppDecorations.iconButton,
                                  child: Icon(Icons.arrow_back,
                                      color: AppColors.darkGreen,
                                      size: 24),
                                ),
                              ),
                              Text('Marketplace',
                                  style: AppTextStyles.heading3),
                              GestureDetector(
                                onTap: () => Get.toNamed('/cart'),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: AppDecorations.iconButton,
                                  child: Icon(Icons.shopping_cart_outlined,
                                      color: AppColors.darkGreen, size: 24),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Shop Info Card ─────────
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: AppDecorations.card,
                                  child: Row(
                                    children: [
                                      // Logo
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: shop!.logo != null
                                            ? Image.network(
                                                'http://10.0.2.2/sheezabackend/public/storage/${shop!.logo}',
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (_, __, ___) =>
                                                        _noLogo(),
                                              )
                                            : _noLogo(),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(shop!.name,
                                                style:
                                                    AppTextStyles.heading3),
                                            if (shop!.address != null)
                                              Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .location_on_outlined,
                                                      size: 14,
                                                      color:
                                                          AppColors.iconMuted),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                        shop!.address!,
                                                        style: AppTextStyles
                                                            .bodySmall),
                                                  ),
                                                ],
                                              ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${shop!.products.length} Products',
                                              style: AppTextStyles.label
                                                  .copyWith(
                                                      color:
                                                          AppColors.golden),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Description
                                if (shop!.description.isNotEmpty)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: AppDecorations.card,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('About Shop',
                                            style: AppTextStyles.heading4),
                                        const SizedBox(height: 8),
                                        Text(shop!.description,
                                            style: AppTextStyles.bodyLarge),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 16),

                                // ── Products ───────────────
                                Text('Products',
                                    style: AppTextStyles.heading3),
                                const SizedBox(height: 12),

                                shop!.products.isEmpty
                                    ? Center(
                                        child: Text('Koi product nahi',
                                            style:
                                                AppTextStyles.bodyLarge),
                                      )
                                    : GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          childAspectRatio: 0.75,
                                        ),
                                        itemCount: shop!.products.length,
                                        itemBuilder: (ctx, i) {
                                          final p = shop!.products[i];
                                          return GestureDetector(
                                            onTap: () => Get.toNamed(
                                                '/product-detail',
                                                arguments: p),
                                            child: Container(
                                              decoration:
                                                  AppDecorations.card,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      16)),
                                                      child: p.image != null
                                                          ? Image.network(
                                                              'http://10.0.2.2/sheezabackend/public/storage/${p.image}',
                                                              width: double
                                                                  .infinity,
                                                              fit: BoxFit
                                                                  .cover,
                                                              errorBuilder:
                                                                  (_, __,
                                                                          ___) =>
                                                                      _noProductImage(),
                                                            )
                                                          : _noProductImage(),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(p.name,
                                                            style: AppTextStyles
                                                                .heading4,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                        Text(
                                                            'Rs. ${p.price}',
                                                            style: AppTextStyles
                                                                .label
                                                                .copyWith(
                                                                    color: AppColors
                                                                        .golden)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
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

  Widget _noLogo() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.store, size: 35, color: AppColors.darkGreen),
    );
  }

  Widget _noProductImage() {
    return Container(
      color: AppColors.cardFill,
      child: Icon(Icons.rice_bowl, size: 40, color: AppColors.darkGreen),
    );
  }
}