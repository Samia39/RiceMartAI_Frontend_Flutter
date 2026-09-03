import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/services/product_service.dart';
import '../../../core/services/shop_service.dart';
import '../../../core/utils/themes.dart';
import '../../../widgets/shop_reviews_section.dart';

class ApprovedShopDetailScreen extends StatefulWidget {
  const ApprovedShopDetailScreen({super.key});

  // Reached via:
  // Get.toNamed(
  //   AppRoutes.adminApprovedShopDetail,
  //   arguments: shop,
  // )
  Map<String, dynamic> get shop => Get.arguments as Map<String, dynamic>;

  @override
  State<ApprovedShopDetailScreen> createState() =>
      _ApprovedShopDetailScreenState();
}

class _ApprovedShopDetailScreenState extends State<ApprovedShopDetailScreen> {
  List<Map<String, dynamic>> products = [];
  bool loadingProducts = true;
  bool isRemoving = false;

  String get _token => GetStorage().read("token") ?? "";

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final shopId = int.parse(widget.shop["id"].toString());

      final data = await ProductService().fetchShopProducts(shopId: shopId);

      if (!mounted) return;

      setState(() {
        products = data;
        loadingProducts = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingProducts = false;
      });
    }
  }

  String _imageUrl(dynamic path) {
    if (path == null || path.toString().isEmpty) {
      return "";
    }

    return "http://ricemart.sandbox.pk/storage/$path";
  }

  // =========================
  // COMPACT INFO ROW
  // =========================

  Widget _compactRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.darkGreen),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTextStyles.labelMuted.copyWith(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString().isNotEmpty == true ? value.toString() : "-",
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // CNIC THUMBNAIL
  // =========================

  Widget _cnicThumb(String label, String url) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelMuted.copyWith(fontSize: 11)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: url.isEmpty
                ? null
                : () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.black,
                        child: InteractiveViewer(
                          child: Image.network(url, fit: BoxFit.contain),
                        ),
                      ),
                    );
                  },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 70,
                width: double.infinity,
                color: AppColors.cream,
                child: url.isNotEmpty
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            size: 20,
                            color: AppColors.iconMuted,
                          );
                        },
                      )
                    : Icon(
                        Icons.image_not_supported,
                        size: 20,
                        color: AppColors.iconMuted,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // PRODUCT TILE
  // =========================

  Widget _productTile(Map<String, dynamic> product) {
    final imageUrl = ProductService.getImageUrl(product);

    final categoryName =
        product["rice_category"]?["name"]?.toString() ?? "Uncategorized";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: AppDecorations.card,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 52,
              width: 52,
              color: AppColors.cream,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.rice_bowl,
                          color: AppColors.darkGreen,
                        );
                      },
                    )
                  : Icon(Icons.rice_bowl, color: AppColors.darkGreen),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product["name"]?.toString() ?? "",
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(categoryName, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Rs. ${product["price"] ?? "-"}",
                style: AppTextStyles.bodyMedium,
              ),
              Text(
                "${product["stock"] ?? 0} KG",
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // REMOVE SELLER DIALOG
  // =========================

  void _showRemoveDialog() {
    final shop = widget.shop; // to solve error
    final reasonController = TextEditingController();

    bool permanentBan = false;
    bool sending = false;

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
              title: Text("Remove Seller", style: AppTextStyles.heading3),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "This will permanently deactivate the shop "
                      "and seller account. Order history is kept. "
                      "This cannot be undone from the app.",
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: AppDecorations.inputField,
                      child: TextField(
                        controller: reasonController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Reason for removal (required)",
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: permanentBan,
                      onChanged: (value) {
                        setDialogState(() {
                          permanentBan = value ?? false;
                        });
                      },
                      title: Text(
                        "Permanently ban this person from "
                        "registering again",
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: sending
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: sending
                      ? null
                      : () async {
                          final reason = reasonController.text.trim();

                          if (reason.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a reason"),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            sending = true;
                          });

                          try {
                            final result = await ShopService().removeSeller(
                              token: _token,
                              shopId: int.parse(
                                shop["id"].toString(),
                              ), // <-- use local `shop`, not widget.shop
                              reason: reason,
                              permanentlyBan: permanentBan,
                            );

                            if (!dialogContext.mounted) {
                              return;
                            }

                            Navigator.pop(dialogContext);

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result["message"] ??
                                      (result["success"] == true
                                          ? "Seller removed"
                                          : "Failed to remove seller"),
                                ),
                              ),
                            );

                            if (result["success"] == true) {
                              Navigator.pop(context, true);
                            }
                          } catch (e) {
                            if (!dialogContext.mounted) {
                              return;
                            }

                            setDialogState(() {
                              sending = false;
                            });

                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text("Failed to remove seller: $e"),
                              ),
                            );
                          }
                        },
                  child: sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Confirm Remove"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;

    final frontImage = _imageUrl(shop["cnic_image"]);

    final backImage = _imageUrl(shop["cnic_back_image"]);

    final shopId = int.parse(shop["id"].toString());

    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Shop Details")),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 40 : 16,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =====================================================
                      // SHOP INFORMATION
                      // =====================================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: AppDecorations.card,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.cream.withOpacity(
                                    0.6,
                                  ),
                                  child: Icon(
                                    Icons.store,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    shop["shop_name"]?.toString() ?? "-",
                                    style: AppTextStyles.heading4,
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    "APPROVED",
                                    style: AppTextStyles.label.copyWith(
                                      color: AppColors.success,
                                      fontSize: 10,
                                    ),
                                  ),
                                  backgroundColor: AppColors.success
                                      .withOpacity(0.15),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            _compactRow(
                              Icons.person,
                              "Owner",
                              shop["owner_name"],
                            ),
                            _compactRow(Icons.phone, "Phone", shop["phone"]),
                            _compactRow(Icons.badge, "CNIC", shop["cnic"]),
                            _compactRow(
                              Icons.location_city,
                              "City",
                              shop["city"],
                            ),
                            _compactRow(
                              Icons.location_on,
                              "Address",
                              shop["address"],
                            ),
                            _compactRow(
                              Icons.info_outline,
                              "Description",
                              shop["description"],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _cnicThumb("CNIC Front", frontImage),
                                const SizedBox(width: 10),
                                _cnicThumb("CNIC Back", backImage),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =====================================================
                      // PRODUCTS
                      // =====================================================
                      Text(
                        "Products (${products.length})",
                        style: AppTextStyles.heading4,
                      ),

                      const SizedBox(height: 10),

                      if (loadingProducts)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (products.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            "No products listed yet",
                            style: AppTextStyles.bodySmall,
                          ),
                        )
                      else
                        Column(children: products.map(_productTile).toList()),

                      // =====================================================
                      // REVIEWS
                      // =====================================================
                      const SizedBox(height: 24),

                      ShopReviewsSection(shopId: shopId),

                      const SizedBox(height: 24),

                      // =====================================================
                      // REMOVE SELLER
                      // =====================================================
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC62828),
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shadowColor: Colors.red.withOpacity(0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _showRemoveDialog,
                          icon: const Icon(Icons.person_remove, size: 21),
                          label: const Text(
                            "Permanently Remove Seller",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

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
}
