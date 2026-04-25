// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/utils/themes.dart';


class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _newArrivals = true;
  bool _priceDrops = false;
  bool _chatMessages = true;

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withOpacity(0.30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.darkGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppDecorations.iconButton,
                        child:
                            const Icon(Icons.arrow_back_ios_new, size: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Notification Settings',
                        style: AppTextStyles.heading3),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Orders', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 10),
                      _buildTile(
                        icon: Icons.receipt_long_outlined,
                        title: 'Order Updates',
                        subtitle: 'Status changes for your orders',
                        value: _orderUpdates,
                        onChanged: (v) =>
                            setState(() => _orderUpdates = v),
                      ),
                      const SizedBox(height: 16),
                      Text('Discover', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 10),
                      _buildTile(
                        icon: Icons.local_offer_outlined,
                        title: 'Promotions',
                        subtitle: 'Deals and special offers',
                        value: _promotions,
                        onChanged: (v) =>
                            setState(() => _promotions = v),
                      ),
                      _buildTile(
                        icon: Icons.new_releases_outlined,
                        title: 'New Arrivals',
                        subtitle: 'Fresh stock and new products',
                        value: _newArrivals,
                        onChanged: (v) =>
                            setState(() => _newArrivals = v),
                      ),
                      _buildTile(
                        icon: Icons.trending_down_outlined,
                        title: 'Price Drops',
                        subtitle: 'When items in your wishlist drop in price',
                        value: _priceDrops,
                        onChanged: (v) =>
                            setState(() => _priceDrops = v),
                      ),
                      const SizedBox(height: 16),
                      Text('Communication',
                          style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 10),
                      _buildTile(
                        icon: Icons.chat_bubble_outline,
                        title: 'Chat Messages',
                        subtitle: 'New messages from support',
                        value: _chatMessages,
                        onChanged: (v) =>
                            setState(() => _chatMessages = v),
                      ),
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
}