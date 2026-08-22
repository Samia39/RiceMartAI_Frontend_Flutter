import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/admin/city_service.dart';
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
  // =========================
  // CITY / DELIVERY
  // =========================
  final CityService _cityService = CityService();
  List _cities = []; // [{id, name, code, delivery_charge}]
  int? selectedCityId;
  double deliveryCharge = 0;
  bool loadingCities = true;
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

  int get distinctShopCount {
    final ids = cart
        .map((item) => item["shop"]?["id"])
        .where((id) => id != null)
        .toSet();
    return ids.isEmpty ? 1 : ids.length;
  }

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
    _loadCities();
  }

  Future<void> _loadCities() async {
    final cities = await _cityService.getCitiesWithCharges();

    if (!mounted) return;

    setState(() {
      _cities = cities;
      loadingCities = false;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
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
        selectedCityId == null ||
        addressController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        selectedCityId == null
            ? "Please select a delivery city"
            : "Please fill all required fields",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // =========================
    // TRANSACTION ID REQUIRED (manual methods only)
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
    // SCREENSHOT REQUIRED (manual methods only)
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
          "Are you sure you want to place this order for Rs ${(total + deliveryCharge).toStringAsFixed(0)}?",
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
      // =========================
      // 1. CREATE THE ORDER (same for all payment methods)
      // For "card", no transactionId/screenshot is sent — the order and
      // its Payment row are created with status "pending", then Stripe
      // takes over.
      // =========================
      final result = await OrderService().checkout(
        customerName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        cityId: selectedCityId!,
        address: addressController.text.trim(),
        paymentMethod: paymentMethod,
        transactionId: paymentMethod == "card"
            ? null
            : transactionIdController.text.trim(),
        imageBytes: paymentMethod == "card" ? null : paymentImageBytes,
        fileName: paymentMethod == "card" ? null : paymentFileName,
        cart: items,
      );

      if (result["success"] != true) {
        setState(() => isLoading = false);
        Get.snackbar(
          "Error",
          _extractErrorMessage(result),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      // =========================
      // 2. IF CARD — open Stripe's payment sheet using the new order's id
      // =========================
      if (paymentMethod == "card") {
        final orderId = result["order"]?["id"] ?? result["order_id"];

        if (orderId == null) {
          setState(() => isLoading = false);
          Get.snackbar(
            "Error",
            "Order created but no order ID returned — cannot start card payment",
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        final intentResult = await PaymentService().createStripePaymentIntent(
          orderId: orderId,
        );

        if (intentResult["success"] != true) {
          setState(() => isLoading = false);
          Get.snackbar(
            "Error",
            intentResult["message"] ?? "Could not start card payment",
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        try {
          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: intentResult["clientSecret"],
              merchantDisplayName: "Rice Mart",
            ),
          );

          await Stripe.instance.presentPaymentSheet();
        } on StripeException catch (e) {
          setState(() => isLoading = false);
          Get.snackbar(
            "Payment Cancelled",
            e.error.localizedMessage ?? "Card payment was not completed",
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        // Payment sheet succeeded on Stripe's side. The order flips to
        // "paid" a moment later once Stripe's webhook reaches the backend
        // — not instantly here.
        setState(() => isLoading = false);

        CartService().clearCart();

        Get.snackbar(
          "Success",
          "Payment submitted — confirming your order...",
          snackPosition: SnackPosition.TOP,
        );

        Get.offAllNamed(AppRoutes.dashboard);
        Get.toNamed(AppRoutes.myOrders);
        return;
      }

      // =========================
      // 3. EASYPAISA / JAZZCASH — same as before
      // =========================
      setState(() => isLoading = false);

      CartService().clearCart();

      Get.snackbar(
        "Success",
        result["message"] ?? "Order placed successfully",
        snackPosition: SnackPosition.TOP,
      );

      Get.offAllNamed(AppRoutes.dashboard);
      Get.toNamed(AppRoutes.myOrders);
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
            style: AppTextStyles.heading3.copyWith(color: AppColors.darkGreen),
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
                      // CITY (delivery charge dropdown)
                      // =========================
                      loadingCities
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          : DropdownButtonFormField<int>(
                              initialValue: selectedCityId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: "Delivery City",
                              ),
                              items: _cities.map<DropdownMenuItem<int>>((city) {
                                return DropdownMenuItem<int>(
                                  value: city['id'],
                                  child: Text(
                                    "${city['name']} (Rs ${city['delivery_charge']})",
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                final city = _cities.firstWhere(
                                  (c) => c['id'] == value,
                                  orElse: () => null,
                                );
                                setState(() {
                                  selectedCityId = value;
                                  final perShopCharge = city != null
                                      ? double.tryParse(
                                              city['delivery_charge']
                                                  .toString(),
                                            ) ??
                                            0
                                      : 0.0;
                                  deliveryCharge =
                                      perShopCharge * distinctShopCount;
                                });
                              },
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
                                Text(
                                  "Subtotal",
                                  style: AppTextStyles.bodyMedium,
                                ),
                                Text(
                                  "Rs ${total.toStringAsFixed(0)}",
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Delivery",
                                  style: AppTextStyles.bodyMedium,
                                ),
                                Text(
                                  "Rs ${deliveryCharge.toStringAsFixed(0)}",
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),

                            const Divider(),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total", style: AppTextStyles.heading3),
                                Text(
                                  "Rs ${(total + deliveryCharge).toStringAsFixed(0)}",
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

                      // =========================
                      // CARD — Stripe test-mode payment
                      // =========================
                      if (paymentMethod == "card")
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: AppDecorations.card,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "You'll be asked for card details on the next step, "
                                "via a secure Stripe payment sheet.",
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Test mode — no real charge occurs.",
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.labelSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Subtotal", style: AppTextStyles.bodyMedium),
                          Text(
                            "Rs ${total.toStringAsFixed(0)}",
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Delivery", style: AppTextStyles.bodyMedium),
                          Text(
                            "Rs ${deliveryCharge.toStringAsFixed(0)}",
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),

                      const Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total", style: AppTextStyles.heading3),
                          Text(
                            "Rs ${(total + deliveryCharge).toStringAsFixed(0)}",
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
