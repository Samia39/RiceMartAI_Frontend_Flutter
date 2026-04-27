// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/core/utils/themes.dart';
import '../../../routes/app_routes.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? '';
      _usernameController.text = prefs.getString('user_username') ?? '';
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Validation',
        'Name cannot be empty',
        backgroundColor: AppColors.golden.withOpacity(0.90),
        colorText: AppColors.cream,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_username', username);

    if (!mounted) return;
    setState(() => _isSaving = false);

    Get.snackbar(
      'Success',
      'Profile updated successfully',
      backgroundColor: AppColors.cream.withOpacity(0.95),
      colorText: AppColors.darkGreen,
      snackPosition: SnackPosition.BOTTOM,
    );

    // ✅ Go back to dashboard (profile tab) — NOT Get.back() which can
    //    mis-navigate to login when the route stack is managed by GetX tabs.
    await Future.delayed(const Duration(milliseconds: 600));
    Get.offAllNamed(AppRoutes.dashboard);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 6),
        Container(
          decoration: AppDecorations.inputField,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Icon(icon, color: AppColors.iconMuted, size: 18),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: AppTextStyles.bodyLarge,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    hintText: label,
                    hintStyle: AppTextStyles.hint,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
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
              // ── AppBar ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      // ✅ Same safe navigation on back arrow
                      onTap: () => Get.offAllNamed(AppRoutes.dashboard),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppDecorations.iconButton,
                        child: const Icon(Icons.arrow_back_ios_new, size: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Edit Profile', style: AppTextStyles.heading3),
                  ],
                ),
              ),

              // ── Body ─────────────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.golden,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            // Avatar
                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
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
                                      size: 40,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.golden,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: AppColors.cream,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            _buildField(
                              'Full Name',
                              _nameController,
                              Icons.person_outline,
                            ),
                            _buildField(
                              'Username',
                              _usernameController,
                              Icons.alternate_email,
                            ),
                            const SizedBox(height: 8),

                            // Save button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.golden,
                                  foregroundColor: AppColors.cream,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isSaving ? null : _save,
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Save Changes',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                              ),
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
