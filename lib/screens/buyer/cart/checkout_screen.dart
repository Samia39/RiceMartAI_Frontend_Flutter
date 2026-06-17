import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/cart_service.dart';
import '../../../core/services/order_service.dart';
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
  final addressController = TextEditingController();
  final transactionIdController = TextEditingController();

  // =========================
  // PAYMENT METHOD
  // =========================
  String paymentMethod = "easypaisa";

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
  // PLACE ORDER
  // =========================
  Future<void> placeOrder() async {
    // =========================
    // BASIC VALIDATION
    // =========================
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
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
          result["message"] ?? "Checkout failed",
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Checkout")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // =========================
              // NAME
              // =========================
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Customer Name"),
              ),

              const SizedBox(height: 16),

              // =========================
              // PHONE
              // =========================
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone Number"),
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
                    Text("Order Summary", style: AppTextStyles.heading3),

                    const SizedBox(height: 15),

                    ...cart.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["name"] ?? "",
                                    style: AppTextStyles.heading4,
                                  ),

                                  Text(
                                    "Shop: ${item["shop"]?["shop_name"] ?? "-"}",
                                  ),
                                ],
                              ),
                            ),

                            Text("x${item["quantity"]}"),

                            const SizedBox(width: 15),

                            Text("Rs ${item["price"]}"),
                          ],
                        ),
                      );
                    }).toList(),

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

              Align(
                alignment: Alignment.centerLeft,
                child: Text("Payment Method", style: AppTextStyles.heading4),
              ),

              const SizedBox(height: 10),

              RadioListTile(
                value: "easypaisa",
                groupValue: paymentMethod,
                title: const Text("EasyPaisa"),
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value!;
                  });
                },
              ),

              RadioListTile(
                value: "jazzcash",
                groupValue: paymentMethod,
                title: const Text("JazzCash"),
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value!;
                  });
                },
              ),

              RadioListTile(
                value: "card",
                groupValue: paymentMethod,
                title: const Text("Card"),
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              if (paymentMethod == "easypaisa" || paymentMethod == "jazzcash")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Send Payment To:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),

                    const Text("03XX-XXXXXXX"),

                    const SizedBox(height: 20),

                    TextField(
                      controller: transactionIdController,
                      decoration: const InputDecoration(
                        labelText: "Transaction ID",
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
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
                  child: const Text(
                    "Card payment gateway will be integrated in future versions. "
                    "For project demonstration, card payment is shown as a UI option.",
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
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : placeOrder,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Place Order"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
