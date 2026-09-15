import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ricemart_ai/core/services/category_service.dart';
import 'package:ricemart_ai/core/utils/themes.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // =========================
  // FETCH
  // =========================
  Future<void> fetchCategories() async {
    setState(() => isLoading = true);

    final data = await CategoryService().fetchAllCategories();

    if (!mounted) return;

    setState(() {
      categories = data;
      isLoading = false;
    });
  }

  // =========================
  // TOGGLE STATUS
  // =========================
  Future<void> toggleStatus(Map<String, dynamic> category, bool value) async {
    final token = GetStorage().read("token") ?? "";

    // optimistic UI update
    setState(() => category["status"] = value);

    final result = await CategoryService().updateStatus(
      token: token,
      categoryId: int.parse(category["id"].toString()),
      status: value,
    );

    if (result["category"] == null) {
      // revert on failure
      setState(() => category["status"] = !value);
      Get.snackbar("Error", "Could not update status");
    }
  }

  // =========================
  // ADD / EDIT DIALOG
  // =========================
  void openCategoryDialog({Map<String, dynamic>? existing}) {
    final nameController = TextEditingController(
      text: existing?["name"]?.toString() ?? "",
    );

    Uint8List? pickedImageBytes;
    String? pickedImageName;
    bool saving = false;

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
              title: Text(
                existing == null ? "Add Category" : "Edit Category",
                style: AppTextStyles.heading4,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // IMAGE PICKER
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 75,
                          maxWidth: 1000,
                        );

                        if (picked != null) {
                          final bytes = await picked.readAsBytes();
                          setDialogState(() {
                            pickedImageBytes = bytes;
                            pickedImageName = picked.name;
                          });
                        }
                      },
                      child: Container(
                        height: 130,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.darkGreen.withOpacity(0.3),
                          ),
                        ),
                        child: pickedImageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  pickedImageBytes!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : (existing?["image_url"] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        existing!["image_url"],
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.rice_bowl,
                                              color: AppColors.darkGreen,
                                            ),
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.add_a_photo,
                                          color: AppColors.darkGreen,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "Tap to add image",
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    )),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // NAME FIELD
                    Container(
                      decoration: AppDecorations.inputField,
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: "Category name",
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty) {
                            Get.snackbar(
                              "Required",
                              "Category name is required",
                            );
                            return;
                          }

                          setDialogState(() => saving = true);

                          final token = GetStorage().read("token") ?? "";
                          final service = CategoryService();

                          final result = existing == null
                              ? await service.createCategory(
                                  token: token,
                                  name: nameController.text.trim(),
                                  imageBytes: pickedImageBytes,
                                  imageName: pickedImageName ?? 'category.jpg',
                                )
                              : await service.updateCategory(
                                  token: token,
                                  categoryId: int.parse(
                                    existing["id"].toString(),
                                  ),
                                  name: nameController.text.trim(),
                                  imageBytes: pickedImageBytes,
                                  imageName: pickedImageName ?? 'category.jpg',
                                );

                          if (!mounted) return;

                          Navigator.pop(context);

                          if (result["category"] != null) {
                            Get.snackbar(
                              "Success",
                              existing == null
                                  ? "Category added"
                                  : "Category updated",
                            );
                            fetchCategories();
                          } else {
                            Get.snackbar(
                              "Error",
                              result["message"]?.toString() ??
                                  "Something went wrong",
                            );
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(existing == null ? "Add" : "Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================
  // CATEGORY CARD
  // =========================
  Widget categoryCard(Map<String, dynamic> category) {
    final imageUrl = category["image_url"];
    final isActive = category["status"] == true;

    return Container(
      decoration: AppDecorations.card,
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // THUMBNAIL
          Container(
            height: 70,
            width: 70,
            color: AppColors.cream.withOpacity(0.6),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.rice_bowl, color: AppColors.darkGreen),
                  )
                : const Icon(Icons.rice_bowl, color: AppColors.darkGreen),
          ),

          // NAME + STATUS
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category["name"] ?? "",
                    style: AppTextStyles.heading4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isActive ? "Active" : "Inactive",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isActive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // EDIT BUTTON
          IconButton(
            onPressed: () => openCategoryDialog(existing: category),
            icon: const Icon(Icons.edit_outlined, color: AppColors.darkGreen),
          ),

          // STATUS SWITCH
          Switch(
            value: isActive,
            activeColor: AppColors.darkGreen,
            onChanged: (value) => toggleStatus(category, value),
          ),

          const SizedBox(width: 6),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Manage Categories")),
        floatingActionButton: FloatingActionButton(
          onPressed: () => openCategoryDialog(),
          backgroundColor: AppColors.darkGreen,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: RefreshIndicator(
          onRefresh: fetchCategories,
          color: AppColors.darkGreen,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : categories.isEmpty
              ? LayoutBuilder(
                  builder: (context, c) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: c.maxHeight),
                      child: Center(
                        child: Text(
                          "No categories yet",
                          style: AppTextStyles.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      categoryCard(categories[index]),
                ),
        ),
      ),
    );
  }
}
