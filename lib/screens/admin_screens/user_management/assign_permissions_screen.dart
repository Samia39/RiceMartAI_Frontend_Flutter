import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ricemart_ai/core/utils/themes.dart';

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

  // =========================
  // SEARCH
  // =========================

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign Permissions"),
        centerTitle: true,
      ),

      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: GetBuilder<PermissionsController>(
          builder: (controller) {
            // =========================
            // FILTERED PERMISSIONS
            // =========================
            final List filteredPermissions = _searchQuery.isEmpty
                ? controller.permissions
                : controller.permissions
                      .where(
                        (p) => p['name'].toString().toLowerCase().contains(
                          _searchQuery,
                        ),
                      )
                      .toList();

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

                          child: Container(
                            decoration: AppDecorations.card,

                            child: Padding(
                              padding: const EdgeInsets.all(12),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    "Available Permissions",
                                    style: AppTextStyles.heading3,
                                  ),

                                  const SizedBox(height: 10),

                                  // =========================
                                  // SEARCH FIELD
                                  // =========================
                                  TextField(
                                    controller: _searchController,

                                    style: AppTextStyles.bodyMedium,

                                    decoration: InputDecoration(
                                      hintText: "Search permissions...",
                                      hintStyle: AppTextStyles.hint,

                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: AppColors.iconMuted,
                                      ),

                                      suffixIcon: _searchQuery.isEmpty
                                          ? null
                                          : IconButton(
                                              icon: Icon(
                                                Icons.clear,
                                                color: AppColors.iconMuted,
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(() {
                                                  _searchQuery = "";
                                                });
                                              },
                                            ),

                                      isDense: true,

                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),

                                      filled: true,
                                      fillColor: AppColors.inputFill,

                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: AppColors.inputBorder,
                                        ),
                                      ),

                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                          color: AppColors.darkGreen,
                                          width: 2,
                                        ),
                                      ),
                                    ),

                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value
                                            .trim()
                                            .toLowerCase();
                                      });
                                    },
                                  ),

                                  const SizedBox(height: 10),

                                  Expanded(
                                    child: filteredPermissions.isEmpty
                                        ? Center(
                                            child: Text(
                                              "No matching permissions",
                                              style: AppTextStyles.bodyMedium,
                                            ),
                                          )
                                        : ListView.builder(
                                            itemCount:
                                                filteredPermissions.length,

                                            itemBuilder: (context, index) {
                                              final permission =
                                                  filteredPermissions[index];

                                              final int id = permission['id'];

                                              final String name =
                                                  permission['name'];

                                              final bool isSelected = controller
                                                  .selectedPermissions
                                                  .contains(id);

                                              return Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),

                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColors.golden
                                                            .withOpacity(0.18)
                                                      : AppColors.cream
                                                            .withOpacity(0.20),

                                                  borderRadius:
                                                      BorderRadius.circular(12),

                                                  border: Border.all(
                                                    color: isSelected
                                                        ? AppColors.golden
                                                        : AppColors.borderGold
                                                              .withOpacity(
                                                                0.55,
                                                              ),
                                                  ),
                                                ),

                                                child: CheckboxListTile(
                                                  value: isSelected,

                                                  activeColor: AppColors.golden,

                                                  controlAffinity:
                                                      ListTileControlAffinity
                                                          .leading,

                                                  title: Text(
                                                    name,

                                                    style: TextStyle(
                                                      fontWeight: isSelected
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      color:
                                                          AppColors.darkGreen,
                                                    ),
                                                  ),

                                                  onChanged: (value) {
                                                    controller.togglePermission(
                                                      id,
                                                    );
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
                          child: Container(
                            decoration: AppDecorations.card,

                            child: Padding(
                              padding: const EdgeInsets.all(12),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    "Assigned Permissions",
                                    style: AppTextStyles.heading3,
                                  ),

                                  const SizedBox(height: 10),

                                  Expanded(
                                    child:
                                        controller.selectedPermissions.isEmpty
                                        ? Center(
                                            child: Text(
                                              "No Permissions Assigned",
                                              style: AppTextStyles.bodyMedium,
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

                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),

                                                decoration: BoxDecoration(
                                                  color: AppColors.golden
                                                      .withOpacity(0.14),

                                                  borderRadius:
                                                      BorderRadius.circular(10),

                                                  border: Border.all(
                                                    color: AppColors.golden,
                                                  ),
                                                ),

                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,

                                                      color: AppColors.golden,
                                                    ),

                                                    const SizedBox(width: 10),

                                                    Expanded(
                                                      child: Text(
                                                        permission['name'],

                                                        style: AppTextStyles
                                                            .bodyLarge
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
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
                      style: AppButtonStyles.primary,

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

                      child: Text(
                        "Save Permissions",
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
