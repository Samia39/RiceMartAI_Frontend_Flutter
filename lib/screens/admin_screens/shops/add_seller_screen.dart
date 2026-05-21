import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/themes.dart';
import '../../../controllers/admin/add_seller_controller.dart';

class AddSellerScreen extends StatefulWidget {
  const AddSellerScreen({super.key});

  @override
  State<AddSellerScreen> createState() => _AddSellerScreenState();
}

class _AddSellerScreenState extends State<AddSellerScreen> {
  final controller = Get.put(AddSellerController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text("Add Seller"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              // =========================
              // USER INFO
              // =========================
              buildField(controller.nameController, "Full Name"),

              buildField(controller.emailController, "Email"),

              buildField(
                controller.passwordController,
                "Password",
                obscure: true,
              ),

              const SizedBox(height: 20),

              // =========================
              // SHOP INFO
              // =========================
              buildField(controller.shopNameController, "Shop Name"),

              buildField(controller.ownerNameController, "Owner Name"),

              buildField(controller.phoneController, "Phone Number"),

              buildField(controller.addressController, "Address"),

              buildField(controller.cnicController, "CNIC (35202-1234567-1)"),

              buildField(
                controller.descriptionController,
                "Description",
                maxLines: 3,
              ),

              const SizedBox(height: 15),

              // =========================
              // IMAGE PICKER
              // =========================
              Obx(() {
                return GestureDetector(
                  onTap: controller.pickImage,

                  child: Container(
                    height: 170,
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.darkGreen),
                    ),

                    child: controller.cnicImage.value == null
                        ? const Center(
                            child: Text(
                              "Upload CNIC Image",
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(
                              controller.cnicImage.value!.path,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                );
              }),

              const SizedBox(height: 25),

              // =========================
              // BUTTON
              // =========================
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.createSeller,

                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Create Seller",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // INPUT FIELD
  // =========================

  Widget buildField(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: TextField(
        controller: controller,
        obscureText: obscure,
        maxLines: maxLines,

        decoration: InputDecoration(
          hintText: hint,

          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
