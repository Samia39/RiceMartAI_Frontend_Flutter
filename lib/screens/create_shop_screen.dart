import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../core/services/shop_service.dart';

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

  final List<Map<String, dynamic>> riceCategories = [];

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
  // Pick rice image
  // -----------------------
  Future<void> pickRiceImage(int index) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      final bytes = await file.readAsBytes();

      setState(() {
        riceCategories[index]["image"] = bytes;
      });
    }
  }

  // -----------------------
  // Add category
  // -----------------------
  void addCategory() {
    setState(() {
      riceCategories.add({
        "nameController": TextEditingController(),
        "priceController": TextEditingController(),
        "stockController": TextEditingController(),
        "image": null,
      });
    });
  }

  void removeCategory(int index) {
    setState(() {
      riceCategories.removeAt(index);
    });
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

    if (riceCategories.isEmpty) {
      Get.snackbar("Error", "Add at least one rice category");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? token = GetStorage().read("token");

      List<Map<String, dynamic>> categoriesPayload = riceCategories.map((rice) {
        return {
          "name": rice["nameController"].text,

          "price_per_kg": rice["priceController"].text,

          "stock_kg": rice["stockController"].text,

          // later can send image path/base64
          "image": null,
        };
      }).toList();

      final result = await ShopService().createShop(
        token: token ?? "",
        cnic: _cnicController.text,
        shopName: _shopController.text,
        ownerName: _ownerController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        description: _descController.text,

        // NEW
        riceCategories: categoriesPayload,
      );
      setState(() {
        isLoading = false;
      });

      if (result["shop"] != null) {
        Get.snackbar("Success", "Shop sent for approval");

        Navigator.pop(context);
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
    return TextFormField(
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

      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon) : null,

        hintText: hint,

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            child,
          ],
        ),
      ),
    );
  }

  Widget categoryCard(int index) {
    var rice = riceCategories[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  "Category ${index + 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                IconButton(
                  onPressed: () {
                    removeCategory(index);
                  },

                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),

            const SizedBox(height: 10),

            inputField(
              controller: rice["nameController"],
              hint: "Rice Name",
              icon: Icons.grain,
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: () {
                pickRiceImage(index);
              },

              child: Container(
                height: 100,
                width: double.infinity,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(),
                ),

                child: rice["image"] != null
                    ? Image.memory(rice["image"], fit: BoxFit.cover)
                    : const Center(child: Text("Upload Rice Image")),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: inputField(
                    controller: rice["stockController"],
                    hint: "Stock",
                    keyboard: TextInputType.number,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: inputField(
                    controller: rice["priceController"],
                    hint: "Price",
                    keyboard: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    addCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Shop")),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
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
                          border: Border.all(),

                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: cnicImage != null
                            ? Image.memory(cnicImage!, fit: BoxFit.cover)
                            : const Center(child: Text("Upload CNIC Image")),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

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

              const SizedBox(height: 18),

              sectionCard(
                title: "Rice Categories",

                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,

                      child: ElevatedButton.icon(
                        onPressed: addCategory,
                        icon: const Icon(Icons.add),
                        label: const Text("Add Category"),
                      ),
                    ),

                    const SizedBox(height: 14),

                    ...riceCategories.asMap().entries.map(
                      (e) => categoryCard(e.key),
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
                      ? const CircularProgressIndicator()
                      : const Text("Create Shop"),
                ),
              ),

              const SizedBox(height: 40),
            ],
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
