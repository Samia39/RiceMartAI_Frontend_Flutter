import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/shop_service.dart';
import '../../../core/utils/themes.dart';

class EditShopScreen extends StatefulWidget {
  const EditShopScreen({super.key});

  @override
  State<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShopScreen> {
  final _formKey = GlobalKey<FormState>();

  final shopController = TextEditingController();
  final ownerController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isLoading = false;

  int? shopId;

  // =========================
  // LOAD SHOP DATA
  // =========================
  @override
  void initState() {
    super.initState();

    final box = GetStorage();

    shopId = box.read("shop_id");

    shopController.text = box.read("shop_name") ?? "";
    ownerController.text = box.read("owner_name") ?? "";
    phoneController.text = box.read("phone") ?? "";
    addressController.text = box.read("address") ?? "";
    descriptionController.text = box.read("description") ?? "";
  }

  // =========================
  // UPDATE SHOP
  // =========================
  Future<void> updateShop() async {
    if (!_formKey.currentState!.validate()) return;

    if (shopId == null) {
      Get.snackbar("Error", "Shop not found");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final box = GetStorage();

    String token = box.read("token") ?? "";

    final result = await ShopService().updateShop(
      token: token,
      shopId: shopId!,
      shopName: shopController.text,
      ownerName: ownerController.text,
      phone: phoneController.text,
      address: addressController.text,
      description: descriptionController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (result["success"] == true) {
      // SAVE UPDATED DATA
      box.write("shop_name", shopController.text);
      box.write("owner_name", ownerController.text);
      box.write("phone", phoneController.text);
      box.write("address", addressController.text);
      box.write("description", descriptionController.text);

      // RESET APPROVAL
      box.write("shop_approved", false);

      Get.snackbar("Success", "Shop updated and sent for approval");

      Get.offAllNamed(AppRoutes.sellerDashboard);
    } else {
      Get.snackbar("Error", result["message"] ?? "Failed");
    }
  }

  // =========================
  // INPUT FIELD
  // =========================
  Widget inputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int lines = 1,
  }) {
    return Container(
      decoration: AppDecorations.inputField,

      child: TextFormField(
        controller: controller,
        maxLines: lines,

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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Edit Shop")),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Form(
            key: _formKey,

            child: Column(
              children: [
                inputField(
                  controller: shopController,
                  hint: "Shop Name",
                  icon: Icons.store,
                ),

                const SizedBox(height: 14),

                inputField(
                  controller: ownerController,
                  hint: "Owner Name",
                  icon: Icons.person,
                ),

                const SizedBox(height: 14),

                inputField(
                  controller: phoneController,
                  hint: "Phone",
                  icon: Icons.phone,
                ),

                const SizedBox(height: 14),

                inputField(
                  controller: addressController,
                  hint: "Address",
                  icon: Icons.location_on,
                ),

                const SizedBox(height: 14),

                inputField(
                  controller: descriptionController,
                  hint: "Description",
                  icon: Icons.info,
                  lines: 4,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    onPressed: isLoading ? null : updateShop,

                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.darkGreen,
                          )
                        : const Text("Update Shop"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    shopController.dispose();
    ownerController.dispose();
    phoneController.dispose();
    addressController.dispose();
    descriptionController.dispose();

    super.dispose();
  }
}
