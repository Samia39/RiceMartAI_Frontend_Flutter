import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/shop_service.dart';
import '../../../core/constants/app_icons.dart';
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
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final cnicController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  bool isLoading = false;

  int? shopId;

  // Existing images already on the server (shown until replaced)
  String? existingFrontImagePath;
  String? existingBackImagePath;

  // Newly picked replacement images (only sent if the seller picks new ones)
  Uint8List? newCnicFrontImage;
  Uint8List? newCnicBackImage;

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
    cityController.text = box.read("city") ?? "";
    addressController.text = box.read("address") ?? "";
    descriptionController.text = box.read("description") ?? "";
    cnicController.text = box.read("cnic") ?? "";

    existingFrontImagePath = box.read("cnic_image");
    existingBackImagePath = box.read("cnic_back_image");
  }

  String _imageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    final host = BaseUrl.url.replaceAll(RegExp(r'/api/?$'), '');
    return "$host/storage/$path";
  }

  // =========================
  // PICK REPLACEMENT CNIC IMAGE
  // =========================
  Future<void> pickCnic(bool isFront) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      final bytes = await file.readAsBytes();

      setState(() {
        if (isFront) {
          newCnicFrontImage = bytes;
        } else {
          newCnicBackImage = bytes;
        }
      });
    }
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
      city: cityController.text,
      address: addressController.text,
      description: descriptionController.text,
      cnic: cnicController.text,
      cnicFrontImage: newCnicFrontImage,
      cnicBackImage: newCnicBackImage,
    );

    setState(() {
      isLoading = false;
    });

    if (result["success"] == true) {
      final shop = result["shop"];

      box.write("shop_name", shopController.text);
      box.write("owner_name", ownerController.text);
      box.write("phone", phoneController.text);
      box.write("city", cityController.text);
      box.write("address", addressController.text);
      box.write("description", descriptionController.text);
      box.write("cnic", cnicController.text);
      box.write("cnic_image", shop?["cnic_image"]);
      box.write("cnic_back_image", shop?["cnic_back_image"]);
      box.write("shop_approved", false);

      Get.snackbar("Success", "Shop updated and sent for approval");

      Navigator.pop(context, true);
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
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      decoration: AppDecorations.inputField,
      child: TextFormField(
        controller: controller,
        maxLines: lines,
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
  // CNIC IMAGE TILE (shows existing image, or new pick preview)
  // =========================
  Widget cnicImageTile({
    required String label,
    required Uint8List? newImage,
    required String? existingPath,
    required VoidCallback onTap,
  }) {
    final existingUrl = _imageUrl(existingPath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 130,
            width: double.infinity,
            decoration: AppDecorations.inputField,
            child: newImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      newImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : existingUrl.isNotEmpty
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(existingUrl, fit: BoxFit.cover),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Tap to replace",
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload_file, color: AppColors.iconMuted),
                        const SizedBox(height: 6),
                        Text("Upload $label", style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
          ),
        ),
      ],
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
                  controller: cnicController,
                  hint: "CNIC (12345-1234567-1)",
                  icon: Icons.badge,
                  keyboard: TextInputType.number,
                ),

                const SizedBox(height: 14),

                inputField(
                  controller: addressController,
                  hint: "Address",
                  icon: Icons.location_on,
                ),

                const SizedBox(height: 14),

                inputField(
                  controller: cityController,
                  hint: "City",
                  icon: Icons.location_city,
                ),

                const SizedBox(height: 14),

                inputField(
                  controller: descriptionController,
                  hint: "Description",
                  icon: Icons.info,
                  lines: 4,
                ),

                const SizedBox(height: 18),

                cnicImageTile(
                  label: "CNIC Front",
                  newImage: newCnicFrontImage,
                  existingPath: existingFrontImagePath,
                  onTap: () => pickCnic(true),
                ),

                const SizedBox(height: 14),

                cnicImageTile(
                  label: "CNIC Back",
                  newImage: newCnicBackImage,
                  existingPath: existingBackImagePath,
                  onTap: () => pickCnic(false),
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
    cityController.dispose();
    descriptionController.dispose();
    cnicController.dispose();

    super.dispose();
  }
}
