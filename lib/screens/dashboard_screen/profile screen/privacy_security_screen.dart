// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/utils/themes.dart';

import '../../../routes/app_routes.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _twoFactor = false;
  bool _loginAlerts = true;
  bool _dataSharing = false;

  Widget _buildSwitchTile({
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

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
            Text(title, style: AppTextStyles.label),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: AppColors.darkGreen.withOpacity(0.40),
              size: 18,
            ),
          ],
        ),
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
                    Text('Privacy & Security', style: AppTextStyles.heading3),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Security', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 10),
                      _buildSwitchTile(
                        icon: Icons.verified_user_outlined,
                        title: 'Two-Factor Authentication',
                        subtitle: 'Add extra security to your account',
                        value: _twoFactor,
                        onChanged: (v) => setState(() => _twoFactor = v),
                      ),
                      _buildSwitchTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'Login Alerts',
                        subtitle: 'Get notified on new sign-ins',
                        value: _loginAlerts,
                        onChanged: (v) => setState(() => _loginAlerts = v),
                      ),
                      const SizedBox(height: 16),
                      Text('Privacy', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 10),
                      _buildSwitchTile(
                        icon: Icons.share_outlined,
                        title: 'Data Sharing',
                        subtitle: 'Share analytics to improve the app',
                        value: _dataSharing,
                        onChanged: (v) => setState(() => _dataSharing = v),
                      ),
                      _buildNavTile(
                        icon: Icons.description_outlined,
                        title: 'Privacy Policy',
                        onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
                      ),
                      _buildNavTile(
                        icon: Icons.article_outlined,
                        title: 'Terms of Service',
                        onTap: () => Get.toNamed(AppRoutes.terms),
                      ),
                      _buildNavTile(
                        icon: Icons.delete_outline,
                        title: 'Delete Account',
                        onTap: () {
                          Get.snackbar(
                            'Delete Account',
                            'Please contact support to delete your account.',
                            backgroundColor: AppColors.cream.withOpacity(0.95),
                            colorText: AppColors.error,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
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
} // TODO Implement this library.
