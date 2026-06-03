// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/themes.dart';
import '../../core/services/product_service.dart';
import '../../models/product_model.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav.dart';

class UserProductsScreen extends StatefulWidget {
  const UserProductsScreen({super.key});

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  List<Product> products = [];
  List<Product> filtered = [];
  bool isLoading = true;
  String search = '';

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() => isLoading = true);
    products = await ProductService.getAllProducts();
    filtered = products;
    setState(() => isLoading = false);
  }

  void searchProducts(String query) {
    setState(() {
      search = query;
      filtered = products
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
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
                    Builder(
                      builder: (ctx) => GestureDetector(
                        onTap: () => Scaffold.of(ctx).openDrawer(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: AppDecorations.iconButton,
                          child: Icon(Icons.menu,
                              color: AppColors.darkGreen, size: 24),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text('Rice Mart', style: AppTextStyles.bodyMedium),
                        Text('Products', style: AppTextStyles.heading3),
                      ],
                    ),
                    Icon(Icons.shopping_cart,
                        color: AppColors.golden, size: 28),
                  ],
                ),
              ),

              // ── Search Bar ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: AppDecorations.inputField,
                  child: TextField(
                    onChanged: searchProducts,
                    style: AppTextStyles.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: AppTextStyles.hint,
                      prefixIcon:
                          Icon(Icons.search, color: AppColors.iconMuted),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Product Grid ─────────────────────────────────
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? Center(
                            child: Text('Koi product nahi mila',
                                style: AppTextStyles.bodyLarge),
                          )
                        : RefreshIndicator(
                            onRefresh: loadProducts,
                            child: GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) {
                                final p = filtered[i];
                                return GestureDetector(
                                  onTap: () => Get.toNamed(
                                      '/product-detail',
                                      arguments: p),
                                  child: Container(
                                    decoration: AppDecorations.card,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Image
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(16)),
                                            child: p.image != null
                                                ? Image.network(
                                                    'http://10.0.2.2/sheezabackend/public/storage/${p.image}',
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            _noImage(),
                                                  )
                                                : _noImage(),
                                          ),
                                        ),
                                        // Info
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(p.name,
                                                  style:
                                                      AppTextStyles.heading4,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                              Text(p.category.toUpperCase(),
                                                  style:
                                                      AppTextStyles.bodySmall),
                                              Text('Rs. ${p.price}',
                                                  style: AppTextStyles.label
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
      color: AppColors.cardFill,
      child: Icon(Icons.rice_bowl, size: 40, color: AppColors.darkGreen),
    );
  }
}