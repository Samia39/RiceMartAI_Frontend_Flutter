import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_repo/screens/login%20screen/privacy_policy_screen.dart';

import 'change_password_screen.dart';
import 'notification_settings_screen.dart';

// ─────────────────────────────────────────────
//  COLOR PALETTE (same as dashboard)
// ─────────────────────────────────────────────
class _C {
  static const darkGreen = Color(0xFF1A2820);
  static const lightGreen = Color(0xFF5A8A6E);
  static const golden = Color(0xFF9D7E3F);
  static const cream = Color(0xFFD4C9A8);
  static const border = Color(0xFFB8A97A);
}

// ─────────────────────────────────────────────
//  PROFILE SCREEN
// ─────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GetStorage _box = GetStorage();

  String get _name => _box.read('userName') ?? 'John Doe';
  String get _email => _box.read('userEmail') ?? 'john@example.com';
  String get _username => _box.read('userHandle') ?? '@johndoe';

  // ── section card wrapper ──────────────────
  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    decoration: BoxDecoration(
      color: _C.cream.withOpacity(0.22),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _C.border.withOpacity(0.45)),
      boxShadow: [
        BoxShadow(
          color: _C.darkGreen.withOpacity(0.07),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );

  // ── info row ──────────────────────────────
  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    bool showDivider = true,
  }) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _C.darkGreen.withOpacity(0.7)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: _C.darkGreen.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _C.darkGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      if (showDivider)
        Divider(
          height: 1,
          thickness: 1,
          color: _C.border.withOpacity(0.25),
          indent: 16,
          endIndent: 16,
        ),
    ],
  );

  // ── settings tile ─────────────────────────
  Widget _settingsTile({
    required IconData icon,
    required String label,
    bool showDivider = true,
    VoidCallback? onTap,
  }) => Column(
    children: [
      InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 18, color: _C.darkGreen.withOpacity(0.75)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _C.darkGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 13,
                color: _C.darkGreen.withOpacity(0.45),
              ),
            ],
          ),
        ),
      ),
      if (showDivider)
        Divider(
          height: 1,
          thickness: 1,
          color: _C.border.withOpacity(0.25),
          indent: 16,
          endIndent: 16,
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarRadius = (screenWidth * 0.13).clamp(42.0, 58.0);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _C.darkGreen,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Manage your account information',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _C.darkGreen.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Avatar + Name card ─────────────────
            _card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    // Avatar circle
                    Container(
                      width: avatarRadius * 2,
                      height: avatarRadius * 2,
                      decoration: BoxDecoration(
                        color: _C.lightGreen.withOpacity(0.45),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _C.border.withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        size: avatarRadius * 1.1,
                        color: _C.darkGreen.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _C.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _username,
                      style: TextStyle(
                        fontSize: 13,
                        color: _C.darkGreen.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info rows inside avatar card
                    Divider(
                      height: 1,
                      color: _C.border.withOpacity(0.3),
                      indent: 16,
                      endIndent: 16,
                    ),
                    _infoRow(
                      icon: Icons.person_outline,
                      label: 'Full Name',
                      value: _name,
                    ),
                    _infoRow(
                      icon: Icons.mail_outline,
                      label: 'Email/Phone',
                      value: _email,
                    ),
                    _infoRow(
                      icon: Icons.phone_outlined,
                      label: 'Username',
                      value: _username,
                      showDivider: false,
                    ),

                    // Edit Profile
                    Divider(
                      height: 1,
                      color: _C.border.withOpacity(0.3),
                      indent: 16,
                      endIndent: 16,
                    ),
                    InkWell(
                      onTap: () => _showEditDialog(context),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: _C.darkGreen.withOpacity(0.75),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _C.darkGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 13,
                              color: _C.darkGreen.withOpacity(0.45),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Account Settings ───────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
              child: Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _C.darkGreen.withOpacity(0.7),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            _card(
              child: Column(
                children: [
                  _settingsTile(
                    icon: Icons.lock_outline,
                    label: 'Change Password',
                    onTap: () => Get.to(() => const ChangePasswordScreen()),
                  ),
                  _settingsTile(
                    icon: Icons.notifications_outlined,
                    label: 'Notification Settings',
                    onTap: () =>
                        Get.to(() => const NotificationSettingsScreen()),
                  ),
                  _settingsTile(
                    icon: Icons.shield_outlined,
                    label: 'Privacy & Security',
                    showDivider: false,
                    onTap: () => Get.to(() => PrivacyPolicyScreen()),
                  ),
                ],
              ),
            ),

            // ── Logout button ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
              child: GestureDetector(
                onTap: () => _confirmLogout(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9D7E3F), Color(0xFFB8953A)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _C.golden.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF0EBD8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: _C.darkGreen, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(controller: nameCtrl, label: 'Full Name'),
            const SizedBox(height: 12),
            _dialogField(controller: emailCtrl, label: 'Email/Phone'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: _C.darkGreen.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _box.write('userName', nameCtrl.text.trim());
              _box.write('userEmail', emailCtrl.text.trim());
              setState(() {});
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.golden,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
  }) => TextField(
    controller: controller,
    style: const TextStyle(color: _C.darkGreen),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _C.darkGreen.withOpacity(0.65)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _C.border.withOpacity(0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _C.lightGreen),
      ),
      filled: true,
      fillColor: _C.cream.withOpacity(0.3),
    ),
  );

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF0EBD8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(color: _C.darkGreen, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: _C.darkGreen),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: _C.darkGreen.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _box.erase();
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
