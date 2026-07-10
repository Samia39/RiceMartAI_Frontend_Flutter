import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/payment_service.dart';
import '../../../core/utils/themes.dart';

class AdminPaymentSettingsScreen extends StatefulWidget {
  const AdminPaymentSettingsScreen({super.key});

  @override
  State<AdminPaymentSettingsScreen> createState() =>
      _AdminPaymentSettingsScreenState();
}

class _AdminPaymentSettingsScreenState
    extends State<AdminPaymentSettingsScreen> {
  // =========================
  // CONTROLLERS
  // =========================
  final easypaisaNumberController = TextEditingController();
  final easypaisaAccountNameController = TextEditingController();
  final jazzcashNumberController = TextEditingController();
  final jazzcashAccountNameController = TextEditingController();

  // =========================
  // STATE
  // =========================
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    easypaisaNumberController.dispose();
    easypaisaAccountNameController.dispose();
    jazzcashNumberController.dispose();
    jazzcashAccountNameController.dispose();
    super.dispose();
  }

  // =========================
  // LOAD CURRENT SETTINGS
  // =========================
  Future<void> _loadSettings() async {
    final settings = await PaymentService().getPaymentSettings();

    if (!mounted) return;

    if (settings != null) {
      easypaisaNumberController.text = settings["easypaisa_number"] ?? "";
      easypaisaAccountNameController.text =
          settings["easypaisa_account_name"] ?? "";
      jazzcashNumberController.text = settings["jazzcash_number"] ?? "";
      jazzcashAccountNameController.text =
          settings["jazzcash_account_name"] ?? "";
    }

    setState(() {
      isLoading = false;
    });
  }

  // =========================
  // EXTRACT LARAVEL VALIDATION ERRORS
  // (same pattern as checkout screen, for consistency)
  // =========================
  String _extractErrorMessage(Map<String, dynamic> result) {
    final errors = result["errors"];

    if (errors is Map<String, dynamic> && errors.isNotEmpty) {
      final messages = <String>[];

      errors.forEach((field, fieldErrors) {
        if (fieldErrors is List && fieldErrors.isNotEmpty) {
          messages.add(fieldErrors.first.toString());
        } else if (fieldErrors != null) {
          messages.add(fieldErrors.toString());
        }
      });

      if (messages.isNotEmpty) {
        return messages.join("\n");
      }
    }

    return result["message"] ?? "Failed to save payment settings";
  }

  // =========================
  // SAVE SETTINGS
  // =========================
  Future<void> _saveSettings() async {
    if (easypaisaNumberController.text.trim().isEmpty ||
        jazzcashNumberController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "EasyPaisa and JazzCash numbers are required",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final result = await PaymentService().adminUpdatePaymentSettings(
      easypaisaNumber: easypaisaNumberController.text.trim(),
      easypaisaAccountName: easypaisaAccountNameController.text.trim(),
      jazzcashNumber: jazzcashNumberController.text.trim(),
      jazzcashAccountName: jazzcashAccountNameController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    if (result["success"] == true) {
      Get.snackbar(
        "Success",
        result["message"] ?? "Payment settings updated",
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        "Error",
        _extractErrorMessage(result),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    }
  }

  // =========================
  // SECTION FOR ONE PAYMENT METHOD
  // =========================
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
            decoration: const InputDecoration(
              labelText: "Account Name (optional)",
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
        appBar: AppBar(title: const Text("Payment Settings")),
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
                              "These numbers are shown to customers on the "
                              "checkout screen when they pay via EasyPaisa "
                              "or JazzCash.",
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

                            const SizedBox(height: 30),

                            SizedBox(
                              height: 55,
                              child: ElevatedButton(
                                onPressed: isSaving ? null : _saveSettings,
                                child: isSaving
                                    ? const CircularProgressIndicator()
                                    : const Text("Save Changes"),
                              ),
                            ),

                            const SizedBox(height: 16),
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
