// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/core/utils/themes.dart';
import '../../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ✅ Always initialized — never null
  String _name = 'John Doe';
  String _username = '@johndoe';
  String _email = 'john@example.com';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _name = prefs.getString('user_name') ?? 'John Doe';
      _username = prefs.getString('user_username') ?? '@johndoe';
      _email = prefs.getString('user_email') ?? 'john@example.com';
      _loading = false;
    });
  }

  // ✅ Safe helper — always returns a @-prefixed string
  String get _safeUsername =>
      (_username.isNotEmpty && _username.startsWith('@'))
      ? _username
      : '@$_username';

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.darkGreen)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.golden,
              foregroundColor: AppColors.cream,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cream.withOpacity(0.30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.40)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.darkGreen.withOpacity(0.70), size: 19),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.label),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.golden.withOpacity(0.75)
              : AppColors.cream.withOpacity(0.22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.golden
                : AppColors.borderGold.withOpacity(0.35),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.cream : AppColors.darkGreen,
              size: 19,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.label.copyWith(
                color: isActive ? AppColors.cream : AppColors.darkGreen,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: isActive
                  ? AppColors.cream.withOpacity(0.80)
                  : AppColors.darkGreen.withOpacity(0.40),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Show loader until prefs are ready — prevents null crash
    if (_loading) {
      return Scaffold(
        body: Container(
          decoration: AppDecorations.gradientBackground,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.golden),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────
                Text('Profile', style: AppTextStyles.heading1),
                const SizedBox(height: 2),
                Text(
                  'Manage your account information',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 20),

                // ── Profile Card ─────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: AppDecorations.card,
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.borderGold,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: AppColors.cream,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(_name, style: AppTextStyles.heading3),
                      const SizedBox(height: 2),
                      // ✅ Use safe getter — no more crash
                      Text(_safeUsername, style: AppTextStyles.bodySmall),
                      const SizedBox(height: 18),

                      // Info Fields
                      _buildInfoTile(
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        value: _name,
                      ),
                      _buildInfoTile(
                        icon: Icons.mail_outline,
                        label: 'Email/Phone',
                        value: _email,
                      ),
                      _buildInfoTile(
                        icon: Icons.alternate_email,
                        label: 'Username',
                        value: _safeUsername, // ✅ safe getter
                      ),

                      // Edit Profile
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.editProfile),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cream.withOpacity(0.30),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.borderGold.withOpacity(0.40),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: AppColors.darkGreen.withOpacity(0.70),
                                size: 19,
                              ),
                              const SizedBox(width: 12),
                              Text('Edit Profile', style: AppTextStyles.label),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.darkGreen.withOpacity(0.40),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── Account Settings ─────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: AppDecorations.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account Settings', style: AppTextStyles.heading4),
                      const SizedBox(height: 14),
                      _buildSettingsTile(
                        icon: Icons.receipt_long_outlined,
                        title: 'My Orders',
                        onTap: () => Get.toNamed(AppRoutes.myOrders),
                        isActive: true,
                      ),
                      _buildSettingsTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        onTap: () => Get.toNamed(AppRoutes.changepassword),
                      ),
                      _buildSettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notification Settings',
                        onTap: () => Get.toNamed(AppRoutes.notification),
                      ),
                      _buildSettingsTile(
                        icon: Icons.security_outlined,
                        title: 'Privacy & Security',
                        onTap: () => Get.toNamed(AppRoutes.privacySecurity),
                      ),
                      _buildSettingsTile(
                        icon: Icons.feedback_outlined,
                        title: 'Feedback',
                        onTap: () => Get.toNamed(AppRoutes.feedback),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── Logout Button ─────────────────────────────
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.golden.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.golden),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: AppColors.cream, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.cream,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
