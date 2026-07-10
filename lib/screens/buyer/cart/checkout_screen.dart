import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/cart_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/utils/themes.dart';
import '../../../routes/app_routes.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // =========================
  // CONTROLLERS
  // =========================
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final transactionIdController = TextEditingController();

  // =========================
  // PAYMENT METHOD
  // =========================
  String paymentMethod = "easypaisa";

  // =========================
  // PAYMENT SETTINGS (EasyPaisa / JazzCash numbers, admin-managed)
  // =========================
  Map<String, dynamic>? paymentSettings;
  bool loadingPaymentSettings = true;

  // =========================
  // IMAGE (WEB)
  // =========================
  Uint8List? paymentImageBytes;
  String? paymentFileName;

  // =========================
  // CART
  // =========================
  List cart = [];

  // =========================
  // TOTAL
  // =========================
  double total = 0;

  // =========================
  // LOADING
  // =========================
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    cart = CartService().getCart();
    total = CartService().totalPrice();

    _loadPaymentSettings();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    addressController.dispose();
    transactionIdController.dispose();
    super.dispose();
  }

  // =========================
  // LOAD PAYMENT SETTINGS
  // (EasyPaisa/JazzCash numbers are admin-managed on the backend,
  // not hardcoded, so they can be changed without an app update)
  // =========================
  Future<void> _loadPaymentSettings() async {
    final settings = await PaymentService().getPaymentSettings();

    if (!mounted) return;

    setState(() {
      paymentSettings = settings;
      loadingPaymentSettings = false;
    });
  }

  // =========================
  // PICK IMAGE
  // =========================
  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();

      final XFile? file = await picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        paymentImageBytes = await file.readAsBytes();
        if (paymentImageBytes!.lengthInBytes > 2 * 1024 * 1024) {
          paymentImageBytes = null;

          Get.snackbar(
            "Error",
            "Image size must be less than 2 MB",
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        paymentFileName = file.name;

        setState(() {});
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Unable to select image",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =========================
  // EXTRACT LARAVEL VALIDATION ERRORS
  // =========================
  // Laravel validation failures (422) return:
  // { "message": "The given data was invalid.", "errors": { "phone": ["The phone field is required."], ... } }
  // This pulls out the first message per field and joins them into one
  // readable string, instead of showing the generic top-level "message".
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

    return result["message"] ?? "Checkout failed";
  }

  // =========================
  // PLACE ORDER
  // =========================
  Future<void> placeOrder() async {
    // =========================
    // BASIC VALIDATION
    // =========================
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all required fields",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // =========================
    // TRANSACTION ID REQUIRED
    // =========================
    if ((paymentMethod == "easypaisa" || paymentMethod == "jazzcash") &&
        transactionIdController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter transaction ID",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // =========================
    // SCREENSHOT REQUIRED
    // =========================
    if ((paymentMethod == "easypaisa" || paymentMethod == "jazzcash") &&
        paymentImageBytes == null) {
      Get.snackbar(
        "Error",
        "Please upload payment screenshot",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // =========================
    // EMPTY CART CHECK
    // =========================
    if (cart.isEmpty) {
      Get.snackbar(
        "Error",
        "Your cart is empty",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Confirm Order"),
        content: Text(
          "Are you sure you want to place this order for Rs ${total.toStringAsFixed(0)}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // =========================
    // CONVERT CART FOR API
    // =========================
    List items = cart.map((item) {
      return {"product_id": item["id"], "quantity": item["quantity"]};
    }).toList();

    setState(() {
      isLoading = true;
    });

    try {
      final result = await OrderService().checkout(
        customerName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        city: cityController.text.trim(),
        address: addressController.text.trim(),
        paymentMethod: paymentMethod,
        transactionId: transactionIdController.text.trim(),
        imageBytes: paymentImageBytes,
        fileName: paymentFileName,
        cart: items,
      );

      setState(() {
        isLoading = false;
      });

      if (result["success"] == true) {
        CartService().clearCart();

        Get.snackbar(
          "Success",
          result["message"] ?? "Order placed successfully",
          snackPosition: SnackPosition.TOP,
        );

        Get.offAllNamed(AppRoutes.myOrders);
      } else {
        Get.snackbar(
          "Error",
          _extractErrorMessage(result),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // =========================
  // SEND PAYMENT TO — dynamic number/account name per method,
  // pulled from the admin-managed payment settings.
  // =========================
  Widget _sendPaymentToSection() {
    if (loadingPaymentSettings) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.card,
        child: const Center(
          child: SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final isEasypaisa = paymentMethod == "easypaisa";

    final String number = isEasypaisa
        ? (paymentSettings?["easypaisa_number"] ?? "")
        : (paymentSettings?["jazzcash_number"] ?? "");

    final String accountName = isEasypaisa
        ? (paymentSettings?["easypaisa_account_name"] ?? "")
        : (paymentSettings?["jazzcash_account_name"] ?? "");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Send Payment To", style: AppTextStyles.heading4),

          const SizedBox(height: 10),

          Text(
            number.isNotEmpty ? number : "Number not set yet",
            style: AppTextStyles.heading3.copyWith(color: AppColors.golden),
          ),

          if (accountName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(accountName, style: AppTextStyles.bodyMedium),
          ],
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
        appBar: AppBar(title: const Text("Checkout")),
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
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // =========================
                      // NAME
                      // =========================
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Customer Name",
                        ),
                      ),

                      const SizedBox(height: 16),

                      // =========================
                      // PHONE
                      // =========================
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                        ),
                      ),

                      const SizedBox(height: 16),

                      // =========================
                      // CITY
                      // =========================
                      TextField(
                        controller: cityController,
                        decoration: const InputDecoration(labelText: "City"),
                      ),

                      const SizedBox(height: 16),

                      // =========================
                      // ADDRESS
                      // =========================
                      TextField(
                        controller: addressController,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: "Address"),
                      ),

                      const SizedBox(height: 24),

                      // =========================
                      // ORDER SUMMARY
                      // =========================
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppDecorations.card,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order Summary",
                              style: AppTextStyles.heading3,
                            ),

                            const SizedBox(height: 15),

                            ...cart.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item["name"] ?? "",
                                            style: AppTextStyles.heading4,
                                          ),

                                          Text(
                                            "Shop: ${item["shop"]?["shop_name"] ?? "-"}",
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),

                                    Text(
                                      "x${item["quantity"]}",
                                      style: AppTextStyles.bodyMedium,
                                    ),

                                    const SizedBox(width: 15),

                                    Text(
                                      "Rs ${item["price"]}",
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              );
                            }),

                            const Divider(),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total", style: AppTextStyles.heading3),
                                Text(
                                  "Rs ${total.toStringAsFixed(0)}",
                                  style: AppTextStyles.heading3,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text("Payment Method", style: AppTextStyles.heading4),

                      const SizedBox(height: 10),

                      Container(
                        decoration: AppDecorations.card,
                        child: Column(
                          children: [
                            RadioListTile(
                              value: "easypaisa",
                              groupValue: paymentMethod,
                              activeColor: AppColors.golden,
                              title: Text(
                                "EasyPaisa",
                                style: AppTextStyles.bodyLarge,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  paymentMethod = value!;
                                });
                              },
                            ),

                            Divider(height: 1, color: AppColors.divider),

                            RadioListTile(
                              value: "jazzcash",
                              groupValue: paymentMethod,
                              activeColor: AppColors.golden,
                              title: Text(
                                "JazzCash",
                                style: AppTextStyles.bodyLarge,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  paymentMethod = value!;
                                });
                              },
                            ),

                            Divider(height: 1, color: AppColors.divider),

                            RadioListTile(
                              value: "card",
                              groupValue: paymentMethod,
                              activeColor: AppColors.golden,
                              title: Text(
                                "Card",
                                style: AppTextStyles.bodyLarge,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  paymentMethod = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (paymentMethod == "easypaisa" ||
                          paymentMethod == "jazzcash")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _sendPaymentToSection(),

                            const SizedBox(height: 20),

                            TextField(
                              controller: transactionIdController,
                              decoration: const InputDecoration(
                                labelText: "Transaction ID",
                              ),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: pickImage,
                                child: Text(
                                  paymentFileName == null
                                      ? "Upload Screenshot"
                                      : paymentFileName!,
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            if (paymentImageBytes != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  paymentImageBytes!,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          ],
                        ),

                      if (paymentMethod == "card")
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: AppDecorations.card,
                          child: Text(
                            "Card payment gateway will be integrated in future versions. "
                            "For project demonstration, card payment is shown as a UI option.",
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),

                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total", style: AppTextStyles.heading3),
                          Text(
                            "Rs ${total.toStringAsFixed(0)}",
                            style: AppTextStyles.heading3,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : placeOrder,
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : const Text("Place Order"),
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
