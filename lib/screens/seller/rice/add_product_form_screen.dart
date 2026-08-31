import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/product_service.dart';
import '../../../core/utils/themes.dart';

class AddProductFormScreen extends StatefulWidget {
  const AddProductFormScreen({super.key});

  // Reached via Get.toNamed(AppRoutes.sellerAddProductForm, arguments: shopId)
  int get shopId => Get.arguments as int;

  @override
  State<AddProductFormScreen> createState() => _AddProductFormScreenState();
}

class _AddProductFormScreenState extends State<AddProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final productNameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  bool isLoading = false;
  bool categoriesLoading = true;

  List<Map<String, dynamic>> categories = [];

  int? selectedCategoryId;

  Uint8List? selectedImage;
  String? selectedImageName;

  String? imageError;

  // =========================
  // INIT
  // =========================

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  // =========================
  // LOAD CATEGORIES
  // =========================

  Future<void> loadCategories() async {
    try {
      final data = await ProductService().fetchCategories();

      if (!mounted) return;

      setState(() {
        categories = data;
        categoriesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        categoriesLoading = false;
      });

      Get.snackbar(
        "Error",
        "Unable to load rice categories",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =========================
  // PICK IMAGE
  // =========================

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();

      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1200,
      );

      if (picked == null) {
        return;
      }

      final bytes = await picked.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImage = bytes;
        selectedImageName = picked.name;
        imageError = null;
      });
    } catch (e) {
      Get.snackbar(
        "Error",
        "Unable to select image",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =========================
  // ADD PRODUCT
  // =========================

  Future<void> addProduct() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate image
    if (selectedImage == null) {
      setState(() {
        imageError = "Product image is required";
      });

      Get.snackbar(
        "Required",
        "Please add a product image",
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    // Validate category
    if (selectedCategoryId == null) {
      Get.snackbar(
        "Required",
        "Please select a rice category",
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final storage = GetStorage();

      final token = storage.read("token");

      if (token == null || token.toString().isEmpty) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        Get.snackbar(
          "Error",
          "Authentication token not found. Please login again.",
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      final result = await ProductService().addProduct(
        token: token.toString(),
        shopId: widget.shopId,
        riceCategoryId: selectedCategoryId!,
        name: productNameController.text.trim(),
        price: priceController.text.trim(),
        stock: stockController.text.trim(),
        imageBytes: selectedImage!,
        imageName: selectedImageName ?? "product.jpg",
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (result["success"] == true && result["product"] != null) {
        Get.snackbar(
          "Success",
          "Product added successfully",
          snackPosition: SnackPosition.BOTTOM,
        );

        Navigator.pop(context, true);
      } else {
        Get.snackbar(
          "Error",
          result["message"]?.toString() ?? "Failed to add product",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      Get.snackbar(
        "Error",
        "Something went wrong. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =========================
  // REQUIRED LABEL
  // =========================

  Widget requiredLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: RichText(
        text: TextSpan(
          text: text,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          children: const [
            TextSpan(
              text: " *",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // INPUT FIELD
  // =========================

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        requiredLabel(label),

        Container(
          decoration: AppDecorations.inputField,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboard,

            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "This field is required";
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
        ),
      ],
    );
  }

  // =========================
  // CATEGORY FIELD
  // =========================

  Widget categoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        requiredLabel("Rice Category"),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: AppDecorations.inputField,

          child: categoriesLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : DropdownButtonFormField<int>(
                  initialValue: selectedCategoryId,

                  decoration: const InputDecoration(border: InputBorder.none),

                  hint: const Text("Select Rice Category"),

                  validator: (value) {
                    if (value == null) {
                      return "Please select a category";
                    }

                    return null;
                  },

                  items: categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: int.tryParse(category["id"].toString()),
                      child: Text(category["name"].toString()),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                ),
        ),
      ],
    );
  }

  // =========================
  // IMAGE PICKER
  // =========================

  Widget imagePickerField() {
    final hasError = imageError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        requiredLabel("Product Image"),

        GestureDetector(
          onTap: pickImage,

          child: Container(
            height: 190,
            width: double.infinity,

            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(16),

              border: Border.all(
                color: hasError
                    ? Colors.red
                    : AppColors.darkGreen.withOpacity(0.3),

                width: hasError ? 1.5 : 1,
              ),
            ),

            child: selectedImage != null
                ? Stack(
                    fit: StackFit.expand,

                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),

                        child: Image.memory(selectedImage!, fit: BoxFit.cover),
                      ),

                      // Remove image
                      Positioned(
                        top: 8,
                        left: 8,

                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImage = null;
                              selectedImageName = null;
                              imageError = "Product image is required";
                            });
                          },

                          child: Container(
                            padding: const EdgeInsets.all(8),

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

                      // Change image
                      Positioned(
                        top: 8,
                        right: 8,

                        child: GestureDetector(
                          onTap: pickImage,

                          child: Container(
                            padding: const EdgeInsets.all(8),

                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.edit,
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
                      Icon(
                        Icons.add_a_photo,
                        size: 42,

                        color: hasError ? Colors.red : AppColors.darkGreen,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Tap to add product image",
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Image is required",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: hasError ? Colors.red : AppColors.iconMuted,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        if (imageError != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 6),

            child: Text(
              imageError!,

              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    productNameController.dispose();
    priceController.dispose();
    stockController.dispose();

    super.dispose();
  }

  // =========================
  // BUILD
  // =========================

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
                          // Required note
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.06),

                              borderRadius: BorderRadius.circular(10),

                              border: Border.all(
                                color: Colors.red.withOpacity(0.2),
                              ),
                            ),

                            child: Row(
                              children: [
                                const Text(
                                  "*",

                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(width: 6),

                                Expanded(
                                  child: Text(
                                    "Fields marked with * are required",

                                    style: AppTextStyles.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Image
                          imagePickerField(),

                          const SizedBox(height: 18),

                          // Category
                          categoryField(),

                          const SizedBox(height: 16),

                          // Product name
                          inputField(
                            controller: productNameController,
                            label: "Product Name",
                            hint: "Enter product name",
                            icon: Icons.rice_bowl,
                          ),

                          const SizedBox(height: 16),

                          // Price
                          inputField(
                            controller: priceController,
                            label: "Price Per KG",
                            hint: "Enter price per KG",
                            icon: Icons.currency_rupee,
                            keyboard: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Stock
                          inputField(
                            controller: stockController,
                            label: "Stock KG",
                            hint: "Enter available stock",
                            icon: Icons.inventory,
                            keyboard: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Add button
                          SizedBox(
                            height: 52,

                            child: ElevatedButton(
                              onPressed: isLoading ? null : addProduct,

                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,

                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
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
