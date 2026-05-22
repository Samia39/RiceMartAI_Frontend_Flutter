import 'package:flutter/material.dart';
import 'package:frontend/core/services/admin/admin_service.dart';
import 'package:get/get.dart';

class UsersController extends GetxController {
  final AdminService service = AdminService();

  RxList users = [].obs;

  RxList<String> roles = <String>[].obs;

  RxBool isLoading = false.obs;

  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  RxString selectedRole = ''.obs;

  RxInt editingUserId = 0.obs;

  // =========================
  // LOAD USERS
  // =========================

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;

      final response = await service.getUsers();

      users.value = response;
    } catch (e) {
      Get.snackbar("Error", "Failed to load users");
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // LOAD ROLES
  // =========================

  Future<void> fetchRoles() async {
    try {
      final response = await service.getRoles();

      roles.value = response
          .map<String>((role) => role['name'].toString())
          .toList();

      if (roles.isNotEmpty) {
        selectedRole.value = roles.first;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load roles");
    }
  }

  // =========================
  // CREATE USER
  // =========================

  Future<void> createUser() async {
    try {
      final response = await service.createUser(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: selectedRole.value,
      );

      if (response['success'] == true) {
        Get.snackbar("Success", response['message']);

        clearFields();

        fetchUsers();
      } else {
        Get.snackbar("Error", response['message']);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to create user");
    }
  }

  // =========================
  // SET EDIT USER
  // =========================

  void setEditUser(dynamic user) {
    editingUserId.value = user['id'];

    nameController.text = user['name'];

    emailController.text = user['email'];

    if (user['roles'].isNotEmpty) {
      selectedRole.value = user['roles'][0]['name'];
    }
  }

  // =========================
  // UPDATE USER
  // =========================

  Future<void> updateUser() async {
    try {
      final response = await service.updateUser(
        id: editingUserId.value,
        name: nameController.text,
        email: emailController.text,
        role: selectedRole.value,
      );

      if (response['success'] == true) {
        Get.snackbar("Success", response['message']);

        clearFields();

        fetchUsers();
      } else {
        Get.snackbar("Error", response['message']);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update user");
    }
  }

  // =========================
  // DELETE USER
  // =========================

  Future<void> deleteUser(int id) async {
    try {
      final response = await service.deleteUser(id);

      if (response['success'] == true) {
        Get.snackbar("Success", response['message']);

        fetchUsers();
      } else {
        Get.snackbar("Error", response['message']);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to delete user");
    }
  }

  // =========================
  // CLEAR
  // =========================

  void clearFields() {
    nameController.clear();

    emailController.clear();

    passwordController.clear();

    editingUserId.value = 0;
  }

  @override
  void onInit() {
    super.onInit();

    fetchUsers();

    fetchRoles();
  }
}
