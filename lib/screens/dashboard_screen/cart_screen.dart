// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/utils/themes.dart';
import '/core/services/dashboard_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CartController cart = Get.find<CartController>();
    return Scaffold(
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.darkGreen,
                      ),
                      onPressed: () => Get.back(),
                    ),
                    const Expanded(
                      child: Text(
                        'My Cart',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading3,
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (cart.items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 72,
                            color: AppColors.darkGreen.withOpacity(0.25),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Your cart is empty',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              'Browse Products',
                              style: AppTextStyles.label.copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.darkGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(18),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: AppDecorations.card,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Image.asset(
                                    item.product.imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.cream.withOpacity(0.4),
                                      child: const Icon(
                                        Icons.grain,
                                        size: 28,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: AppTextStyles.heading4,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.product.shop,
                                      style: AppTextStyles.bodySmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rs ${item.product.price.toStringAsFixed(0)}/kg',
                                      style: AppTextStyles.label.copyWith(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      _QBtn(
                                        icon: Icons.remove,
                                        onTap: () => cart.decrement(item),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Text(
                                          '${item.qty}',
                                          style: AppTextStyles.label,
                                        ),
                                      ),
                                      _QBtn(
                                        icon: Icons.add,
                                        onTap: () => cart.increment(item),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () => cart.remove(item.product),
                                    child: Text(
                                      'Remove',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.error,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              Obx(() {
                if (cart.items.isEmpty) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.cardFill,
                    border: Border(
                      top: BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total (${cart.totalCount} items)',
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            'Rs ${cart.totalPrice.toStringAsFixed(0)}',
                            style: AppTextStyles.heading4,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Get.snackbar(
                            'Order Placed',
                            'Your order has been placed!',
                            snackPosition: SnackPosition.BOTTOM,
                          ),
                          style: AppButtonStyles.primary,
                          child: const Text(
                            'Proceed to Checkout',
                            style: AppTextStyles.button,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.overlayLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
      ),
      child: Icon(icon, size: 16, color: AppColors.darkGreen),
    ),
  );
} // TODO Implement this library.

// TODO Implement this library.
