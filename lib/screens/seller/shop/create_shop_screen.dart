import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/services/shop_service.dart';
import '../../../core/utils/themes.dart';
import 'shop_status_screen.dart';

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
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Uint8List? cnicFrontImage;
  Uint8List? cnicBackImage;

  bool isLoading = false;

  // ---------------------------------------------------------
  // Pick CNIC (Front or Back)
  // ---------------------------------------------------------
  Future<void> pickCnic(bool isFront) async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      final bytes = await file.readAsBytes();

      setState(() {
        if (isFront) {
          cnicFrontImage = bytes;
        } else {
          cnicBackImage = bytes;
        }
      });
    }
  }

  // ---------------------------------------------------------
  // Create Shop
  // ---------------------------------------------------------
  Future<void> createShop() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Both CNIC images are required
    if (cnicFrontImage == null || cnicBackImage == null) {
      Get.snackbar(
        "Required",
        "Please upload both front and back sides of your CNIC.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? token = GetStorage().read("token");

      final result = await ShopService().createShop(
        token: token ?? "",
        cnic: _cnicController.text.trim(),
        shopName: _shopController.text.trim(),
        ownerName: _ownerController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        address: _addressController.text.trim(),
        description: _descController.text.trim(),
        cnicFrontImage: cnicFrontImage!,
        cnicBackImage: cnicBackImage!,
      );

      setState(() {
        isLoading = false;
      });

      if (result["shop"] != null) {
        final box = GetStorage();

        box.write("has_shop", true);
        box.write("shop_approved", false);
        box.write("shop_id", result["shop"]["id"]);

        box.write("shop_name", _shopController.text.trim());
        box.write("owner_name", _ownerController.text.trim());
        box.write("phone", _phoneController.text.trim());
        box.write("city", _cityController.text.trim());
        box.write("address", _addressController.text.trim());
        box.write("description", _descController.text.trim());

        Get.offAll(() => ShopStatusScreen(shop: result["shop"]));
      } else {
        Get.snackbar(
          "Error",
          result["message"] ?? "Failed to create shop",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      Get.snackbar(
        "Error",
        "Server error. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ---------------------------------------------------------
  // Reusable Input Field
  // ---------------------------------------------------------
  Widget inputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int lines = 1,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? formatters,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: RichText(
            text: TextSpan(
              text: hint,
              style: AppTextStyles.label,
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  TextSpan(
                    text: ' (Optional)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.iconMuted,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Input box
        Container(
          decoration: AppDecorations.inputField,
          child: TextFormField(
            controller: controller,
            maxLines: lines,
            keyboardType: keyboard,
            inputFormatters: formatters,

            // Only validate required fields
            validator: isRequired
                ? (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Required";
                    }

                    return null;
                  }
                : null,

            style: AppTextStyles.bodyLarge,
            cursorColor: AppColors.darkGreen,

            decoration: InputDecoration(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,

              prefixIcon: icon != null
                  ? Icon(icon, color: AppColors.darkGreen)
                  : null,

              hintText: hint,
              hintStyle: AppTextStyles.hint,

              errorStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // CNIC Image Tile
  // ---------------------------------------------------------
  Widget cnicImageTile({
    required String label,
    required Uint8List? image,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CNIC label with required *
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.label,
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: AppDecorations.inputField,
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.upload_file,
                          color: AppColors.iconMuted,
                          size: 30,
                        ),
                        const SizedBox(height: 6),
                        Text("Upload $label", style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 3),
                        Text(
                          "Required",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // Section Card
  // ---------------------------------------------------------
  Widget sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: AppDecorations.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // Build
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Create Shop")),

        body: Form(
          key: _formKey,
          child: LayoutBuilder(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ==================================================
                        // CNIC INFORMATION
                        // ==================================================
                        sectionCard(
                          title: "CNIC Information",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // CNIC Number
                              inputField(
                                controller: _cnicController,
                                hint: "CNIC",
                                icon: Icons.badge,
                                keyboard: TextInputType.number,
                                formatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9-]'),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),

                              // CNIC Front
                              cnicImageTile(
                                label: "CNIC Front",
                                image: cnicFrontImage,
                                onTap: () => pickCnic(true),
                              ),

                              const SizedBox(height: 15),

                              // CNIC Back
                              cnicImageTile(
                                label: "CNIC Back",
                                image: cnicBackImage,
                                onTap: () => pickCnic(false),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // SHOP INFORMATION
                        // ==================================================
                        sectionCard(
                          title: "Shop Information",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Shop Name
                              inputField(
                                controller: _shopController,
                                hint: "Shop Name",
                                icon: Icons.store,
                              ),

                              const SizedBox(height: 12),

                              // Owner Name
                              inputField(
                                controller: _ownerController,
                                hint: "Owner Name",
                                icon: Icons.person,
                              ),

                              const SizedBox(height: 12),

                              // Phone
                              inputField(
                                controller: _phoneController,
                                hint: "Phone",
                                icon: Icons.phone,
                                keyboard: TextInputType.phone,
                              ),

                              const SizedBox(height: 12),

                              // City
                              inputField(
                                controller: _cityController,
                                hint: "City",
                                icon: Icons.location_city,
                              ),

                              const SizedBox(height: 12),

                              // Address
                              inputField(
                                controller: _addressController,
                                hint: "Address",
                                icon: Icons.location_on,
                              ),

                              const SizedBox(height: 12),

                              // Description - OPTIONAL
                              inputField(
                                controller: _descController,
                                hint: "Description",
                                icon: Icons.info,
                                lines: 4,
                                isRequired: false,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ==================================================
                        // CREATE SHOP BUTTON
                        // ==================================================
                        SizedBox(
                          height: 55,
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
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------
  @override
  void dispose() {
    _cnicController.dispose();
    _shopController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _descController.dispose();

    super.dispose();
  }
}
