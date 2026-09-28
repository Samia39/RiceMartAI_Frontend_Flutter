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
  // change for strip
  int? _pendingCardOrderId;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final CityService _cityService = CityService();
  List _cities = [];
  int? selectedCityId;
  bool loadingCities = true;
  final addressController = TextEditingController();
  final transactionIdController = TextEditingController();

  String paymentMethod = "easypaisa";

  // payment setting EasyPaisa / JazzCash numbers, admin-managed

  Map<String, dynamic>? paymentSettings;
  bool loadingPaymentSettings = true;

  Uint8List? paymentImageBytes;
  String? paymentFileName;

  List cart = [];

  double get deliveryCharge {
    if (selectedCityId == null) return 0;
    final city = _cities.firstWhere(
      (c) => c['id'] == selectedCityId,
      orElse: () => null,
    );
    if (city == null) return 0;

    final base = double.tryParse(city['delivery_charge'].toString()) ?? 0;
    final extraPercent = double.tryParse(city['extra_percent'].toString()) ?? 0;
    final perKgExtra = base * (extraPercent / 100);

    final Map<dynamic, double> shopWeights = {};
    for (final item in cart) {
      final shopId = item["shop"]?["id"] ?? item["shop_id"];
      if (shopId == null) continue;
      final qty = (item["quantity"] as num).toDouble();
      shopWeights[shopId] = (shopWeights[shopId] ?? 0) + qty;
    }

    double total = 0;
    for (final weight in shopWeights.values) {
      final extraKg = weight > 1 ? weight - 1 : 0;
      total += base + (perKgExtra * extraKg);
    }
    return total;
  }

  Map<String, double> get shopDeliveryBreakdown {
    if (selectedCityId == null) return {};
    final city = _cities.firstWhere(
      (c) => c['id'] == selectedCityId,
      orElse: () => null,
    );
    if (city == null) return {};

    final base = double.tryParse(city['delivery_charge'].toString()) ?? 0;
    final extraPercent = double.tryParse(city['extra_percent'].toString()) ?? 0;
    final perKgExtra = base * (extraPercent / 100);

    final Map<String, double> shopWeights = {};
    final Map<String, String> shopNames = {};

    for (final item in cart) {
      final shopId = (item["shop"]?["id"] ?? item["shop_id"])?.toString();
      if (shopId == null) continue;
      final qty = (item["quantity"] as num).toDouble();
      shopWeights[shopId] = (shopWeights[shopId] ?? 0) + qty;
      shopNames[shopId] = item["shop"]?["shop_name"] ?? "Shop";
    }

    final Map<String, double> breakdown = {};
    shopWeights.forEach((shopId, weight) {
      final extraKg = weight > 1 ? weight - 1 : 0;
      final charge = base + (perKgExtra * extraKg);
      breakdown[shopNames[shopId] ?? "Shop"] = charge;
    });

    return breakdown;
  }

  List<Map<String, dynamic>> get groupedByShop {
    final Map<String, List> shopItems = {};
    final Map<String, String> shopNames = {};

    for (final item in cart) {
      final shopId = (item["shop"]?["id"] ?? item["shop_id"])?.toString();
      if (shopId == null) continue;
      shopItems.putIfAbsent(shopId, () => []).add(item);
      shopNames[shopId] = item["shop"]?["shop_name"] ?? "Shop";
    }

    final breakdown = shopDeliveryBreakdown;

    return shopItems.entries.map((entry) {
      final items = entry.value;
      final shopName = shopNames[entry.key] ?? "Shop";
      final shopSubtotal = items.fold<double>(0, (sum, item) {
        final price = double.tryParse(item["price"].toString()) ?? 0;
        final qty = double.tryParse(item["quantity"].toString()) ?? 0;
        return sum + (price * qty);
      });
      final shopDelivery = breakdown[shopName] ?? 0;

      return {
        "shopName": shopName,
        "items": items,
        "subtotal": shopSubtotal,
        "delivery": shopDelivery,
        "shopTotal": shopSubtotal + shopDelivery,
      };
    }).toList();
  }

  // =========================
  // SUBTOTAL
  // =========================
  double get subtotal => Get.find<CartService>().totalPrice();

  // =========================
  // TOTAL (subtotal + delivery)
  // =========================
  double get total => subtotal + deliveryCharge;

  // =========================
  // LOADING
  // =========================
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    cart = Get.find<CartService>().getCart();

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
    // change for strip
    if (_pendingCardOrderId != null) {
      OrderService().cancelUnpaidOrder(_pendingCardOrderId!);
    }
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    transactionIdController.dispose();
    super.dispose();
  }

  // =========================
  // LOAD PAYMENT SETTINGS
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

      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 800,
        maxHeight: 800,
      );

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
    int? orderId;

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

    if (paymentMethod == "card") {
      Get.snackbar(
        "Test Environment",
        "Stripe is currently in demo mode. Please select Cash/Easypaisa to place an order. Card payments will be available in the future.",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
      return;
    }

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
      // 2. IF CARD open Stripe's payment sheet using the new order's id
      // =========================
      if (paymentMethod == "card") {
        orderId = result["order"]?["id"] ?? result["order_id"];
        // change for strip
        _pendingCardOrderId = orderId;

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
          await OrderService().cancelUnpaidOrder(orderId);
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
          await OrderService().cancelUnpaidOrder(orderId);
          setState(() => isLoading = false);
          Get.snackbar(
            "Order Not Placed",
            "Order can't be placed. Card payment is not in production mode.",
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
          );
          return;
        }

        // change for strip
        await OrderService().cancelUnpaidOrder(orderId);
        _pendingCardOrderId = null;
        setState(() => isLoading = false);

        Get.snackbar(
          "Test Environment",
          "This is a test Stripe environment. Orders cannot be placed and will be available in the future.",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      // =========================
      // EASYPAISA / JAZZCASH
      // =========================
      setState(() => isLoading = false);

      Get.find<CartService>().clearCart();

      Get.snackbar(
        "Success",
        result["message"] ?? "Order placed successfully",
        snackPosition: SnackPosition.TOP,
      );

      Get.offAllNamed(AppRoutes.dashboard, arguments: {'tabIndex': 3});
    } catch (e) {
      if (paymentMethod == "card" && orderId != null) {
        await OrderService().cancelUnpaidOrder(orderId);
      }

      setState(() {
        isLoading = false;
      });

      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // =========================
  // SEND PAYMENT TO  dynamic number/account name per method
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

            // =========================
            // FORM FIELDS (name, phone, city, address)
            // =========================
            final formFields = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Customer Name"),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: "Phone Number"),
                ),

                const SizedBox(height: 16),

                loadingCities
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCityId = value;
                          });
                        },
                      ),

                const SizedBox(height: 16),

                TextField(
                  controller: addressController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "Address"),
                ),
              ],
            );

            // =========================
            // ORDER SUMMARY
            // =========================
            final orderSummaryCard = Container(
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order Summary", style: AppTextStyles.heading3),

                  const SizedBox(height: 15),

                  ...groupedByShop.map((shop) {
                    final items = shop["items"] as List;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.overlayLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.borderGold.withOpacity(0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop["shopName"],
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item["name"] ?? "",
                                        style: AppTextStyles.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "x${item["quantity"]}  Rs ${item["price"]}",
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Subtotal",
                                  style: AppTextStyles.bodySmall,
                                ),
                                Text(
                                  "Rs ${(shop["subtotal"] as double).toStringAsFixed(0)}",
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Delivery",
                                  style: AppTextStyles.bodySmall,
                                ),
                                Text(
                                  "Rs ${(shop["delivery"] as double).toStringAsFixed(0)}",
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Shop Total",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "Rs ${(shop["shopTotal"] as double).toStringAsFixed(0)}",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const Divider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Subtotal", style: AppTextStyles.bodyMedium),
                      Text(
                        "Rs ${subtotal.toStringAsFixed(0)}",
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Delivery", style: AppTextStyles.bodyMedium),
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
                        "Rs ${total.toStringAsFixed(0)}",
                        style: AppTextStyles.heading3,
                      ),
                    ],
                  ),
                ],
              ),
            );

            // =========================
            // PAYMENT METHOD SECTION
            // =========================
            final paymentMethodSection = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                        title: Text("JazzCash", style: AppTextStyles.bodyLarge),
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
                        title: Text("Card", style: AppTextStyles.bodyLarge),
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

                if (paymentMethod == "easypaisa" || paymentMethod == "jazzcash")
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
              ],
            );

            // =========================
            // PLACE ORDER BUTTON
            // =========================
            final placeOrderButton = SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : placeOrder,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Place Order"),
              ),
            );

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 40 : 16,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 1100 : 600),
                  child: isWide
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [formFields],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(flex: 2, child: orderSummaryCard),
                              ],
                            ),
                            const SizedBox(height: 24),
                            paymentMethodSection,
                            const SizedBox(height: 24),
                            placeOrderButton,
                            const SizedBox(height: 16),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            formFields,
                            const SizedBox(height: 24),
                            orderSummaryCard,
                            const SizedBox(height: 24),
                            paymentMethodSection,
                            const SizedBox(height: 24),
                            placeOrderButton,
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
