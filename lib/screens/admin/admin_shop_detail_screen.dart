// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/themes.dart';
import '../../core/services/shop_service.dart';
import '../../models/shop_model.dart';

class AdminShopDetailScreen extends StatelessWidget {
  const AdminShopDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Shop shop = Get.arguments as Shop;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppDecorations.iconButton,
                        child: Icon(Icons.arrow_back,
                            color: AppColors.darkGreen, size: 22),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text('Seller Verification',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            )),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Shop Status Card ──────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppDecorations.card,
                        child: Row(
                          children: [
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.darkGreen.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.store,
                                  color: AppColors.darkGreen, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(shop.name,
                                    style: AppTextStyles.heading4),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: shop.status == 'approved'
                                        ? AppColors.success.withOpacity(0.15)
                                        : shop.status == 'rejected'
                                            ? AppColors.error.withOpacity(0.15)
                                            : AppColors.warning.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    shop.status.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: shop.status == 'approved'
                                          ? AppColors.success
                                          : shop.status == 'rejected'
                                              ? AppColors.error
                                              : AppColors.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Seller Information ────────────────
                      Text('Seller Information',
                          style: AppTextStyles.heading3),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppDecorations.card,
                        child: Column(
                          children: [
                            _infoRow('Owner', shop.ownerName ?? 'N/A'),
                            _divider(),
                            _infoRow('CNIC', shop.cnicNumber ?? 'N/A'),
                            _divider(),
                            _infoRow('Phone', shop.phone ?? 'N/A'),
                            _divider(),
                            _infoRow('Address', shop.address ?? 'N/A'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Shop Information ──────────────────
                      Text('Shop Information',
                          style: AppTextStyles.heading3),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppDecorations.card,
                        child: Column(
                          children: [
                            _infoRow('Shop Name', shop.name),
                            _divider(),
                            _infoRow('Description',
                                shop.description.isEmpty
                                    ? 'N/A'
                                    : shop.description),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── CNIC Document ─────────────────────
                      Text('CNIC Document',
                          style: AppTextStyles.heading3),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: AppDecorations.card,
                        child: shop.cnicImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  'http://127.0.0.1:8000/storage/${shop.cnicImage}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _noCnicImage(),
                                ),
                              )
                            : _noCnicImage(),
                      ),
                      const SizedBox(height: 24),

                      // ── Action Buttons ────────────────────
                      if (shop.status == 'pending') ...[
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final success =
                                      await ShopService.updateStatus(
                                          shop.id, 'approved');
                                  if (success) {
                                    Get.snackbar('Success',
                                        'Shop approved!',
                                        backgroundColor: AppColors.cream);
                                    Get.back();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.success.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppColors.success
                                            .withOpacity(0.40)),
                                  ),
                                  child: const Center(
                                    child: Text('Approve',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.success,
                                        )),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.cream.withOpacity(0.30),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppColors.borderGold
                                            .withOpacity(0.60)),
                                  ),
                                  child: const Center(
                                    child: Text('Correction',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.darkGreen,
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            final success = await ShopService.updateStatus(
                                shop.id, 'rejected');
                            if (success) {
                              Get.snackbar(
                                  'Done', 'Shop rejected.',
                                  backgroundColor: AppColors.cream);
                              Get.back();
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.error.withOpacity(0.40)),
                            ),
                            child: const Center(
                              child: Text('Reject',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.error,
                                  )),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.darkGreen.withOpacity(0.60),
                )),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGreen,
                )),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
      color: AppColors.darkGreen.withOpacity(0.10), thickness: 1);

  Widget _noCnicImage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined,
              size: 40, color: AppColors.darkGreen.withOpacity(0.35)),
          const SizedBox(height: 8),
          Text('No CNIC image',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.darkGreen.withOpacity(0.55),
              )),
        ],
      ),
    );
  }
}