import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin/user_management/permissions_controller.dart';

class AssignPermissionScreen extends StatefulWidget {
  const AssignPermissionScreen({super.key});

  @override
  State<AssignPermissionScreen> createState() => _AssignPermissionScreenState();
}

class _AssignPermissionScreenState extends State<AssignPermissionScreen> {
  // =========================
  // FIND CONTROLLER
  // =========================

  final PermissionsController controller = Get.find<PermissionsController>();

  @override
  void initState() {
    super.initState();

    // RESET SCREEN STATE
    controller.selectedRoleId.value = null;
    controller.selectedPermissions.clear();

    // LOAD DATA
    controller.loadRoles();
    controller.loadPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign Permissions"),
        centerTitle: true,
      ),

      body: GetBuilder<PermissionsController>(
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
                // =========================
                // ROLE DROPDOWN
                // =========================
                DropdownButtonFormField<int>(
                  value: controller.selectedRoleId.value,

                  decoration: InputDecoration(
                    labelText: "Select Role",

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  items: controller.roles.map<DropdownMenuItem<int>>((role) {
                    return DropdownMenuItem<int>(
                      value: role['id'],
                      child: Text(role['name']),
                    );
                  }).toList(),

                  onChanged: (value) async {
                    await controller.onRoleChanged(value);
                  },
                ),

                const SizedBox(height: 20),

                // =========================
                // CONTENT
                // =========================
                Expanded(
                  child: Column(
                    children: [
                      // =========================
                      // AVAILABLE PERMISSIONS
                      // =========================
                      Expanded(
                        flex: 2,

                        child: Card(
                          elevation: 3,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(12),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  "Available Permissions",

                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Expanded(
                                  child: ListView.builder(
                                    itemCount: controller.permissions.length,

                                    itemBuilder: (context, index) {
                                      final permission =
                                          controller.permissions[index];

                                      final int id = permission['id'];

                                      final String name = permission['name'];

                                      final bool isSelected = controller
                                          .selectedPermissions
                                          .contains(id);

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),

                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.green.withOpacity(0.12)
                                              : Colors.grey.withOpacity(0.05),

                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),

                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.green
                                                : Colors.grey.shade300,
                                          ),
                                        ),

                                        child: CheckboxListTile(
                                          value: isSelected,

                                          activeColor: Colors.green,

                                          controlAffinity:
                                              ListTileControlAffinity.leading,

                                          title: Text(
                                            name,

                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),

                                          onChanged: (value) {
                                            controller.togglePermission(id);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // =========================
                      // ASSIGNED PERMISSIONS
                      // =========================
                      Expanded(
                        child: Card(
                          elevation: 3,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),

                          child: Padding(
                            padding: const EdgeInsets.all(12),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  "Assigned Permissions",

                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Expanded(
                                  child: controller.selectedPermissions.isEmpty
                                      ? const Center(
                                          child: Text(
                                            "No Permissions Assigned",
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: controller
                                              .selectedPermissions
                                              .length,

                                          itemBuilder: (context, index) {
                                            final selectedId = controller
                                                .selectedPermissions[index];

                                            final permission = controller
                                                .permissions
                                                .firstWhere(
                                                  (element) =>
                                                      element['id'] ==
                                                      selectedId,
                                                );

                                            return Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 8,
                                              ),

                                              padding: const EdgeInsets.all(12),

                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(
                                                  0.1,
                                                ),

                                                borderRadius:
                                                    BorderRadius.circular(10),

                                                border: Border.all(
                                                  color: Colors.green,
                                                ),
                                              ),

                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.check_circle,

                                                    color: Colors.green,
                                                  ),

                                                  const SizedBox(width: 10),

                                                  Expanded(
                                                    child: Text(
                                                      permission['name'],

                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // =========================
                // SAVE BUTTON
                // =========================
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () async {
                      if (controller.selectedRoleId.value == null) {
                        Get.snackbar("Error", "Please select a role");

                        return;
                      }

                      final message = await controller.assignPermissions();

                      Get.snackbar(
                        "Success",
                        message,

                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },

                    child: const Text(
                      "Save Permissions",

                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
