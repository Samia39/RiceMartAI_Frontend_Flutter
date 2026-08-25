import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/product_service.dart';
import '../../../core/utils/themes.dart';

class AddProductFormScreen extends StatefulWidget {
  final int shopId;

  const AddProductFormScreen({super.key, required this.shopId});

  @override
  State<AddProductFormScreen> createState() => _AddProductFormScreenState();
}

class _AddProductFormScreenState extends State<AddProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final productNameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  bool isLoading = false;

  List<Map<String, dynamic>> categories = [];

  int? selectedCategoryId;
  String? selectedCategoryName;

  Uint8List? selectedImage;

  // =========================
  // PICK IMAGE
  // =========================
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1200,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        selectedImage = bytes;
      });
    }
  }

  // =========================
  // LOAD CATEGORIES
  // =========================
  Future<void> loadCategories() async {
    final data = await ProductService().fetchCategories();

    setState(() {
      categories = data;
    });
  }

  // =========================
  // ADD PRODUCT
  // =========================
  Future<void> addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategoryId == null) {
      Get.snackbar("Error", "Select category");
      return;
    }

    setState(() {
      isLoading = true;
    });

    String token = GetStorage().read("token") ?? "";

    final result = await ProductService().addProduct(
      token: token,
      shopId: widget.shopId,
      riceCategoryId: selectedCategoryId!,
      name: productNameController.text,
      price: priceController.text,
      stock: stockController.text,
      imageBytes: selectedImage,
      imageName: 'product.jpg',
    );

    setState(() {
      isLoading = false;
    });

    if (result["product"] != null) {
      Get.snackbar("Success", "Product Added");
      if (mounted) Navigator.pop(context, true);
    } else {
      Get.snackbar(
        "Error",
        result["message"]?.toString() ?? "Failed to add product",
      );
    }
  }

  // =========================
  // INPUT FIELD
  // =========================
  Widget inputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      decoration: AppDecorations.inputField,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) {
          if (v == null || v.isEmpty) {
            return "Required";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null
              ? Icon(icon, color: AppColors.darkGreen)
              : null,
        ),
      ),
    );
  }

  // =========================
  // IMAGE PICKER WIDGET
  // =========================
  Widget imagePickerField() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkGreen.withOpacity(0.3)),
        ),
        child: selectedImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(selectedImage!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedImage = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 40, color: AppColors.darkGreen),
                  const SizedBox(height: 10),
                  Text(
                    "Tap to add product image",
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  @override
  void dispose() {
    productNameController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Add Product")),
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
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: AppDecorations.card,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          imagePickerField(),

                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: AppDecorations.inputField,
                            child: DropdownButtonFormField<int>(
                              value: selectedCategoryId,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              hint: const Text("Select Rice Category"),
                              items: categories.map((category) {
                                return DropdownMenuItem<int>(
                                  value: category["id"],
                                  child: Text(category["name"]),
                                );
                              }).toList(),
                              onChanged: (value) {
                                final category = categories.firstWhere(
                                  (e) => e["id"] == value,
                                );

                                setState(() {
                                  selectedCategoryId = value;
                                  selectedCategoryName = category["name"];
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          inputField(
                            controller: productNameController,
                            hint: "Product Name",
                            icon: Icons.rice_bowl,
                          ),

                          const SizedBox(height: 14),

                          inputField(
                            controller: priceController,
                            hint: "Price Per KG",
                            icon: Icons.currency_rupee,
                            keyboard: TextInputType.number,
                          ),

                          const SizedBox(height: 14),

                          inputField(
                            controller: stockController,
                            hint: "Stock KG",
                            icon: Icons.inventory,
                            keyboard: TextInputType.number,
                          ),

                          const SizedBox(height: 22),

                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : addProduct,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: AppColors.darkGreen,
                                    )
                                  : const Text("Add Product"),
                            ),
                          ),
                        ],
                      ),
                    ),
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
