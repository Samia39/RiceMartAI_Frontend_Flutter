import 'package:flutter/material.dart';
import 'package:frontend/core/services/admin/admin_service.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddSellerController extends GetxController {
  // =========================
  // TEXT CONTROLLERS
  // =========================

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final shopNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cnicController = TextEditingController();
  final descriptionController = TextEditingController();

  // =========================
  // IMAGE
  // =========================

  final ImagePicker picker = ImagePicker();
  Rx<XFile?> cnicImage = Rx<XFile?>(null);

  // =========================
  // LOADING
  // =========================

  RxBool isLoading = false.obs;

  // =========================
  // PICK IMAGE
  // =========================

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      cnicImage.value = pickedFile;
    }
  }

  // =========================
  // VALIDATION
  // =========================

  bool validate() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        shopNameController.text.isEmpty ||
        ownerNameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ||
        cnicController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all required fields");
      return false;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters");
      return false;
    }

    // if (cnicImage.value == null) {
    //   Get.snackbar("Error", "Please upload CNIC image");
    //   return false;
    // }

    return true;
  }

  // =========================
  // SUBMIT
  // =========================

  Future<void> createSeller() async {
    if (!validate()) return;

    isLoading.value = true;

    try {
      final response = await AdminService().createSeller(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        shopName: shopNameController.text,
        ownerName: ownerNameController.text,
        phone: phoneController.text,
        address: addressController.text,
        cnic: cnicController.text,
        description: descriptionController.text,
      );

      if (response['success'] == true) {
        Get.snackbar("Success", "Seller created successfully");
        Get.back();
      } else {
        Get.snackbar("Error", response['message'] ?? "Failed");
      }
    } catch (e) {
      Get.snackbar("Error", "Server error");
    } finally {
      isLoading.value = false;
    }
  }
}
