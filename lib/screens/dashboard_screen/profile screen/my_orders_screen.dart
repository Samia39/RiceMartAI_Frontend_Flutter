// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/utils/themes.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy orders — replace with real API data
    final List<Map<String, dynamic>> orders = [
      {
        'id': '#ORD-001',
        'item': 'Basmati Rice 5kg',
        'date': 'Apr 20, 2026',
        'status': 'Delivered',
        'amount': 'PKR 1,200',
        'statusColor': AppColors.success,
      },
      {
        'id': '#ORD-002',
        'item': 'Super Kernel Rice 10kg',
        'date': 'Apr 22, 2026',
        'status': 'Processing',
        'amount': 'PKR 2,400',
        'statusColor': AppColors.warning,
      },
      {
        'id': '#ORD-003',
        'item': 'Brown Rice 2kg',
        'date': 'Apr 24, 2026',
        'status': 'Pending',
        'amount': 'PKR 650',
        'statusColor': AppColors.info,
      },
    ];

    return Scaffold(
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    Text('My Orders', style: AppTextStyles.heading3),
                  ],
                ),
              ),

              Expanded(
                child: orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 60, color: AppColors.darkGreen.withOpacity(0.3)),
                            const SizedBox(height: 12),
                            Text('No orders yet', style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: AppDecorations.card,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(order['id'], style: AppTextStyles.heading4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (order['statusColor'] as Color).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: (order['statusColor'] as Color).withOpacity(0.50),
                                        ),
                                      ),
                                      child: Text(
                                        order['status'],
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: order['statusColor'],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(order['item'], style: AppTextStyles.bodyLarge),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(order['date'], style: AppTextStyles.bodySmall),
                                    Text(
                                      order['amount'],
                                      style: AppTextStyles.label.copyWith(
                                        color: AppColors.golden,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}