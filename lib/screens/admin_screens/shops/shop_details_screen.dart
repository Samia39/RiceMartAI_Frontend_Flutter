import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/core/services/shop_service.dart';
import '../../../core/utils/themes.dart';

class ShopDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> shop;

  /// When true (e.g. opened from the Approved Shops list), the
  /// Approve / Correction / Reject action row is hidden and a simple
  /// "Approved" indicator is shown instead — this screen becomes
  /// view-only.
  final bool readOnly;

  const ShopDetailsScreen({
    super.key,
    required this.shop,
    this.readOnly = false,
  });

  // =========================
  // STATUS COLOR (pending / approved / rejected)
  // =========================
  Color _statusColor(String status) {
    switch (status) {
      case "approved":
        return AppColors.success;
      case "rejected":
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _imageUrl(dynamic path) {
    if (path == null || path.toString().isEmpty) return "";
    return "http://127.0.0.1:8000/storage/$path";
  }

  @override
  Widget build(BuildContext context) {
    final frontImage = _imageUrl(shop["cnic_image"]);
    final backImage = _imageUrl(shop["cnic_back_image"]);

    final status = (shop["status"] ?? "pending").toString();
    final statusColor = _statusColor(status);

    final correctionReason = shop["correction_reason"]?.toString();
    final hasCorrectionReason =
        correctionReason != null && correctionReason.isNotEmpty;
    final rejectionReason = shop["rejection_reason"]?.toString();
    final hasRejectionReason =
        rejectionReason != null && rejectionReason.isNotEmpty;

    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text("Seller Verification"),
          centerTitle: true,
        ),

        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 40 : 18,
                vertical: 18,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: AppDecorations.card,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.cream.withOpacity(0.5),
                              child: Icon(
                                Icons.store,
                                size: 32,
                                color: AppColors.darkGreen,
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shop["shop_name"] ?? "-",
                                    style: AppTextStyles.heading3,
                                  ),

                                  const SizedBox(height: 8),

                                  Chip(
                                    label: Text(
                                      status.toUpperCase(),
                                      style: AppTextStyles.label.copyWith(
                                        color: statusColor,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                    backgroundColor: statusColor.withOpacity(
                                      0.15,
                                    ),
                                    side: BorderSide(
                                      color: statusColor.withOpacity(0.45),
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // PENDING CORRECTION NOTICE
                      if (hasCorrectionReason) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.warning.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.report_problem_outlined,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Correction Requested",
                                      style: AppTextStyles.label.copyWith(
                                        color: AppColors.warning,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      correctionReason,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // SELLER INFO
                      _sectionTitle("Seller Information"),

                      _infoCard([
                        _infoRow("Owner", shop["owner_name"]),
                        _infoRow("CNIC", shop["cnic"]),
                        _infoRow("Phone", shop["phone"]),
                        _infoRow("City", shop["city"]),
                        _infoRow("Address", shop["address"]),
                      ]),

                      const SizedBox(height: 20),

                      // SHOP INFO
                      _sectionTitle("Shop Information"),

                      _infoCard([
                        _infoRow("Shop Name", shop["shop_name"]),
                        _infoRow("Description", shop["description"]),
                      ]),

                      const SizedBox(height: 20),

                      // CNIC — FRONT
                      _sectionTitle("CNIC Document (Front)"),

                      _cnicTile(
                        context,
                        imageUrl: frontImage,
                        heroTag: "cnic-front-image",
                      ),

                      const SizedBox(height: 20),

                      // CNIC — BACK
                      _sectionTitle("CNIC Document (Back)"),

                      _cnicTile(
                        context,
                        imageUrl: backImage,
                        heroTag: "cnic-back-image",
                      ),

                      const SizedBox(height: 30),

                      // ACTIONS (hidden when read-only)
                      if (!readOnly) ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  String token =
                                      GetStorage().read("token") ?? "";

                                  final result = await ShopService()
                                      .approveShop(
                                        token: token,
                                        shopId: int.parse(
                                          shop["id"].toString(),
                                        ),
                                      );

                                  if (result["success"] == true &&
                                      context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Shop Approved"),
                                      ),
                                    );

                                    Navigator.pop(context, true);
                                  }
                                },
                                child: const Text("Approve"),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _correctionDialog(context, shop);
                                },
                                child: const Text("Correction"),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: BorderSide(
                                color: AppColors.error.withOpacity(0.7),
                              ),
                            ),
                            onPressed: () => _rejectDialog(context, shop),
                            child: const Text("Reject"),
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: AppDecorations.card,
                          child: Row(
                            children: [
                              Icon(
                                status == "rejected"
                                    ? Icons.cancel
                                    : Icons.check_circle,
                                color: status == "rejected"
                                    ? AppColors.error
                                    : AppColors.success,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  status == "rejected"
                                      ? "This shop has been rejected."
                                      : "This shop has already been approved.",
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _cnicTile(
    BuildContext context, {
    required String imageUrl,
    required String heroTag,
  }) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: AppDecorations.card,
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isNotEmpty
          ? InkWell(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    barrierColor: Colors.black,
                    transitionDuration: const Duration(milliseconds: 250),
                    pageBuilder: (context, animation, __) => FadeTransition(
                      opacity: animation,
                      child: _CnicFullScreenViewer(
                        imageUrl: imageUrl,
                        heroTag: heroTag,
                      ),
                    ),
                  ),
                );
              },
              child: Hero(
                tag: heroTag,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_not_supported, color: AppColors.iconMuted),
                  const SizedBox(height: 6),
                  Text("No image", style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTextStyles.heading3),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.card,
      child: Column(children: children),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Text(label, style: AppTextStyles.label)),
          Expanded(
            flex: 5,
            child: Text(
              value?.toString() ?? "-",
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _correctionDialog(BuildContext context, Map<String, dynamic> shop) {
    TextEditingController reason = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cream,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),

              title: Text("Request Correction", style: AppTextStyles.heading3),

              content: Container(
                decoration: AppDecorations.inputField,
                child: TextField(
                  controller: reason,
                  maxLines: 3,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Write correction reason...",
                    hintStyle: AppTextStyles.hint,
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: isSending
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          final reasonText = reason.text.trim();

                          if (reasonText.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter a correction reason",
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSending = true);

                          String token = GetStorage().read("token") ?? "";

                          final result = await ShopService().requestCorrection(
                            token: token,
                            shopId: int.parse(shop["id"].toString()),
                            reason: reasonText,
                          );

                          if (!dialogContext.mounted) return;

                          Navigator.pop(dialogContext);

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result["message"] ??
                                    (result["success"] == true
                                        ? "Correction request sent"
                                        : "Failed to send correction request"),
                              ),
                            ),
                          );

                          if (result["success"] == true) {
                            // Refresh the list this screen was opened from.
                            Navigator.pop(context, true);
                          }
                        },
                  child: isSending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Send"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _rejectDialog(BuildContext context, Map<String, dynamic> shop) {
    TextEditingController reason = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cream,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: Text("Reject Shop", style: AppTextStyles.heading3),
              content: Container(
                decoration: AppDecorations.inputField,
                child: TextField(
                  controller: reason,
                  maxLines: 3,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Write rejection reason...",
                    hintStyle: AppTextStyles.hint,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSending
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  onPressed: isSending
                      ? null
                      : () async {
                          final reasonText = reason.text.trim();

                          if (reasonText.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter a rejection reason",
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSending = true);

                          String token = GetStorage().read("token") ?? "";

                          final result = await ShopService().rejectShop(
                            token: token,
                            shopId: int.parse(shop["id"].toString()),
                            reason: reasonText,
                          );

                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result["message"] ??
                                    (result["success"] == true
                                        ? "Shop rejected"
                                        : "Failed to reject shop"),
                              ),
                            ),
                          );

                          if (result["success"] == true) {
                            Navigator.pop(context, true);
                          }
                        },
                  child: isSending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Reject"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FULL-SCREEN CNIC VIEWER
//  Dark backdrop, pinch-to-zoom, close button, Hero transition from
//  whichever thumbnail (front/back) was tapped.
// ─────────────────────────────────────────────────────────────────────────────
class _CnicFullScreenViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const _CnicFullScreenViewer({required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Hero(
                tag: heroTag,
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
            ),
          ),

          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
