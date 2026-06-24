import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';
import '../../../core/utils/themes.dart';
import '../../../core/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Storage & token ─────────────────────────────────────
  final _box = GetStorage();
  String _token = '';

  // ── User data ────────────────────────────────────────────
  String _name = '';
  String _email = '';
  String _role = '';
  bool _isVerified = false;
  bool _hasShop = false;

  // ── UI state ─────────────────────────────────────────────
  bool _loadingProfile = true;
  bool _savingProfile = false;
  bool _showEditForm = false;
  bool _obscurePassword = true;

  // ── Edit form controllers ────────────────────────────────
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _token = _box.read('token') ?? '';
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Parse role from list ─────────────────────────────────
  String _parseRole(dynamic apiRoles) {
    // Try from API response first
    if (apiRoles != null && apiRoles is List && apiRoles.isNotEmpty) {
      final first = apiRoles[0];
      return first is Map ? first['name'].toString() : first.toString();
    }

    // Fallback to GetStorage 'roles' list (saved at login)
    final storedRoles = _box.read('roles');
    if (storedRoles is List && storedRoles.isNotEmpty) {
      final first = storedRoles[0];
      return first is Map ? first['name'].toString() : first.toString();
    }

    return 'customer';
  }

  // ── Fetch authenticated user ─────────────────────────────
  Future<void> _fetchProfile() async {
    if (_token.isEmpty) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    setState(() => _loadingProfile = true);

    try {
      final data = await AuthService.me(_token);
      final user = data['user'] ?? data;

      setState(() {
        _name = user['name'] ?? '';
        _email = user['email'] ?? '';
        _role = _parseRole(user['roles'] ?? data['roles']);
        _isVerified = (user['is_verified'] == 1 || user['is_verified'] == true);
        _hasShop =
            (user['has_shop'] == 1 || user['has_shop'] == true) ||
            (_box.read('has_shop') ?? false);
      });

      // Prefill edit controllers with current values
      _nameController.text = _name;
      _emailController.text = _email;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Could not load profile. Please login again.",
        backgroundColor: Colors.red.withOpacity(0.85),
        colorText: Colors.white,
      );
    } finally {
      setState(() => _loadingProfile = false);
    }
  }

  // ── Save profile changes ─────────────────────────────────
  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();
    final newPassword = _passwordController.text.trim();

    // ── Validation ───────────────────────────────────────
    if (newName.isEmpty) {
      _showError("Name cannot be empty.");
      return;
    }

    if (!_isVerified && newEmail.isEmpty) {
      _showError("Email cannot be empty.");
      return;
    }

    if (!_isVerified && !GetUtils.isEmail(newEmail)) {
      _showError("Please enter a valid email address.");
      return;
    }

    if (newPassword.isNotEmpty && newPassword.length < 6) {
      _showError("Password must be at least 6 characters.");
      return;
    }

    setState(() => _savingProfile = true);

    try {
      await AuthService.updateProfile(
        _token,
        name: newName,
        email: _isVerified ? null : newEmail,
        password: newPassword.isEmpty ? null : newPassword,
      );

      _passwordController.clear();

      Get.snackbar(
        "Success",
        "Profile updated successfully.",
        backgroundColor: Colors.green.withOpacity(0.85),
        colorText: Colors.white,
      );

      setState(() => _showEditForm = false);
      await _fetchProfile();
    } catch (e) {
      _showError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      setState(() => _savingProfile = false);
    }
  }

  // ── Logout ───────────────────────────────────────────────
  void _logout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      textConfirm: "Yes, Logout",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        _box.erase();
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }

  // ── Helper ───────────────────────────────────────────────
  void _showError(String msg) {
    Get.snackbar(
      "Validation Error",
      msg,
      backgroundColor: Colors.red.withOpacity(0.85),
      colorText: Colors.white,
    );
  }

  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Profile")),
        body: _loadingProfile
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    _buildEditSection(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Profile card ─────────────────────────────────────────
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 16),

          // Name
          Text(_name.isNotEmpty ? _name : "—", style: AppTextStyles.heading3),
          const SizedBox(height: 6),

          // Email
          Text(
            _email.isNotEmpty ? _email : "—",
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: 10),

          // Verified badge only
          if (_isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green, width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    "Verified",
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange, width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Unverified",
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Edit profile section ─────────────────────────────────
  Widget _buildEditSection() {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row with toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Edit Profile", style: AppTextStyles.heading3),
              IconButton(
                icon: Icon(
                  _showEditForm ? Icons.expand_less : Icons.expand_more,
                ),
                onPressed: () => setState(() => _showEditForm = !_showEditForm),
              ),
            ],
          ),

          // Collapsible form
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _showEditForm
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                // ── Name field ──────────────────────────
                Container(
                  decoration: AppDecorations.inputField,
                  child: TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      hintText: "Full Name",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Email (only if not verified) ─────────
                if (!_isVerified) ...[
                  Container(
                    decoration: AppDecorations.inputField,
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "Email Address",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      "⚠ Your email is not verified. You may update it here.",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Password field ───────────────────────
                Container(
                  decoration: AppDecorations.inputField,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: "New Password (leave blank to keep current)",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Save button ──────────────────────────
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _savingProfile ? null : _saveProfile,
                    icon: _savingProfile
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_savingProfile ? "Saving..." : "Save Changes"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ───────────────────────────────────────
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),

        // Become Seller — only for customers without a shop
        if (_role.toLowerCase() == 'customer' && !_hasShop)
          SizedBox(
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.createShop),
              icon: const Icon(Icons.store),
              label: const Text("Become Seller"),
            ),
          ),

        // Seller Dashboard — anyone who has a shop
        if (_hasShop)
          SizedBox(
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.sellerDashboard),
              icon: const Icon(Icons.dashboard),
              label: const Text("Seller Dashboard"),
            ),
          ),

        const SizedBox(height: 14),

        // Logout
        SizedBox(
          height: 55,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          ),
        ),
      ],
    );
  }
}
