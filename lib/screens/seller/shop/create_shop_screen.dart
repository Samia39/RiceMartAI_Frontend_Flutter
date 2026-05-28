import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/services/shop_service.dart';
import '../../../core/utils/themes.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();

  final _cnicController = TextEditingController();
  final _shopController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Uint8List? cnicImage;
  bool isLoading = false;

  // -----------------------
  // Pick CNIC
  // -----------------------
  Future<void> pickCnic() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      final bytes = await file.readAsBytes();

      setState(() {
        cnicImage = bytes;
      });
    }
  }

  // -----------------------
  // Create Shop
  // -----------------------
  Future<void> createShop() async {
    if (!_formKey.currentState!.validate()) return;

    if (cnicImage == null) {
      Get.snackbar(
        "Error",
        "Upload CNIC image",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? token = GetStorage().read("token");

      final result = await ShopService().createShop(
        token: token ?? "",
        cnic: _cnicController.text,
        shopName: _shopController.text,
        ownerName: _ownerController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        description: _descController.text,
      );

      setState(() {
        isLoading = false;
      });

      if (result["shop"] != null) {
        final box = GetStorage();

        box.write("has_shop", true);

        box.write("shop_approved", false);

        box.write("shop_id", result["shop"]["id"]);
        // SAVE SHOP DATA
        box.write("shop_name", _shopController.text);
        box.write("owner_name", _ownerController.text);
        box.write("phone", _phoneController.text);
        box.write("address", _addressController.text);
        box.write("description", _descController.text);

        Get.snackbar("Success", "Shop sent for approval");
      } else {
        Get.snackbar("Error", result["message"] ?? "Failed");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      Get.snackbar("Error", "Server error");
    }
  }

  // -----------------------
  // Reusable field
  // -----------------------
  Widget inputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int lines = 1,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? formatters,
  }) {
    return Container(
      decoration: AppDecorations.inputField,

      child: TextFormField(
        controller: controller,
        maxLines: lines,
        keyboardType: keyboard,
        inputFormatters: formatters,

        validator: (v) {
          if (v == null || v.isEmpty) {
            return "Required";
          }
          return null;
        },

        style: AppTextStyles.bodyLarge,

        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: AppColors.darkGreen)
              : null,

          hintText: hint,
        ),
      ),
    );
  }

  Widget sectionCard({required String title, required Widget child}) {
    return Container(
      decoration: AppDecorations.card,

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(title, style: AppTextStyles.heading3),

            const SizedBox(height: 16),

            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Create Shop")),

        body: Form(
          key: _formKey,

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
                // -----------------------
                // CNIC Information
                // -----------------------
                sectionCard(
                  title: "CNIC Information",

                  child: Column(
                    children: [
                      inputField(
                        controller: _cnicController,
                        hint: "12345-1234567-1",
                        icon: Icons.badge,
                        keyboard: TextInputType.number,
                        formatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                        ],
                      ),

                      const SizedBox(height: 15),

                      GestureDetector(
                        onTap: pickCnic,

                        child: Container(
                          height: 120,
                          width: double.infinity,

                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.inputBorder),
                          ),

                          child: cnicImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    cnicImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    "Upload CNIC Image",
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // -----------------------
                // Shop Information
                // -----------------------
                sectionCard(
                  title: "Shop Information",

                  child: Column(
                    children: [
                      inputField(
                        controller: _shopController,
                        hint: "Shop Name",
                        icon: Icons.store,
                      ),

                      const SizedBox(height: 12),

                      inputField(
                        controller: _ownerController,
                        hint: "Owner Name",
                        icon: Icons.person,
                      ),

                      const SizedBox(height: 12),

                      inputField(
                        controller: _phoneController,
                        hint: "Phone",
                        icon: Icons.phone,
                      ),

                      const SizedBox(height: 12),

                      inputField(
                        controller: _addressController,
                        hint: "Address",
                        icon: Icons.location_on,
                      ),

                      const SizedBox(height: 12),

                      inputField(
                        controller: _descController,
                        hint: "Description",
                        icon: Icons.info,
                        lines: 4,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    onPressed: isLoading ? null : createShop,

                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.darkGreen,
                          )
                        : const Text("Create Shop"),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cnicController.dispose();
    _shopController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descController.dispose();

    super.dispose();
  }
}
