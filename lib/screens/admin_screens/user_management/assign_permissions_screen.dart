import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin/user_management/permissions_controller.dart';

class AssignPermissionScreen extends StatefulWidget {
  const AssignPermissionScreen({super.key});

  @override
  State<AssignPermissionScreen> createState() => _AssignPermissionScreenState();
}

class _AssignPermissionScreenState extends State<AssignPermissionScreen> {
  final controller = Get.put(PermissionsController());

  @override
  void initState() {
    super.initState();
    controller.loadRoles();
    controller.loadPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Permissions")),

      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              // ROLE DROPDOWN
              DropdownButtonFormField<int>(
                value: controller.selectedRoleId,
                items: controller.roles.map<DropdownMenuItem<int>>((role) {
                  return DropdownMenuItem<int>(
                    value: role['id'],
                    child: Text(role['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.selectedRoleId = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Select Role',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // PERMISSIONS LIST
              Expanded(
                child: ListView.builder(
                  itemCount: controller.permissions.length,
                  itemBuilder: (context, index) {
                    final permission = controller.permissions[index]['name'];

                    return CheckboxListTile(
                      title: Text(permission),
                      value: controller.selectedPermissions.contains(
                        permission,
                      ),
                      onChanged: (_) {
                        controller.togglePermission(permission);
                      },
                    );
                  },
                ),
              ),

              // BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (controller.selectedRoleId == null) {
                      Get.snackbar("Error", "Please select a role");
                      return;
                    }

                    final message = await controller.assignPermissions();

                    Get.snackbar("Result", message);
                  },
                  child: const Text("Assign Permissions"),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
