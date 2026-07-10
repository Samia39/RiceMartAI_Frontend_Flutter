import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/themes.dart';
import '../../../controllers/admin/add_seller_controller.dart';

class AddSellerScreen extends StatefulWidget {
  const AddSellerScreen({super.key});

  @override
  State<AddSellerScreen> createState() => _AddSellerScreenState();
}

class _AddSellerScreenState extends State<AddSellerScreen> {
  final controller = Get.put(AddSellerController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Add Seller")),

        body: LayoutBuilder(
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
                      // =========================
                      // ACCOUNT INFO
                      // =========================
                      sectionCard(
                        title: "Account Info",

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,

                          children: [
                            buildField(
                              controller.nameController,
                              "Full Name",
                              icon: Icons.person,
                            ),

                            const SizedBox(height: 12),

                            buildField(
                              controller.emailController,
                              "Email",
                              icon: Icons.email,
                              keyboard: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 12),

                            buildField(
                              controller.passwordController,
                              "Password",
                              icon: Icons.lock,
                              obscure: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // =========================
                      // SHOP INFO
                      // =========================
                      sectionCard(
                        title: "Shop Info",

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,

                          children: [
                            buildField(
                              controller.shopNameController,
                              "Shop Name",
                              icon: Icons.store,
                            ),

                            const SizedBox(height: 12),

                            buildField(
                              controller.ownerNameController,
                              "Owner Name",
                              icon: Icons.badge,
                            ),

                            const SizedBox(height: 12),

                            buildField(
                              controller.phoneController,
                              "Phone Number",
                              icon: Icons.phone,
                              keyboard: TextInputType.phone,
                            ),

                            const SizedBox(height: 12),

                            buildField(
                              controller.addressController,
                              "Address",
                              icon: Icons.location_on,
                            ),

                            const SizedBox(height: 12),

                            buildField(
                              controller.cnicController,
                              "CNIC (35202-1234567-1)",
                              icon: Icons.credit_card,
                            ),

                            const SizedBox(height: 12),

                            buildField(
                              controller.descriptionController,
                              "Description",
                              icon: Icons.info,
                              maxLines: 3,
                            ),

                            const SizedBox(height: 12),

                            // =========================
                            // IMAGE PICKER
                            // =========================
                            Obx(() {
                              return GestureDetector(
                                onTap: controller.pickImage,

                                child: Container(
                                  height: 170,
                                  width: double.infinity,

                                  decoration: AppDecorations.inputField,

                                  child: controller.cnicImage.value == null
                                      ? Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.upload_file,
                                                color: AppColors.iconMuted,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                "Upload CNIC Image",
                                                style: AppTextStyles.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.network(
                                            controller.cnicImage.value!.path,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // =========================
                      // BUTTON
                      // =========================
                      Obx(() {
                        return SizedBox(
                          height: 55,

                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.createSeller,

                            child: controller.isLoading.value
                                ? const CircularProgressIndicator()
                                : Text(
                                    "Create Seller",
                                    style: AppTextStyles.button,
                                  ),
                          ),
                        );
                      }),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================
  // INPUT FIELD
  // =========================
  // The outer Container supplies background/border via
  // AppDecorations.inputField, so the TextField itself is told not to
  // paint its own fill/border — otherwise the global InputDecorationTheme
  // would stack a second background/border on top of this one.
  Widget buildField(
    TextEditingController controller,
    String hint, {
    IconData? icon,
    bool obscure = false,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      decoration: AppDecorations.inputField,

      child: TextField(
        controller: controller,
        obscureText: obscure,
        maxLines: obscure ? 1 : maxLines,
        keyboardType: keyboard,

        style: AppTextStyles.bodyLarge,
        cursorColor: AppColors.darkGreen,

        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,

          prefixIcon: icon != null
              ? Icon(icon, color: AppColors.darkGreen)
              : null,

          hintText: hint,
          hintStyle: AppTextStyles.hint,
        ),
      ),
    );
  }

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
}
