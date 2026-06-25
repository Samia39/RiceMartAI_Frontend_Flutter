// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../core/utils/themes.dart';
import '../../core/services/product_service.dart';
import '../../models/product_model.dart';
import 'add_product_screen.dart';

class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});
  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  List<ProductModel> products = [];
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
        title: const Text('Delete Product',
            style: TextStyle(fontFamily: 'Poppins')),
        content: const Text('Kya aap sure hain?',
            style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Delete',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ProductService.deleteProduct(id);
      if (success) loadProducts();
    }
  }

  Color _statusColor(String status) {
    if (status == 'approved') return AppColors.success;
    if (status == 'rejected') return AppColors.error;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Rice Products',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  )),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddProductScreen()),
                  );
                  loadProducts();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: AppDecorations.iconButton,
                  child: Icon(Icons.add,
                      color: AppColors.darkGreen, size: 22),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rice_bowl_outlined,
                              size: 60,
                              color: AppColors.darkGreen.withOpacity(0.35)),
                          const SizedBox(height: 12),
                          Text('Koi product nahi — (+) se add karo',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: AppColors.darkGreen.withOpacity(0.55),
                              )),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadProducts,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                                        'http://127.0.0.1:8000/storage/${p.image}',
                                        width: 55,
                                        height: 55,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _noImage(),
                                      )
                                    : _noImage(),
                              ),
                              title: Text(p.name,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkGreen,
                                  )),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rs. ${p.price}',
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                          color: AppColors.darkGreen
                                              .withOpacity(0.85))),
                                  Text('Stock: ${p.stock} kg',
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: AppColors.darkGreen
                                              .withOpacity(0.65))),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _statusColor(p.status)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      p.status.toUpperCase(),
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: _statusColor(p.status)),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete,
                                    color: AppColors.error),
                                onPressed: () => deleteProduct(p.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
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