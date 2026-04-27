// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/utils/themes.dart';

class CartItem {
  final String id;
  final String name;
  final String weight;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.weight,
    required this.price,
    this.quantity = 1,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Dummy cart items — replace with GetX controller / real data
  final List<CartItem> _items = [
    CartItem(id: '1', name: 'Basmati Rice', weight: '5kg', price: 1200),
    CartItem(id: '2', name: 'Super Kernel Rice', weight: '10kg', price: 2400),
    CartItem(id: '3', name: 'Brown Rice', weight: '2kg', price: 650),
  ];

  double get _subtotal =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);
  double get _shipping => _items.isEmpty ? 0 : 150;
  double get _total => _subtotal + _shipping;

  void _increment(CartItem item) => setState(() => item.quantity++);
  void _decrement(CartItem item) {
    if (item.quantity > 1) {
      setState(() => item.quantity--);
    } else {
      _remove(item);
    }
  }

  void _remove(CartItem item) {
    setState(() => _items.remove(item));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppDecorations.iconButton,
                        child: const Icon(Icons.arrow_back_ios_new, size: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('My Cart', style: AppTextStyles.heading3),
                    const Spacer(),
                    Text(
                      '${_items.length} items',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: AppColors.darkGreen.withOpacity(0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your cart is empty',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Dismissible(
                            key: Key(item.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _remove(item),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: AppDecorations.card,
                              child: Row(
                                children: [
                                  // Icon placeholder
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGreen.withOpacity(
                                        0.30,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.grain,
                                      color: AppColors.darkGreen,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: AppTextStyles.heading4,
                                        ),
                                        Text(
                                          item.weight,
                                          style: AppTextStyles.bodySmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'PKR ${(item.price * item.quantity).toStringAsFixed(0)}',
                                          style: AppTextStyles.label.copyWith(
                                            color: AppColors.golden,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Quantity
                                  Row(
                                    children: [
                                      _qtyButton(
                                        icon: Icons.remove,
                                        onTap: () => _decrement(item),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Text(
                                          '${item.quantity}',
                                          style: AppTextStyles.label,
                                        ),
                                      ),
                                      _qtyButton(
                                        icon: Icons.add,
                                        onTap: () => _increment(item),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Summary
              if (_items.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.cream.withOpacity(0.25),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.borderGold.withOpacity(0.40),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      _summaryRow(
                        'Subtotal',
                        'PKR ${_subtotal.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 6),
                      _summaryRow(
                        'Shipping',
                        'PKR ${_shipping.toStringAsFixed(0)}',
                      ),
                      Divider(color: AppColors.divider, height: 18),
                      _summaryRow(
                        'Total',
                        'PKR ${_total.toStringAsFixed(0)}',
                        bold: true,
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () {
                          Get.snackbar(
                            'Order Placed!',
                            'Your order has been placed successfully.',
                            backgroundColor: AppColors.cream.withOpacity(0.95),
                            colorText: AppColors.darkGreen,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        child: const Text('Proceed to Checkout'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.cream.withOpacity(0.35),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderGold.withOpacity(0.50)),
        ),
        child: Icon(icon, size: 15, color: AppColors.darkGreen),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: bold ? AppTextStyles.heading4 : AppTextStyles.bodyLarge,
        ),
        Text(
          value,
          style: bold
              ? AppTextStyles.heading4.copyWith(color: AppColors.golden)
              : AppTextStyles.bodyLarge,
        ),
      ],
    );
  }
}
