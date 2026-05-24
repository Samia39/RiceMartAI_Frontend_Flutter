import 'package:get/get.dart';
import '../../../core/services/admin/admin_service.dart';

class PermissionsController extends GetxController {
  final AdminService _service = AdminService();

  // =========================
  // STATE VARIABLES
  // =========================

  var roles = [].obs;
  var permissions = [].obs;

  RxnInt selectedRoleId = RxnInt();

  var selectedPermissions = <int>[].obs;

  // =========================
  // LOAD ROLES
  // =========================

  Future<void> loadRoles() async {
    try {
      final data = await _service.getRolesManagement();
      roles.value = data;
      update();
    } catch (e) {
      Get.snackbar("Error", "Failed to load roles");
    }
  }

  // =========================
  // LOAD PERMISSIONS
  // =========================

  Future<void> loadPermissions() async {
    try {
      final data = await _service.getPermissions();
      permissions.value = data;
      update();
    } catch (e) {
      Get.snackbar("Error", "Failed to load permissions");
    }
  }

  // =========================
  // LOAD ROLE PERMISSIONS
  // =========================

  Future<void> loadRolePermissions(int roleId) async {
    try {
      final data = await _service.getRolePermissions(roleId);

      // convert to int list safely
      selectedPermissions.value = List<int>.from(data.map((e) => e['id']));
      update();
    } catch (e) {
      Get.snackbar("Error", "Failed to load role permissions");
    }
  }

  // =========================
  // HANDLE ROLE CHANGE
  // =========================

  Future<void> onRoleChanged(int? roleId) async {
    selectedRoleId.value = roleId;

    if (roleId != null) {
      await loadRolePermissions(roleId);
    } else {
      selectedPermissions.clear();
    }
  }

  // =========================
  // TOGGLE PERMISSION
  // =========================

  void togglePermission(int permissionId) {
    if (selectedPermissions.contains(permissionId)) {
      selectedPermissions.remove(permissionId);
    } else {
      selectedPermissions.add(permissionId);
    }

    update();
  }

  // =========================
  // ASSIGN PERMISSIONS
  // =========================

  Future<String> assignPermissions() async {
    try {
      final response = await _service.assignPermissions(
        roleId: selectedRoleId.value!,
        permissions: selectedPermissions.toList(),
      );

      return response['message'] ?? "Success";
    } catch (e) {
      return "Failed to assign permissions";
    }
  }

  @override
  void onClose() {
    selectedPermissions.clear();
    selectedRoleId.value = null;

    super.onClose();
  }
}
