// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/themes.dart';
import '../../core/services/product_service.dart';
import '../../models/product_model.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_nav.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameC;
  late TextEditingController descC;
  late TextEditingController priceC;
  late TextEditingController stockC;
  late String category;
  File? image;
  bool isLoading = false;
  late Product product;

  final categories = [
    'rice', 'basmati', 'brown rice', 'white rice', 'other'
  ];

  @override
  void initState() {
    super.initState();
    product = Get.arguments as Product;
    nameC = TextEditingController(text: product.name);
    descC = TextEditingController(text: product.description);
    priceC = TextEditingController(text: product.price.toString());
    stockC = TextEditingController(text: product.stock.toString());
    category = product.category;
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => image = File(picked.path));
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final success = await ProductService.updateProduct(
      id: product.id,
      name: nameC.text,
      description: descC.text,
      price: double.parse(priceC.text),
      stock: int.parse(stockC.text),
      category: category,
      image: image,
    );

    setState(() => isLoading = false);

    if (success) {
      Get.snackbar('Success', 'Product update ho gaya!',
          backgroundColor: AppColors.cream);
      Get.back();
    } else {
      Get.snackbar('Error', 'Kuch masla hua!',
          backgroundColor: AppColors.cream);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      bottomNavigationBar: const BottomNav(currentIndex: 1),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppDecorations.iconButton,
                        child: Icon(Icons.arrow_back,
                            color: AppColors.darkGreen, size: 24),
                      ),
                    ),
                    Column(
                      children: [
                        Text('Seller Panel',
                            style: AppTextStyles.bodyMedium),
                        Text('Edit Product', style: AppTextStyles.heading3),
                      ],
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: AppDecorations.card,
                            child: image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(image!, fit: BoxFit.cover),
                                  )
                                : product.image != null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        child: Image.network(
                                          'http://10.0.2.2/sheezabackend/public/storage/${product.image}',
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _noImage(),
                                        ),
                                      )
                                    : _noImage(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildField(nameC, 'Product Name', Icons.rice_bowl),
                        const SizedBox(height: 12),
                        _buildField(descC, 'Description',
                            Icons.description, maxLines: 3),
                        const SizedBox(height: 12),
                        _buildField(priceC, 'Price (Rs.)',
                            Icons.currency_rupee, isNumber: true),
                        const SizedBox(height: 12),
                        _buildField(stockC, 'Stock (kg)',
                            Icons.inventory, isNumber: true),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: AppDecorations.inputField,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: category,
                              isExpanded: true,
                              icon: Icon(Icons.keyboard_arrow_down,
                                  color: AppColors.darkGreen),
                              style: AppTextStyles.bodyLarge,
                              items: categories
                                  .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c.toUpperCase())))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => category = val!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: isLoading ? null : submit,
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : Text('Update Karo',
                                  style: AppTextStyles.button),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController c, String hint, IconData icon,
      {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: AppDecorations.inputField,
      child: TextFormField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.hint,
          prefixIcon: Icon(icon, color: AppColors.iconMuted),
        ),
        validator: (v) => v!.isEmpty ? '$hint required hai' : null,
      ),
    );
  }

  Widget _noImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 40, color: AppColors.darkGreen),
        const SizedBox(height: 8),
        Text('Image Change Karo', style: AppTextStyles.label),
      ],
    );
  }
}