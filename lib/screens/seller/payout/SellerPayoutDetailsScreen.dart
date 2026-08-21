import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/services/shop_service.dart';
import '../../../core/utils/themes.dart';

class SellerPayoutDetailsScreen extends StatefulWidget {
  const SellerPayoutDetailsScreen({super.key});

  @override
  State<SellerPayoutDetailsScreen> createState() =>
      _SellerPayoutDetailsScreenState();
}

class _SellerPayoutDetailsScreenState extends State<SellerPayoutDetailsScreen> {
  final box = GetStorage();
  final ShopService shopService = ShopService();

  final easypaisaNumberController = TextEditingController();
  final easypaisaAccountNameController = TextEditingController();
  final jazzcashNumberController = TextEditingController();
  final jazzcashAccountNameController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadShop();
  }

  @override
  void dispose() {
    easypaisaNumberController.dispose();
    easypaisaAccountNameController.dispose();
    jazzcashNumberController.dispose();
    jazzcashAccountNameController.dispose();
    super.dispose();
  }

  Future<void> _loadShop() async {
    final token = box.read("token");
    final result = await shopService.getMyShop(token);

    if (!mounted) return;

    if (result["success"] == true) {
      final shop = result["shop"];
      easypaisaNumberController.text = shop["payout_easypaisa_number"] ?? "";
      easypaisaAccountNameController.text =
          shop["payout_easypaisa_account_name"] ?? "";
      jazzcashNumberController.text = shop["payout_jazzcash_number"] ?? "";
      jazzcashAccountNameController.text =
          shop["payout_jazzcash_account_name"] ?? "";
    }

    setState(() => isLoading = false);
  }

  Future<void> _save() async {
    final hasEasypaisa = easypaisaNumberController.text.trim().isNotEmpty;
    final hasJazzcash = jazzcashNumberController.text.trim().isNotEmpty;

    if (!hasEasypaisa && !hasJazzcash) {
      Get.snackbar("Error", "Please add at least one payout account");
      return;
    }

    setState(() => isSaving = true);

    final token = box.read("token");
    final result = await shopService.updatePayoutDetails(
      token: token,
      easypaisaNumber: hasEasypaisa
          ? easypaisaNumberController.text.trim()
          : null,
      easypaisaAccountName: hasEasypaisa
          ? easypaisaAccountNameController.text.trim()
          : null,
      jazzcashNumber: hasJazzcash ? jazzcashNumberController.text.trim() : null,
      jazzcashAccountName: hasJazzcash
          ? jazzcashAccountNameController.text.trim()
          : null,
    );

    setState(() => isSaving = false);

    Get.snackbar(
      result["success"] == true ? "Success" : "Error",
      result["message"] ?? "",
    );
  }

  Widget _methodSection({
    required String title,
    required TextEditingController numberController,
    required TextEditingController accountNameController,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.heading4),
          const SizedBox(height: 14),
          TextField(
            controller: numberController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: "Account Number"),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: accountNameController,
            decoration: const InputDecoration(labelText: "Account Name"),
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
        appBar: AppBar(title: const Text("Payout Details")),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 40 : 16,
                      vertical: 16,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Add one or both — admin will send your payout to "
                              "whichever account you've filled in, after a customer "
                              "confirms they received your item.",
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: 20),

                            _methodSection(
                              title: "EasyPaisa",
                              numberController: easypaisaNumberController,
                              accountNameController:
                                  easypaisaAccountNameController,
                            ),

                            const SizedBox(height: 20),

                            _methodSection(
                              title: "JazzCash",
                              numberController: jazzcashNumberController,
                              accountNameController:
                                  jazzcashAccountNameController,
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              height: 55,
                              child: ElevatedButton(
                                onPressed: isSaving ? null : _save,
                                child: isSaving
                                    ? const CircularProgressIndicator()
                                    : const Text("Save"),
                              ),
                            ),
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
