import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/admin/admin_service.dart';

class AddSellerController extends GetxController {
  final AdminService _adminService = AdminService();

  // =========================
  // ACCOUNT INFO
  // =========================
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // =========================
  // SHOP INFO
  // =========================
  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final cnicController = TextEditingController();
  final descriptionController = TextEditingController();

  // =========================
  // IMAGES
  // =========================
  final Rx<XFile?> cnicFrontImage = Rx<XFile?>(null);
  final Rx<XFile?> cnicBackImage = Rx<XFile?>(null);

  final RxBool isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickFrontImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) cnicFrontImage.value = picked;
  }

  Future<void> pickBackImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) cnicBackImage.value = picked;
  }

  Future<void> createSeller() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        shopNameController.text.trim().isEmpty ||
        ownerNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        cnicController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all required fields",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (cnicFrontImage.value == null || cnicBackImage.value == null) {
      Get.snackbar(
        "Error",
        "Please upload both sides of the CNIC",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isLoading.value = true;

    try {
      final Uint8List frontBytes = await cnicFrontImage.value!.readAsBytes();
      final Uint8List backBytes = await cnicBackImage.value!.readAsBytes();

      final result = await _adminService.createSeller(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        shopName: shopNameController.text.trim(),
        ownerName: ownerNameController.text.trim(),
        phone: phoneController.text.trim(),
        city: cityController.text.trim(),
        address: addressController.text.trim(),
        cnic: cnicController.text.trim(),
        description: descriptionController.text.trim(),
        cnicFrontImage: frontBytes,
        cnicBackImage: backBytes,
        cnicFrontFileName: cnicFrontImage.value!.name,
        cnicBackFileName: cnicBackImage.value!.name,
      );

      isLoading.value = false;

      if (result['success'] == true) {
        Get.snackbar(
          "Success",
          "Seller account created — approved and ready to log in",
          snackPosition: SnackPosition.TOP,
        );
        Get.back(result: true);
      } else {
        Get.snackbar(
          "Error",
          result['message'] ?? "Failed to create seller",
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.TOP);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    shopNameController.dispose();
    ownerNameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    addressController.dispose();
    cnicController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
