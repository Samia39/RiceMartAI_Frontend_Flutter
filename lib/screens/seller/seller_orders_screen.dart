// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../core/utils/themes.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});
  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 12),
          child: Text('Seller Orders',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              )),
        ),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.darkGreen,
          unselectedLabelColor: AppColors.darkGreen.withOpacity(0.45),
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          indicatorColor: AppColors.darkGreen,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: AppColors.darkGreen.withOpacity(0.15),
          tabs: const [
            Tab(text: 'Active Orders'),
            Tab(text: 'History'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildActiveOrders(),
              _buildHistory(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveOrders() {
    final orders = []; // ← Khali
    if (orders.isEmpty) return _emptyState('No active orders');
    return const SizedBox();
  }

  Widget _buildHistory() {
    final orders = []; // ← Khali
    if (orders.isEmpty) return _emptyState('No order history');
    return const SizedBox();
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 60,
              color: AppColors.darkGreen.withOpacity(0.35)),
          const SizedBox(height: 12),
          Text(msg,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.darkGreen.withOpacity(0.55),
              )),
        ],
      ),
    );
  }
}