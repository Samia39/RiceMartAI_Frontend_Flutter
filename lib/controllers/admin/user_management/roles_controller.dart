import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/admin/admin_service.dart';

class RolesController extends GetxController {
  final AdminService service = AdminService();

  RxList roles = [].obs;

  RxBool isLoading = false.obs;

  RxInt editingRoleId = 0.obs;

  final roleController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchRoles();
  }

  // =========================
  // FETCH ROLES
  // =========================

  Future<void> fetchRoles() async {
    try {
      isLoading.value = true;

      final data = await service.getRolesManagement();

      roles.value = data;
    } catch (e) {
      Get.snackbar("Error", "Failed to load roles");
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // CREATE ROLE
  // =========================

  Future<void> createRole() async {
    if (roleController.text.isEmpty) {
      Get.snackbar("Error", "Role name required");
      return;
    }

    final response = await service.createRole(roleController.text);

    if (response['success'] == true) {
      Get.snackbar("Success", response['message']);

      roleController.clear();

      fetchRoles();
    }
  }

  // =========================
  // SET EDIT
  // =========================

  void setEditRole(dynamic role) {
    editingRoleId.value = role['id'];

    roleController.text = role['name'];
  }

  // =========================
  // UPDATE ROLE
  // =========================

  Future<void> updateRole() async {
    final response = await service.updateRole(
      editingRoleId.value,
      roleController.text,
    );

    if (response['success'] == true) {
      Get.snackbar("Success", response['message']);

      editingRoleId.value = 0;

      roleController.clear();

      fetchRoles();
    }
  }

  // =========================
  // DELETE ROLE
  // =========================

  Future<void> deleteRole(int id) async {
    final response = await service.deleteRole(id);

    if (response['success'] == true) {
      Get.snackbar("Success", response['message']);

      fetchRoles();
    } else {
      Get.snackbar("Error", response['message']);
    }
  }
}
