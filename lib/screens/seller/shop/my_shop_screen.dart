import 'package:flutter/material.dart';
import 'package:ricemart_ai/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/services/shop_service.dart';
import '../../../core/utils/themes.dart';

class MyShopScreen extends StatefulWidget {
  const MyShopScreen({super.key});

  @override
  State<MyShopScreen> createState() => _MyShopScreenState();
}

class _MyShopScreenState extends State<MyShopScreen> {
  String shopName = "";
  String ownerName = "";
  String phone = "";
  String address = "";
  String description = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadShopData();
    });
  }

  Future<void> loadShopData() async {
    final box = GetStorage();

    String token = box.read("token") ?? "";

    final result = await ShopService().getMyShop(token);

    if (result["success"] == true) {
      final shop = result["shop"];

      setState(() {
        shopName = shop["shop_name"] ?? "";
        ownerName = shop["owner_name"] ?? "";
        phone = shop["phone"] ?? "";
        address = shop["address"] ?? "";
        description = shop["description"] ?? "";
      });

      // SAVE ALSO IN STORAGE
      box.write("shop_id", shop["id"]);
      box.write("shop_name", shop["shop_name"]);
      box.write("owner_name", shop["owner_name"]);
      box.write("phone", shop["phone"]);
      box.write("address", shop["address"]);
      box.write("description", shop["description"]);
      box.write("shop_approved", shop["is_approved"]);
      box.write("cnic", shop["cnic"]);
      box.write("cnic_image", shop["cnic_image"]);
      box.write("cnic_back_image", shop["cnic_back_image"]);
      box.write("city", shop["city"]);
    } else {
      Get.snackbar("Error", result["message"]);
    }
  }

  // =========================
  // DELETE SHOP
  // =========================
  // =========================
  // STEP 1: REQUEST OTP
  // =========================
  Future<void> _requestDeleteOtp() async {
    final box = GetStorage();
    String token = box.read("token") ?? "";
    int? shopId = box.read("shop_id");

    if (shopId == null) return;

    final result = await ShopService().requestShopDeletion(
      token: token,
      shopId: shopId,
    );

    if (result["success"] == true) {
      Get.snackbar("OTP Sent", "Check your email for the verification code");
      _showOtpDialog(shopId, token);
    } else {
      Get.snackbar("Error", result["message"] ?? "Failed to send OTP");
    }
  }

  // =========================
  // STEP 2: ENTER OTP + CONFIRM DELETE
  // =========================
  void _showOtpDialog(int shopId, String token) {
    final otpController = TextEditingController();
    bool isSending = false;
    bool isResending = false;

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
              title: Text("Verify Deletion", style: AppTextStyles.heading3),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter the 6-digit code sent to your email to permanently delete this shop.",
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: AppDecorations.inputField,
                    child: TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter OTP",
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isResending
                          ? null
                          : () async {
                              setDialogState(() => isResending = true);
                              final result = await ShopService()
                                  .requestShopDeletion(
                                    token: token,
                                    shopId: shopId,
                                  );
                              setDialogState(() => isResending = false);
                              if (!dialogContext.mounted) return;
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result["message"] ?? "OTP resent",
                                  ),
                                ),
                              );
                            },
                      child: Text(isResending ? "Resending..." : "Resend OTP"),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: isSending
                      ? null
                      : () async {
                          final otp = otpController.text.trim();
                          if (otp.length != 6) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text("Enter the 6-digit OTP"),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSending = true);

                          final result = await ShopService()
                              .confirmShopDeletion(
                                token: token,
                                shopId: shopId,
                                otp: otp,
                              );

                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);

                          if (result["success"] == true) {
                            final box = GetStorage();
                            box.remove("has_shop");
                            box.remove("shop_approved");
                            box.remove("shop_id");
                            box.remove("shop_name");
                            box.remove("owner_name");
                            box.remove("phone");
                            box.remove("city");
                            box.remove("address");
                            box.remove("description");
                            box.remove("cnic");
                            box.remove("cnic_image");
                            box.remove("cnic_back_image");
                            box.write("shop_status", "none");
                            box.write("roles", ["customer"]);

                            Get.snackbar("Success", "Shop deleted");
                            Get.offAllNamed(AppRoutes.dashboard);
                          } else {
                            Get.snackbar(
                              "Error",
                              result["message"] ?? "Failed to delete shop",
                            );
                          }
                        },
                  child: isSending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Confirm Delete"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: AppColors.darkGreen),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(title, style: AppTextStyles.bodyMedium),

                const SizedBox(height: 4),

                Text(value, style: AppTextStyles.heading4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("My Shop")),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              infoTile(icon: Icons.store, title: "Shop Name", value: shopName),

              infoTile(icon: Icons.person, title: "Owner", value: ownerName),

              infoTile(icon: Icons.phone, title: "Phone", value: phone),

              infoTile(
                icon: Icons.location_on,
                title: "Address",
                value: address,
              ),

              infoTile(
                icon: Icons.info,
                title: "Description",
                value: description,
              ),

              const SizedBox(height: 30),

              // =========================
              // EDIT SHOP
              // =========================
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(AppRoutes.editShop);
                  },

                  icon: const Icon(Icons.edit),

                  label: const Text("Edit Shop"),
                ),
              ),

              const SizedBox(height: 14),

              // =========================
              // DELETE SHOP
              // =========================
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                  onPressed: () {
                    Get.defaultDialog(
                      title: "Delete Shop",
                      middleText:
                          "Are you sure? You'll need to verify with an OTP sent to your email.",
                      textConfirm: "Continue",
                      textCancel: "Cancel",
                      confirmTextColor: Colors.white,
                      onConfirm: () async {
                        Get.back();
                        await _requestDeleteOtp();
                      },
                    );
                  },
                  icon: const Icon(Icons.delete),

                  label: const Text("Delete Shop"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
