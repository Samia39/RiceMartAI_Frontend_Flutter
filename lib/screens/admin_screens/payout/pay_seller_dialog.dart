import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/admin/payout_service.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/utils/themes.dart';

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
  bool confirmStep = false; // false = form, true = "are you sure" step
  String? errorText;

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
      setState(() => errorText = "Image size must be less than 2 MB");
      return;
    }

    if (!mounted) return;
    setState(() {
      proofBytes = bytes;
      proofFileName = file.name;
      errorText = null;
    });
  }

  // Step 1: validate, then switch this same dialog into a confirm view.
  void goToConfirmStep() {
    if (isSubmitting) return;

    if (transactionIdController.text.trim().isEmpty) {
      setState(() => errorText = "Please enter the transaction ID");
      return;
    }
    if (proofBytes == null) {
      setState(() => errorText = "Please upload a payment screenshot");
      return;
    }

    setState(() {
      errorText = null;
      confirmStep = true;
    });
  }

  // Step 2: actually send it.
  Future<void> submit() async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
      errorText = null;
    });

    final result = await PayoutService().payPayout(
      payoutId: widget.payout["id"],
      payoutMethod: payoutMethod,
      transactionId: transactionIdController.text.trim(),
      imageBytes: proofBytes!,
      fileName: proofFileName!,
    );

    if (!mounted) return;

    if (result["success"] == true) {
      // Close the dialog FIRST — the parent shows the snackbar and
      // refreshes once the overlay is clean, so it's never hidden
      // behind the (now-closed) dialog barrier.
      Get.back(
        result: {
          "success": true,
          "message": result["message"] ?? "Payment recorded",
        },
      );
    } else {
      // Still inside the dialog: show it inline, not as a snackbar.
      setState(() {
        isSubmitting = false;
        confirmStep = false; // let them see/edit the form again
        errorText =
            result["message"]?.toString() ??
            "Payment failed. Please try again.";
      });
    }
  }

  Widget buildForm(
    bool isEasypaisa,
    String sellerNumber,
    String sellerAccountName,
    String myNumber,
    String netAmount,
    Map shop,
  ) {
    return Column(
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
            child: Image.memory(proofBytes!, height: 140, fit: BoxFit.cover),
          ),
        ],
        if (errorText != null) ...[
          const SizedBox(height: 12),
          Text(
            errorText!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget buildConfirmStep(String netAmount, Map shop, bool isEasypaisa) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Confirm this payment?", style: AppTextStyles.heading4),
        const SizedBox(height: 10),
        Text(
          "Rs $netAmount to ${shop["shop_name"] ?? "this shop"} via "
          "${isEasypaisa ? "EasyPaisa" : "JazzCash"}.\nTxn ID: "
          "${transactionIdController.text.trim()}",
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 6),
        Text("This can't be undone once sent.", style: AppTextStyles.bodySmall),
        if (errorText != null) ...[
          const SizedBox(height: 12),
          Text(
            errorText!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
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

    return PopScope(
      canPop: !isSubmitting,
      child: AlertDialog(
        backgroundColor: AppColors.cream,
        title: Text(
          confirmStep ? "Confirm Payment" : "Pay Seller",
          style: AppTextStyles.heading3,
        ),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: confirmStep
                ? buildConfirmStep(netAmount, shop, isEasypaisa)
                : buildForm(
                    isEasypaisa,
                    sellerNumber,
                    sellerAccountName,
                    myNumber,
                    netAmount,
                    shop,
                  ),
          ),
        ),
        actions: confirmStep
            ? [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => setState(() => confirmStep = false),
                  child: const Text("Back"),
                ),
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
              ]
            : [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: goToConfirmStep,
                  child: const Text("Confirm Payment"),
                ),
              ],
      ),
    );
  }
}
