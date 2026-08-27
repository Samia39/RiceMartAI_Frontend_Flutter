import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/product_service.dart';
import '../../../core/utils/themes.dart';
import 'add_product_form_screen.dart';

class AddRiceScreen extends StatefulWidget {
  const AddRiceScreen({super.key});

  @override
  State<AddRiceScreen> createState() => _AddRiceScreenState();
}

class _AddRiceScreenState extends State<AddRiceScreen> {
  List<Map<String, dynamic>> productList = [];
  bool isLoading = true;

  int? shopId;

  // =========================
  // LOAD SHOP ID
  // =========================
  Future<void> loadShopId() async {
    final box = GetStorage();

    shopId = box.read("shop_id");

    if (shopId != null) {
      await fetchProducts();
    } else {
      setState(() => isLoading = false);
    }
  }

  // =========================
  // FETCH PRODUCTS
  // =========================
  Future<void> fetchProducts() async {
    setState(() => isLoading = true);

    final data = await ProductService().fetchShopProducts(shopId: shopId!);

    setState(() {
      productList = data;
      isLoading = false;
    });
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

    Uint8List? editSelectedImage;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.cream,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text("Edit Product", style: AppTextStyles.heading4),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 75,
                          maxWidth: 1200,
                        );
                        if (picked != null) {
                          final bytes = await picked.readAsBytes();
                          setDialogState(() {
                            editSelectedImage = bytes;
                          });
                        }
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.darkGreen.withOpacity(0.3),
                          ),
                        ),
                        child: editSelectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  editSelectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_a_photo,
                                    color: AppColors.darkGreen,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Tap to change image",
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 14),

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
                      imageBytes: editSelectedImage,
                      imageName: 'product.jpg',
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
      },
    );
  }

  // =========================
  // GO TO ADD PRODUCT FORM
  // =========================
  Future<void> openAddProductForm() async {
    if (shopId == null) {
      Get.snackbar("Error", "No approved shop found");
      return;
    }

    final added = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddProductFormScreen(shopId: shopId!)),
    );

    if (added == true) {
      fetchProducts();
    }
  }

  // =========================
  // PRODUCT CARD
  // =========================
  Widget productCard(Map<String, dynamic> product) {
    final imageUrl = ProductService.getImageUrl(product);
    final categoryName =
        product["rice_category"]?["name"]?.toString() ?? "Uncategorized";

    return Container(
      decoration: AppDecorations.card,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // =========================
          // TOP: ICON / IMAGE
          // =========================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: AppColors.cream.withOpacity(0.5),
            child: Center(
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.darkGreen.withOpacity(0.12),
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl == null
                    ? Icon(
                        Icons.rice_bowl,
                        color: AppColors.darkGreen,
                        size: 28,
                      )
                    : null,
              ),
            ),
          ),

          // =========================
          // DETAILS
          // =========================
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product["name"] ?? "",
                  style: AppTextStyles.heading4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  categoryName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.iconMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  "Rs ${product["price"]}/KG",
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // =========================
          // FOOTER: EDIT | DELETE
          // =========================
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => editRiceDialog(product),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Edit",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: InkWell(
                    onTap: () => deleteProduct(product["id"]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Delete",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("My Products")),
        floatingActionButton: FloatingActionButton(
          onPressed: openAddProductForm,
          backgroundColor: AppColors.darkGreen,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: RefreshIndicator(
          onRefresh: fetchProducts,
          color: AppColors.darkGreen,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : productList.isEmpty
                      ? LayoutBuilder(
                          builder: (context, c) => SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: c.maxHeight,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.rice_bowl_outlined,
                                      size: 42,
                                      color: AppColors.iconMuted,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "No products yet",
                                      style: AppTextStyles.bodyLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Tap + to add your first product",
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.fromLTRB(
                            isWide ? 24 : 14,
                            14,
                            isWide ? 24 : 14,
                            90,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isWide ? 4 : 2,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                mainAxisExtent: isWide ? 250 : 255,
                              ),
                          itemCount: productList.length,
                          itemBuilder: (context, index) =>
                              productCard(productList[index]),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
