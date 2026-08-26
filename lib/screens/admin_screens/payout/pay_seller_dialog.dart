import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:frontend/core/services/admin/payout_service.dart';
import 'package:frontend/core/services/payment_service.dart';
import 'package:frontend/core/utils/themes.dart';

class PaySellerDialog extends StatefulWidget {
  final Map payout;

  const PaySellerDialog({super.key, required this.payout});

  @override
  State<PaySellerDialog> createState() => _PaySellerDialogState();
}

class _PaySellerDialogState extends State<PaySellerDialog> {
  String payoutMethod = "easypaisa";
  final transactionIdController = TextEditingController();

  Map<String, dynamic>? paymentSettings;
  bool loadingSettings = true;
  bool isSubmitting = false;

  Uint8List? proofBytes;
  String? proofFileName;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await PaymentService().getPaymentSettings();
    if (!mounted) return;
    setState(() {
      paymentSettings = settings;
      loadingSettings = false;
    });
  }

  Future<void> pickProof() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (bytes.lengthInBytes > 2 * 1024 * 1024) {
      Get.snackbar("Error", "Image size must be less than 2 MB");
      return;
    }

    setState(() {
      proofBytes = bytes;
      proofFileName = file.name;
    });
  }

  Future<void> submit() async {
    if (transactionIdController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter the transaction ID");
      return;
    }
    if (proofBytes == null) {
      Get.snackbar("Error", "Please upload a payment screenshot");
      return;
    }

    setState(() => isSubmitting = true);

    final result = await PayoutService().payPayout(
      payoutId: widget.payout["id"],
      payoutMethod: payoutMethod,
      transactionId: transactionIdController.text.trim(),
      imageBytes: proofBytes!,
      fileName: proofFileName!,
    );

    setState(() => isSubmitting = false);

    Get.snackbar(
      result["success"] == true ? "Success" : "Error",
      result["message"] ?? "",
    );

    if (result["success"] == true) Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.payout["shop"] ?? {};
    final netAmount = widget.payout["net_amount"]?.toString() ?? "0";

    final isEasypaisa = payoutMethod == "easypaisa";

    final sellerNumber = isEasypaisa
        ? (shop["payout_easypaisa_number"] ?? "")
        : (shop["payout_jazzcash_number"] ?? "");

    final sellerAccountName = isEasypaisa
        ? (shop["payout_easypaisa_account_name"] ?? "")
        : (shop["payout_jazzcash_account_name"] ?? "");

    final myNumber = isEasypaisa
        ? (paymentSettings?["easypaisa_number"] ?? "")
        : (paymentSettings?["jazzcash_number"] ?? "");

    return AlertDialog(
      backgroundColor: AppColors.cream,
      title: Text("Pay Seller", style: AppTextStyles.heading3),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${shop["shop_name"] ?? "Shop"} — Rs $netAmount",
                style: AppTextStyles.heading4,
              ),
              const SizedBox(height: 4),
              Text(
                sellerNumber.isNotEmpty
                    ? "Send to (${isEasypaisa ? "EasyPaisa" : "JazzCash"}): $sellerNumber — $sellerAccountName"
                    : "Seller hasn't added a ${isEasypaisa ? "EasyPaisa" : "JazzCash"} account yet",
                style: AppTextStyles.bodySmall,
              ),

              const SizedBox(height: 16),

              Text("Paid via", style: AppTextStyles.label),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      value: "easypaisa",
                      groupValue: payoutMethod,
                      contentPadding: EdgeInsets.zero,
                      title: const Text("EasyPaisa"),
                      onChanged: (v) => setState(() => payoutMethod = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      value: "jazzcash",
                      groupValue: payoutMethod,
                      contentPadding: EdgeInsets.zero,
                      title: const Text("JazzCash"),
                      onChanged: (v) => setState(() => payoutMethod = v!),
                    ),
                  ),
                ],
              ),

              if (!loadingSettings)
                Text(
                  "Sending from: ${myNumber.isNotEmpty ? myNumber : 'not set in Payment Settings'}",
                  style: AppTextStyles.bodySmall,
                ),

              const SizedBox(height: 14),

              TextField(
                controller: transactionIdController,
                decoration: const InputDecoration(labelText: "Transaction ID"),
              ),

              const SizedBox(height: 14),

              ElevatedButton(
                onPressed: pickProof,
                child: Text(proofFileName ?? "Upload Screenshot"),
              ),

              if (proofBytes != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    proofBytes!,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: isSubmitting ? null : submit,
          child: isSubmitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Confirm Payment"),
        ),
      ],
    );
  }
}
