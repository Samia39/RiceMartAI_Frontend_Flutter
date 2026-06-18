// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../core/utils/themes.dart';
import '../../core/services/shop_service.dart';
import '../../models/shop_model.dart';

class SellerShopScreen extends StatefulWidget {
  const SellerShopScreen({super.key});
  @override
  State<SellerShopScreen> createState() => _SellerShopScreenState();
}

class _SellerShopScreenState extends State<SellerShopScreen> {
  Shop? shop;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    loadMyShop();
  }

  Future<void> loadMyShop() async {
    setState(() => isLoading = true);
    try {
      print('🔍 Loading my shop...');
      shop = await ShopService.getMyShop();
      print('✅ Shop: ${shop?.name}');
    } catch (e) {
      print('❌ Error: $e');
      errorMsg = e.toString();
      shop = null;
    }
    setState(() => isLoading = false);
  }

  Color _statusColor(String status) {
    if (status == 'approved') return AppColors.success;
    if (status == 'rejected') return AppColors.error;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (shop == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined,
                size: 60,
                color: AppColors.darkGreen.withOpacity(0.35)),
            const SizedBox(height: 12),
            Text('Koi shop nahi mili',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.darkGreen.withOpacity(0.55),
                )),
            if (errorMsg != null) ...[
              const SizedBox(height: 8),
              Text(errorMsg!,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.error,
                  )),
            ],
            const SizedBox(height: 16),
            GestureDetector(
              onTap: loadMyShop,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cream.withOpacity(0.30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.borderGold.withOpacity(0.60)),
                ),
                child: const Text('Retry',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreen,
                    )),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text('My Shop',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                )),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cream.withOpacity(0.30),
                    border:
                        Border.all(color: AppColors.borderGold, width: 2),
                  ),
                  child: Icon(Icons.storefront,
                      size: 45, color: AppColors.darkGreen),
                ),
                const SizedBox(height: 10),
                Text(shop!.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    )),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor(shop!.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    shop!.status.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _statusColor(shop!.status),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _infoCard(Icons.person_outline, 'Owner',
              shop!.ownerName ?? 'N/A'),
          const SizedBox(height: 12),
          _infoCard(Icons.phone_outlined, 'Phone', shop!.phone ?? 'N/A'),
          const SizedBox(height: 12),
          _infoCard(Icons.location_on_outlined, 'Address',
              shop!.address ?? 'N/A'),
          const SizedBox(height: 12),
          _infoCard(Icons.info_outline, 'Description',
              shop!.description.isEmpty ? 'N/A' : shop!.description),
          const SizedBox(height: 24),

          if (shop!.status == 'pending')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.warning.withOpacity(0.40)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aap ki shop admin approve karne ka wait kar rahi hai.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (shop!.status == 'approved') ...[
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.cream.withOpacity(0.30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.borderGold.withOpacity(0.60)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.edit_outlined,
                        color: AppColors.darkGreen, size: 20),
                    SizedBox(width: 8),
                    Text('Edit Shop',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGreen,
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.delete_outline,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Delete Shop',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream.withOpacity(0.22),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.borderGold.withOpacity(0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 20, color: AppColors.darkGreen.withOpacity(0.65)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.darkGreen.withOpacity(0.60),
                    )),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGreen,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}