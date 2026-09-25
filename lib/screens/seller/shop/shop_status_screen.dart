import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ricemart_ai/core/services/auth_service.dart';
import '../../../core/services/shop_service.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/utils/themes.dart';
import '../../../routes/app_routes.dart';

class ShopStatusScreen extends StatefulWidget {
  final Map<String, dynamic>? shop;

  const ShopStatusScreen({super.key, this.shop});

  @override
  State<ShopStatusScreen> createState() => _ShopStatusScreenState();
}

class _ShopStatusScreenState extends State<ShopStatusScreen> {
  Map<String, dynamic>? shop;
  bool loading = true;
  bool _shopGone = false; // true when admin rejected/removed the shop

  @override
  void initState() {
    super.initState();
    shop = widget.shop;
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => loading = true);

    final token = GetStorage().read("token") ?? "";
    final result = await ShopService().getMyShop(token);

    if (!mounted) return;

    if (result["success"] == true) {
      setState(() {
        shop = result["shop"];
        loading = false;
      });

      final box = GetStorage();
      box.write("shop_id", shop!["id"]);
      box.write("shop_name", shop!["shop_name"]);
      box.write("owner_name", shop!["owner_name"]);
      box.write("phone", shop!["phone"]);
      box.write("city", shop!["city"]);
      box.write("address", shop!["address"]);
      box.write("description", shop!["description"]);
      box.write("shop_approved", shop!["is_approved"]);
      box.write("shop_status", shop!["status"]);
      box.write("cnic", shop!["cnic"]);
      box.write("cnic_image", shop!["cnic_image"]);
      box.write("cnic_back_image", shop!["cnic_back_image"]);
    } else {
      // /my-shop failed. Most likely the admin rejected the shop and the
      // backend no longer returns it. Confirm with /me before deciding.
      try {
        final me = await AuthService.me(token);
        if (!mounted) return;

        if (me['user'] == null) {
          // Not a valid answer (network/server problem) — don't guess.
          setState(() => loading = false);
          Get.snackbar(
            'Could not refresh',
            'Please check your connection and try again.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        setState(() {
          _shopGone = me['has_shop'] != true;
          loading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => loading = false);
        Get.snackbar(
          'Could not refresh',
          'Please check your connection and try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  String get _status => (shop?["status"] ?? "pending").toString();
  String? get _correctionReason => shop?["correction_reason"]?.toString();
  bool get _hasCorrection =>
      _correctionReason != null && _correctionReason!.isNotEmpty;
  String? get _rejectionReason => shop?["rejection_reason"]?.toString();

  bool get _isExistingSeller {
    final roles = List<String>.from(GetStorage().read('roles') ?? []);
    return roles.contains('seller');
  }

  // Pending or correction-requested shops lock the screen — applies to
  // both a brand-new applicant and an existing seller re-submitting an
  // edit. Rejected/approved always have their own way forward (a button),
  // so they don't need to be forced to stay.
  bool get _mustStayHere =>
      !_shopGone && (_status == "pending" || _hasCorrection);

  void _goToBuyerDashboard() {
    final box = GetStorage();
    box.remove("has_shop");
    box.remove("shop_id");
    box.remove("shop_approved");
    box.write("shop_status", "none");
    Get.offAllNamed(AppRoutes.dashboard);
  }

  void _continueToSellerDashboard() {
    // Role hasn't changed (still 'seller') — this shop update is just
    // awaiting re-approval, so the seller keeps full dashboard access
    // while it's reviewed. No storage to clear, no reload needed.
    Get.offAllNamed(AppRoutes.sellerDashboard);
  }

  // Refreshes cached roles/permissions (customer -> seller) via the
  // same AuthController.loadUser() used at app startup, then navigates
  // to the seller dashboard now that the fresh role is in storage.
  Future<void> _goToSellerDashboard() async {
    try {
      final box = GetStorage();
      final token = box.read('token') ?? '';

      // Fresh roles/permissions straight from the backend
      final res = await AuthService.me(token);

      final freshRoles = List<String>.from(res['roles'] ?? []);
      final freshPerms = List<String>.from(res['permissions'] ?? []);

      if (!freshRoles.contains('seller')) {
        Get.snackbar(
          'Not ready yet',
          'Your seller access is not active yet. Please try again shortly.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Same keys loadUser() saves
      box.write('roles', freshRoles);
      box.write('permissions', freshPerms);
      box.write('has_shop', res['has_shop']);
      box.write('shop_status', res['shop_status'] ?? 'none');
      box.write('shop_id', res['shop']?['id']);
      box.write('is_shop_approved', res['shop']?['is_approved'] == 1);

      // Keep the in-memory controller in sync too
      if (Get.isRegistered<AuthController>()) {
        final c = Get.find<AuthController>();
        c.roles.value = freshRoles;
        c.permissions.value = freshPerms;
      }

      if (!mounted) return;
      Get.offAllNamed(AppRoutes.sellerDashboard);
    } catch (e, st) {
      debugPrint('Go to seller dashboard failed: $e\n$st');
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Converted from Navigator.push(MaterialPageRoute(...)) to a named
  // route so AuthMiddleware/PermissionMiddleware('update own shop')
  // actually run for it.
  Future<void> _editAndResubmit() async {
    await Get.toNamed(AppRoutes.editShop);
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_mustStayHere,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.snackbar(
            "Please wait",
            "You'll be able to leave once your shop is re-approved.",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
      child: Container(
        decoration: AppDecorations.gradientBackground,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Shop Status"),
            automaticallyImplyLeading: false,
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : (shop == null && !_shopGone)
              ? Center(
                  child: Text("No shop found", style: AppTextStyles.heading4),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 48,
                        ),
                        child: Center(child: _buildStateCard()),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStateCard() {
    if (_shopGone) return _rejectedCard();
    if (_status == "approved") return _approvedCard();
    if (_status == "rejected") return _rejectedCard();
    if (_hasCorrection) return _correctionCard();
    return _pendingCard();
  }

  Widget _pendingCard() {
    return _statusCard(
      icon: Icons.hourglass_top,
      iconColor: AppColors.warning,
      title: "Application Under Review",
      message: _isExistingSeller
          ? "Your shop \"${shop!["shop_name"] ?? ''}\" was updated and is "
                "waiting for admin re-approval. You'll regain access to your "
                "seller dashboard once it's reviewed."
          : "Your shop \"${shop!["shop_name"] ?? ''}\" has been submitted and is "
                "waiting for admin approval. We'll notify you once it's reviewed.",
      children: [
        OutlinedButton.icon(
          onPressed: _refresh,
          icon: const Icon(Icons.refresh),
          label: const Text("Check Status"),
        ),
      ],
    );
  }

  Widget _rejectedCard() {
    return _statusCard(
      icon: Icons.cancel,
      iconColor: AppColors.error,
      title: "Shop Application Rejected",
      message: (_rejectionReason?.isNotEmpty == true)
          ? _rejectionReason!
          : "Your shop application did not meet our requirements.",
      children: [
        ElevatedButton(
          onPressed: _goToBuyerDashboard,
          child: const Text("Back to Buyer Dashboard"),
        ),
      ],
    );
  }

  Widget _correctionCard() {
    return _statusCard(
      icon: Icons.report_problem_outlined,
      iconColor: AppColors.warning,
      title: "Correction Requested",
      message: _correctionReason ?? "",
      children: [
        ElevatedButton.icon(
          onPressed: _editAndResubmit,
          icon: const Icon(Icons.edit),
          label: const Text("Edit & Resubmit"),
        ),
      ],
    );
  }

  Widget _approvedCard() {
    if (_isExistingSeller) {
      // Re-approval after an edit — role never changed, just send them back.
      return _statusCard(
        icon: Icons.celebration,
        iconColor: AppColors.success,
        title: "Shop Updated",
        message:
            "Your changes to \"${shop!["shop_name"] ?? ''}\" have been "
            "approved and your shop is live again.",
        children: [
          ElevatedButton(
            onPressed: _continueToSellerDashboard,
            child: const Text("Back to Your Shop"),
          ),
        ],
      );
    }

    // First-time approval — customer becomes a seller.
    return _statusCard(
      icon: Icons.celebration,
      iconColor: AppColors.success,
      title: "Congratulations!",
      message:
          "Your shop \"${shop!["shop_name"] ?? ''}\" has been approved. "
          "You're now a seller on Rice Mart.",
      children: [
        ElevatedButton(
          onPressed: _goToSellerDashboard,
          child: const Text("Go to Seller Dashboard"),
        ),
      ],
    );
  }

  Widget _statusCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.card,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: iconColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
  }
}
