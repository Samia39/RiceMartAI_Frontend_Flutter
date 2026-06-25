// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/themes.dart';
import '../../core/services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameC = TextEditingController();
  final descC = TextEditingController();
  final priceC = TextEditingController();
  final stockC = TextEditingController();
  String category = 'rice';
  File? image;
  bool isLoading = false;

  final categories = ['rice', 'basmati', 'brown rice', 'white rice', 'other'];

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => image = File(picked.path));
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final result = await ProductService.addProduct(
      name: nameC.text,
      description: descC.text,
      price: double.parse(priceC.text),
      stock: int.parse(stockC.text),
      category: category,
      image: image,
    );

    setState(() => isLoading = false);

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product add ho gaya!')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppDecorations.iconButton,
                        child: Icon(Icons.arrow_back,
                            color: AppColors.darkGreen, size: 22),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text('Add Product',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            )),
                      ),
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
                                    child: Image.file(image!,
                                        fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate,
                                          size: 40,
                                          color: AppColors.darkGreen),
                                      const SizedBox(height: 8),
                                      Text('Image Select Karo',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: AppColors.darkGreen)),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildField(nameC, 'Product Name', Icons.rice_bowl),
                        const SizedBox(height: 12),
                        _buildField(descC, 'Description', Icons.description,
                            maxLines: 3),
                        const SizedBox(height: 12),
                        _buildField(priceC, 'Price (Rs.)',
                            Icons.currency_rupee,
                            isNumber: true),
                        const SizedBox(height: 12),
                        _buildField(
                            stockC, 'Stock (kg)', Icons.inventory,
                            isNumber: true),
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
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppColors.darkGreen),
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
                        GestureDetector(
                          onTap: isLoading ? null : submit,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cream.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.borderGold
                                      .withOpacity(0.70)),
                            ),
                            child: Center(
                              child: isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Product Add Karo',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.darkGreen,
                                      )),
                            ),
                          ),
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

  Widget _buildField(
    TextEditingController c,
    String hint,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Container(
      decoration: AppDecorations.inputField,
      child: TextFormField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(fontFamily: 'Poppins', color: AppColors.darkGreen),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.hint,
          prefixIcon: Icon(icon, color: AppColors.iconMuted),
        ),
        validator: (v) => v!.isEmpty ? '$hint required hai' : null,
      ),
    );
  }
}