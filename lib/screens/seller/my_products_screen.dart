// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/themes.dart';
import '../../core/services/product_service.dart';
import '../../models/product_model.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() => isLoading = true);
    products = await ProductService.getMyProducts();
    setState(() => isLoading = false);
  }

  Future<void> deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: Text('Delete Product', style: AppTextStyles.heading3),
        content: Text('Kya aap sure hain?', style: AppTextStyles.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: AppTextStyles.label),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: AppTextStyles.label.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ProductService.deleteProduct(id);
      if (success) {
        loadProducts();
        Get.snackbar('Success', 'Product delete ho gaya!',
            backgroundColor: AppColors.cream);
      }
    }
  }

  Color _statusColor(String status) {
    if (status == 'approved') return AppColors.success;
    if (status == 'rejected') return AppColors.error;
    return AppColors.warning;
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
                        Text('Seller Panel',
                            style: AppTextStyles.bodyMedium),
                        Text('My Products', style: AppTextStyles.heading3),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed('/add-product'),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppDecorations.iconButton,
                        child: Icon(Icons.add,
                            color: AppColors.darkGreen, size: 24),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Product List ─────────────────────────────────
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : products.isEmpty
                        ? Center(
                            child: Text('Koi product nahi hai',
                                style: AppTextStyles.bodyLarge),
                          )
                        : RefreshIndicator(
                            onRefresh: loadProducts,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              itemCount: products.length,
                              itemBuilder: (ctx, i) {
                                final p = products[i];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: AppDecorations.card,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: p.image != null
                                          ? Image.network(
                                              'http://10.0.2.2/sheezabackend/public/storage/${p.image}',
                                              width: 55,
                                              height: 55,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _noImage(),
                                            )
                                          : _noImage(),
                                    ),
                                    title: Text(p.name,
                                        style: AppTextStyles.heading4),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Rs. ${p.price}',
                                            style: AppTextStyles.bodyMedium),
                                        Text('Stock: ${p.stock}',
                                            style: AppTextStyles.bodySmall),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _statusColor(p.status)
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            p.status.toUpperCase(),
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                    color: _statusColor(
                                                        p.status),
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: AppColors.golden),
                                          onPressed: () => Get.toNamed(
                                              '/edit-product',
                                              arguments: p),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: AppColors.error),
                                          onPressed: () =>
                                              deleteProduct(p.id),
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
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.rice_bowl, color: AppColors.darkGreen),
    );
  }
}