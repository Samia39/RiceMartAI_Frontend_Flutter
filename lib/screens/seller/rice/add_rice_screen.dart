import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/services/product_service.dart';
import '../../../core/utils/themes.dart';

class AddRiceScreen extends StatefulWidget {
  const AddRiceScreen({super.key});

  @override
  State<AddRiceScreen> createState() => _AddRiceScreenState();
}

class _AddRiceScreenState extends State<AddRiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final productNameController = TextEditingController();

  final priceController = TextEditingController();

  final stockController = TextEditingController();

  bool isLoading = false;

  List<Map<String, dynamic>> productList = [];

  List<Map<String, dynamic>> categories = [];

  int? selectedCategoryId;

  String? selectedCategoryName;

  int? shopId;

  // =========================
  // LOAD SHOP ID
  // =========================
  Future<void> loadShopId() async {
    final box = GetStorage();

    shopId = box.read("shop_id");

    if (shopId != null) {
      fetchProducts();
    }

    setState(() {});
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
  // FETCH PRODUCTS
  // =========================
  Future<void> fetchProducts() async {
    final data = await ProductService().fetchShopProducts(shopId: shopId!);

    setState(() {
      productList = data;
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

    if (shopId == null) {
      Get.snackbar("Error", "No approved shop found");

      return;
    }

    setState(() {
      isLoading = true;
    });

    String token = GetStorage().read("token") ?? "";

    final result = await ProductService().addProduct(
      token: token,

      shopId: shopId!,

      riceCategoryId: selectedCategoryId!,

      name: productNameController.text,

      price: priceController.text,

      stock: stockController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (result["product"] != null) {
      Get.snackbar("Success", "Product Added");

      selectedCategoryId = null;

      selectedCategoryName = null;

      productNameController.clear();

      priceController.clear();

      stockController.clear();

      fetchProducts();

      setState(() {});
    }
  }

  // =========================
  // DELETE PRODUCT
  // =========================
  Future<void> deleteProduct(int productId) async {
    String token = GetStorage().read("token") ?? "";

    await ProductService().deleteProduct(token: token, productId: productId);

    fetchProducts();

    Get.snackbar("Deleted", "Product removed");
  }

  // =========================
  // EDIT PRODUCT
  // =========================
  void editRiceDialog(Map<String, dynamic> product) {
    final editPriceController = TextEditingController(
      text: product["price"].toString(),
    );

    final editStockController = TextEditingController(
      text: product["stock"].toString(),
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.cream,

          title: const Text("Edit Product", style: AppTextStyles.heading4),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                decoration: AppDecorations.inputField,

                child: TextField(
                  controller: editPriceController,
                  keyboardType: TextInputType.number,

                  decoration: const InputDecoration(
                    hintText: "Price",
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Container(
                decoration: AppDecorations.inputField,

                child: TextField(
                  controller: editStockController,
                  keyboardType: TextInputType.number,

                  decoration: const InputDecoration(
                    hintText: "Stock",
                    prefixIcon: Icon(Icons.inventory),
                  ),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                String token = GetStorage().read("token") ?? "";

                await ProductService().updateProduct(
                  token: token,

                  productId: product["id"],

                  price: editPriceController.text,

                  stock: editStockController.text,
                );

                Navigator.pop(context);

                fetchProducts();

                Get.snackbar("Success", "Product Updated");
              },

              child: const Text("Update"),
            ),
          ],
        );
      },
    );
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
  // INIT
  // =========================
  @override
  void initState() {
    super.initState();

    loadShopId();

    loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Add Product")),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              // FORM
              Container(
                padding: const EdgeInsets.all(16),

                decoration: AppDecorations.card,

                child: Form(
                  key: _formKey,

                  child: Column(
                    children: [
                      // CATEGORY DROPDOWN
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

                      // PRODUCT NAME
                      inputField(
                        controller: productNameController,
                        hint: "Product Name",
                        icon: Icons.rice_bowl,
                      ),

                      const SizedBox(height: 14),

                      // PRICE
                      inputField(
                        controller: priceController,
                        hint: "Price Per KG",
                        icon: Icons.currency_rupee,
                        keyboard: TextInputType.number,
                      ),

                      const SizedBox(height: 14),

                      // STOCK
                      inputField(
                        controller: stockController,
                        hint: "Stock KG",
                        icon: Icons.inventory,
                        keyboard: TextInputType.number,
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,

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

              const SizedBox(height: 24),

              // TITLE
              Align(
                alignment: Alignment.centerLeft,

                child: Text("Your Products", style: AppTextStyles.heading3),
              ),

              const SizedBox(height: 14),

              // EMPTY
              if (productList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: AppDecorations.card,

                  child: const Center(child: Text("No products added yet")),
                )
              // PRODUCTS
              else
                ...productList.map((product) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),

                    padding: const EdgeInsets.all(16),

                    decoration: AppDecorations.card,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          product["name"] ?? "",

                          style: AppTextStyles.heading4,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Price: Rs ${product["price"]}",

                          style: AppTextStyles.bodyLarge,
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Stock: ${product["stock"]} KG",

                          style: AppTextStyles.bodyLarge,
                        ),

                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,

                          children: [
                            IconButton(
                              onPressed: () {
                                editRiceDialog(product);
                              },

                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.info,
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                deleteProduct(product["id"]);
                              },

                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    productNameController.dispose();

    priceController.dispose();

    stockController.dispose();

    super.dispose();
  }
}
