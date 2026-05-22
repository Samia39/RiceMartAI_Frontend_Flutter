import 'package:get/get.dart';
import '../../../core/services/admin/admin_service.dart';

class PermissionsController extends GetxController {
  final AdminService _service = AdminService();

  var roles = [].obs;
  var permissions = [].obs;

  var selectedRoleId;
  var selectedPermissions = <String>[].obs;

  // LOAD ROLES
  Future<void> loadRoles() async {
    try {
      final data = await _service.getRolesManagement();
      roles.value = data;
    } catch (e) {
      Get.snackbar("Error", "Failed to load roles");
    }
  }

  // LOAD PERMISSIONS
  Future<void> loadPermissions() async {
    try {
      final data = await _service.getPermissions();
      permissions.value = data;
    } catch (e) {
      Get.snackbar("Error", "Failed to load permissions");
    }
  }

  // TOGGLE CHECKBOX
  void togglePermission(String permission) {
    if (selectedPermissions.contains(permission)) {
      selectedPermissions.remove(permission);
    } else {
      selectedPermissions.add(permission);
    }
  }

  // ASSIGN PERMISSIONS
  Future<String> assignPermissions() async {
    try {
      final response = await _service.assignPermissions(
        roleId: selectedRoleId,
        permissions: selectedPermissions,
      );

      return response['message'] ?? "Success";
    } catch (e) {
      return "Failed to assign permissions";
    }
  }
}
