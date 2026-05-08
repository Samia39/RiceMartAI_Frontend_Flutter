import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/services/rice_service.dart';
import '../../../core/services/rice_type_service.dart';
import '../../../core/utils/themes.dart';

class AddRiceScreen extends StatefulWidget {
  const AddRiceScreen({super.key});

  @override
  State<AddRiceScreen> createState() => _AddRiceScreenState();
}

class _AddRiceScreenState extends State<AddRiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final priceController = TextEditingController();
  final stockController = TextEditingController();

  bool isLoading = false;

  List<Map<String, dynamic>> riceList = [];

  List<Map<String, dynamic>> riceTypes = [];

  String? selectedRice;

  int? shopId;

  // -------------------------
  // LOAD SHOP ID
  // -------------------------
  Future<void> loadShopId() async {
    final box = GetStorage();

    shopId = box.read("shop_id");

    if (shopId != null) {
      fetchRice();
    }

    setState(() {});
  }

  // -------------------------
  // LOAD RICE TYPES
  // -------------------------
  Future<void> loadRiceTypes() async {
    final data = await RiceTypeService().fetchRiceTypes();

    setState(() {
      riceTypes = data;
    });
  }

  // -------------------------
  // FETCH RICE
  // -------------------------
  Future<void> fetchRice() async {
    String token = GetStorage().read("token") ?? "";

    final data = await RiceService().fetchShopRice(
      token: token,
      shopId: shopId!,
    );

    setState(() {
      riceList = data;
    });
  }

  // -------------------------
  // ADD RICE
  // -------------------------
  Future<void> addRice() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedRice == null) {
      Get.snackbar("Error", "Select rice type");

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

    final result = await RiceService().addRice(
      token: token,
      shopId: shopId!,
      name: selectedRice!,
      price: priceController.text,
      stock: stockController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (result["success"] == true) {
      Get.snackbar("Success", "Rice Added");

      selectedRice = null;

      priceController.clear();
      stockController.clear();

      fetchRice();

      setState(() {});
    }
  }

  // -------------------------
  // DELETE RICE
  // -------------------------
  Future<void> deleteRice(int riceId) async {
    String token = GetStorage().read("token") ?? "";

    final result = await RiceService().deleteRice(token: token, riceId: riceId);

    if (result["success"] == true) {
      fetchRice();

      Get.snackbar("Deleted", "Rice removed");
    }
  }

  // -------------------------
  // EDIT RICE
  // -------------------------
  void editRiceDialog(Map<String, dynamic> rice) {
    final editPriceController = TextEditingController(
      text: rice["price"].toString(),
    );

    final editStockController = TextEditingController(
      text: rice["stock"].toString(),
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.cream,

          title: const Text("Edit Rice", style: AppTextStyles.heading4),

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

                final result = await RiceService().updateRice(
                  token: token,
                  riceId: rice["id"],
                  price: editPriceController.text,
                  stock: editStockController.text,
                );

                if (result["success"] == true) {
                  Navigator.pop(context);

                  fetchRice();

                  Get.snackbar("Success", "Rice Updated");
                }
              },

              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  // -------------------------
  // INPUT FIELD
  // -------------------------
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

  // -------------------------
  // INIT
  // -------------------------
  @override
  void initState() {
    super.initState();

    loadShopId();

    loadRiceTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Add Rice")),

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
                      // DROPDOWN
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),

                        decoration: AppDecorations.inputField,

                        child: DropdownButtonFormField<String>(
                          value: selectedRice,

                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),

                          hint: const Text("Select Rice Type"),

                          items: riceTypes.map((rice) {
                            return DropdownMenuItem<String>(
                              value: rice["name"],

                              child: Text(rice["name"]),
                            );
                          }).toList(),

                          onChanged: (value) {
                            setState(() {
                              selectedRice = value;
                            });
                          },
                        ),
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

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: ElevatedButton(
                          onPressed: isLoading ? null : addRice,

                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: AppColors.darkGreen,
                                )
                              : const Text("Add Rice"),
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

                child: Text(
                  "Your Rice Listings",
                  style: AppTextStyles.heading3,
                ),
              ),

              const SizedBox(height: 14),

              // EMPTY
              if (riceList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppDecorations.card,

                  child: const Center(child: Text("No rice added yet")),
                )
              // LIST
              else
                ...riceList.map((rice) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: AppDecorations.card,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(rice["name"] ?? "", style: AppTextStyles.heading4),

                        const SizedBox(height: 10),

                        Text(
                          "Price: Rs ${rice["price"]}",
                          style: AppTextStyles.bodyLarge,
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "Stock: ${rice["stock"]} KG",
                          style: AppTextStyles.bodyLarge,
                        ),

                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,

                          children: [
                            IconButton(
                              onPressed: () {
                                editRiceDialog(rice);
                              },

                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.info,
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                deleteRice(rice["id"]);
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
    priceController.dispose();
    stockController.dispose();

    super.dispose();
  }
}
