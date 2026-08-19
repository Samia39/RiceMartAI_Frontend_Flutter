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

  String payoutMethod = "easypaisa";
  final accountNumberController = TextEditingController();
  final accountNameController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadShop();
  }

  Future<void> _loadShop() async {
    final token = box.read("token");
    final result = await shopService.getMyShop(token);

    if (!mounted) return;

    if (result["success"] == true) {
      final shop = result["shop"];
      setState(() {
        payoutMethod = shop["payout_method"] ?? "easypaisa";
        accountNumberController.text = shop["payout_account_number"] ?? "";
        accountNameController.text = shop["payout_account_name"] ?? "";
      });
    }

    setState(() => isLoading = false);
  }

  Future<void> _save() async {
    if (accountNumberController.text.trim().isEmpty ||
        accountNameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please fill in all fields");
      return;
    }

    setState(() => isSaving = true);

    final token = box.read("token");
    final result = await shopService.updatePayoutDetails(
      token: token,
      payoutMethod: payoutMethod,
      accountNumber: accountNumberController.text.trim(),
      accountName: accountNameController.text.trim(),
    );

    setState(() => isSaving = false);

    Get.snackbar(
      result["success"] == true ? "Success" : "Error",
      result["message"] ?? "",
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
                              "This is where the admin sends your payout after a customer "
                              "confirms they received your item.",
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: AppDecorations.card,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "Receiving method",
                                    style: AppTextStyles.label,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: RadioListTile<String>(
                                          value: "easypaisa",
                                          groupValue: payoutMethod,
                                          contentPadding: EdgeInsets.zero,
                                          title: const Text("EasyPaisa"),
                                          onChanged: (v) =>
                                              setState(() => payoutMethod = v!),
                                        ),
                                      ),
                                      Expanded(
                                        child: RadioListTile<String>(
                                          value: "jazzcash",
                                          groupValue: payoutMethod,
                                          contentPadding: EdgeInsets.zero,
                                          title: const Text("JazzCash"),
                                          onChanged: (v) =>
                                              setState(() => payoutMethod = v!),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: accountNumberController,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      labelText: "Account Number",
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  TextField(
                                    controller: accountNameController,
                                    decoration: const InputDecoration(
                                      labelText: "Account Name",
                                    ),
                                  ),
                                ],
                              ),
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
