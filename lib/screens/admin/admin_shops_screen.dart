// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/themes.dart';
import '../../core/services/shop_service.dart';
import '../../models/shop_model.dart';

class AdminShopsScreen extends StatefulWidget {
  const AdminShopsScreen({super.key});
  @override
  State<AdminShopsScreen> createState() => _AdminShopsScreenState();
}

class _AdminShopsScreenState extends State<AdminShopsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Shop> allShops = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // argument se initial tab set karo
    final arg = Get.arguments as String?;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: arg == 'approved' ? 1 : 0,
    );
    loadShops();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadShops() async {
    setState(() => isLoading = true);
    try {
      allShops = await ShopService.getAdminShops();
    } catch (e) {
      allShops = [];
    }
    setState(() => isLoading = false);
  }

  Future<void> updateStatus(int id, String status) async {
    final success = await ShopService.updateStatus(id, status);
    if (success) {
      loadShops();
      Get.snackbar('Success', 'Shop $status!',
          backgroundColor: AppColors.cream);
    }
  }

  List<Shop> getFiltered(String status) =>
      allShops.where((s) => s.status == status).toList();

  @override
  Widget build(BuildContext context) {
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
                        child: Text('Seller Approvals',
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

              // ── Tabs ─────────────────────────────────────
              TabBar(
                controller: _tabController,
                labelColor: AppColors.darkGreen,
                unselectedLabelColor:
                    AppColors.darkGreen.withOpacity(0.45),
                labelStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                indicatorColor: AppColors.darkGreen,
                indicatorWeight: 2.5,
                dividerColor: AppColors.darkGreen.withOpacity(0.15),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Pending'),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${getFiltered('pending').length}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Tab(text: 'Approved'),
                ],
              ),

              // ── Tab Content ──────────────────────────────
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList('pending'),
                          _buildList('approved'),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(String status) {
    final shops = getFiltered(status);

    if (shops.isEmpty) {
      return Center(
        child: Text('No $status shops',
            style: AppTextStyles.bodyLarge),
      );
    }

    return RefreshIndicator(
      onRefresh: loadShops,
      child: ListView.builder(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: shops.length,
        itemBuilder: (ctx, i) => _shopCard(shops[i]),
      ),
    );
  }

  Widget _shopCard(Shop shop) {
    return GestureDetector(
      onTap: () => Get.toNamed('/admin-shop-detail', arguments: shop),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shop.name, style: AppTextStyles.heading4),
            const SizedBox(height: 4),
            Text('Owner: ${shop.ownerName ?? "N/A"}',
                style: AppTextStyles.bodySmall),
            Text('CNIC: ${shop.cnicNumber ?? "N/A"}',
                style: AppTextStyles.bodySmall),
            Text('Phone: ${shop.phone ?? "N/A"}',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () =>
                    Get.toNamed('/admin-shop-detail', arguments: shop),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cream.withOpacity(0.30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.borderGold.withOpacity(0.60)),
                  ),
                  child: const Center(
                    child: Text('View Details',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGreen,
                        )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}