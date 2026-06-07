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
        // ── Title ────────────────────────────────────────
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

        // ── Tabs — underline style ────────────────────────
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

        // ── Tab Content ──────────────────────────────────
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
    final orders = [
      {
        'id': '#ORD-001',
        'customer': 'Ali Hassan',
        'items': '2x Basmati Rice 5kg',
        'total': 'Rs. 2,400',
        'status': 'Pending',
        'time': '10 min ago',
      },
      {
        'id': '#ORD-002',
        'customer': 'Sara Khan',
        'items': '1x Brown Rice 2kg',
        'total': 'Rs. 800',
        'status': 'Processing',
        'time': '25 min ago',
      },
    ];

    if (orders.isEmpty) return _emptyState('No active orders');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: orders.length,
      itemBuilder: (ctx, i) => _orderCard(orders[i], isActive: true),
    );
  }

  Widget _buildHistory() {
    final orders = [
      {
        'id': '#ORD-000',
        'customer': 'Ahmed Raza',
        'items': '3x White Rice 10kg',
        'total': 'Rs. 5,100',
        'status': 'Delivered',
        'time': '2 days ago',
      },
    ];

    if (orders.isEmpty) return _emptyState('No order history');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: orders.length,
      itemBuilder: (ctx, i) => _orderCard(orders[i], isActive: false),
    );
  }

  Widget _orderCard(Map order, {required bool isActive}) {
    final statusColor = order['status'] == 'Pending'
        ? AppColors.warning
        : order['status'] == 'Processing'
            ? AppColors.info
            : AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cream.withOpacity(0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID + Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order['id']!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    )),
                Text(order['time']!,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.darkGreen.withOpacity(0.55),
                    )),
              ],
            ),
            const SizedBox(height: 6),

            // Customer
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 14,
                    color: AppColors.darkGreen.withOpacity(0.65)),
                const SizedBox(width: 6),
                Text(order['customer']!,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.darkGreen.withOpacity(0.85),
                    )),
              ],
            ),
            const SizedBox(height: 4),

            // Items
            Row(
              children: [
                Icon(Icons.rice_bowl_outlined,
                    size: 14,
                    color: AppColors.darkGreen.withOpacity(0.65)),
                const SizedBox(width: 6),
                Text(order['items']!,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.darkGreen.withOpacity(0.85),
                    )),
              ],
            ),
            const SizedBox(height: 10),

            // Total + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order['total']!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.golden,
                    )),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(order['status']!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      )),
                ),
              ],
            ),

            // Accept / Reject buttons
            if (isActive) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.success.withOpacity(0.40)),
                        ),
                        child: const Center(
                          child: Text('Accept',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
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
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.error.withOpacity(0.40)),
                        ),
                        child: const Center(
                          child: Text('Reject',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              )),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
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