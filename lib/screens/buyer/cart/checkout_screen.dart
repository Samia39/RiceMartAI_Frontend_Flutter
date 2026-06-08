import 'dart:io';

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

  // =========================
  // PAYMENT METHOD
  // =========================
  String paymentMethod = "easypaisa";

  // =========================
  // PAYMENT IMAGE
  // =========================
  File? paymentImage;

  // =========================
  // TOTAL
  // =========================
  double total = 0;

  // =========================
  // CART
  // =========================
  List cart = [];

  @override
  void initState() {
    super.initState();

    cart = CartService().getCart();

    total = CartService().totalPrice();
  }

  // =========================
  // PICK IMAGE
  // =========================
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        paymentImage = File(pickedFile.path);
      });
    }
  }

  // =========================
  // PLACE ORDER
  // =========================
  Future<void> placeOrder() async {
    // SIMPLE VALIDATION
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");

      return;
    }

    // CHECK SCREENSHOT
    if ((paymentMethod == "easypaisa" || paymentMethod == "jazzcash") &&
        paymentImage == null) {
      Get.snackbar("Error", "Please upload payment screenshot");

      return;
    }

    // =========================
    // CONVERT CART
    // =========================
    List items = cart.map((item) {
      return {"product_id": item["id"], "quantity": item["quantity"]};
    }).toList();

    // =========================
    // API CALL
    // =========================
    final result = await OrderService().checkout(
      customerName: nameController.text,

      phone: phoneController.text,

      address: addressController.text,

      paymentMethod: paymentMethod,

      paymentProof: paymentImage,

      cart: items,
    );

    // =========================
    // SUCCESS
    // =========================
    if (result["success"] == true) {
      CartService().clearCart();

      Get.snackbar("Success", "Order placed successfully");

      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.snackbar("Error", result["message"] ?? "Checkout failed");
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
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =========================
              // NAME
              // =========================
              TextField(
                controller: nameController,

                style: const TextStyle(color: Colors.black),

                decoration: InputDecoration(
                  labelText: "Full Name",

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // =========================
              // PHONE
              // =========================
              TextField(
                controller: phoneController,

                style: const TextStyle(color: Colors.black),

                decoration: InputDecoration(
                  labelText: "Phone Number",

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // =========================
              // ADDRESS
              // =========================
              TextField(
                controller: addressController,

                maxLines: 3,

                style: const TextStyle(color: Colors.black),

                decoration: InputDecoration(
                  labelText: "Address",

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // PAYMENT METHOD
              // =========================
              Text("Select Payment Method", style: AppTextStyles.heading4),

              const SizedBox(height: 10),

              RadioListTile(
                value: "easypaisa",

                groupValue: paymentMethod,

                onChanged: (value) {
                  setState(() {
                    paymentMethod = value!;
                  });
                },

                title: const Text("EasyPaisa"),
              ),

              RadioListTile(
                value: "jazzcash",

                groupValue: paymentMethod,

                onChanged: (value) {
                  setState(() {
                    paymentMethod = value!;
                  });
                },

                title: const Text("JazzCash"),
              ),

              RadioListTile(
                value: "card",

                groupValue: paymentMethod,

                onChanged: (value) {
                  setState(() {
                    paymentMethod = value!;
                  });
                },

                title: const Text("Card"),
              ),

              const SizedBox(height: 20),

              // =========================
              // EASYPAISA/JAZZCASH
              // =========================
              if (paymentMethod == "easypaisa" || paymentMethod == "jazzcash")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text("Send payment to:", style: AppTextStyles.bodyLarge),

                    const SizedBox(height: 8),

                    const Text("03XX-XXXXXXX"),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: pickImage,

                      child: Text(
                        paymentImage == null
                            ? "Upload Screenshot"
                            : "Screenshot Selected",
                      ),
                    ),
                  ],
                ),

              // =========================
              // CARD FIELDS
              // ========================
              const SizedBox(height: 30),

              // =========================
              // TOTAL
              // =========================
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

              // =========================
              // PLACE ORDER BUTTON
              // =========================
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  onPressed: placeOrder,

                  child: const Text("Place Order"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
