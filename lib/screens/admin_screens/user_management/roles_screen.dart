import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin/user_management/roles_controller.dart';
import '../../../core/utils/themes.dart';

class RolesScreen extends StatelessWidget {
  RolesScreen({super.key});

  final controller = Get.put(RolesController());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text("Roles Management"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              // LEFT
              Expanded(
                flex: 2,

                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppDecorations.card,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Row(
                        children: [
                          Icon(Icons.security),

                          SizedBox(width: 10),

                          Text(
                            "Add Role",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: controller.roleController,

                        decoration: InputDecoration(
                          hintText: "Role Name",
                          filled: true,
                          fillColor: AppColors.cream,

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,

                        child: ElevatedButton(
                          onPressed: () {
                            if (controller.editingRoleId.value == 0) {
                              controller.createRole();
                            } else {
                              controller.updateRole();
                            }
                          },

                          child: Obx(
                            () => Text(
                              controller.editingRoleId.value == 0
                                  ? "Create Role"
                                  : "Update Role",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // RIGHT
              Expanded(
                flex: 3,

                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppDecorations.card,

                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      itemCount: controller.roles.length,

                      itemBuilder: (context, index) {
                        final role = controller.roles[index];

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.darkGreen,
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),

                            title: Text(role['name']),

                            subtitle: Text(
                              "Users: ${role['users_count']}\nCreated: ${role['created_at']}",
                            ),

                            isThreeLine: true,

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,

                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),

                                  onPressed: () {
                                    controller.setEditRole(role);
                                  },
                                ),

                                IconButton(
                                  icon: const Icon(Icons.delete),

                                  onPressed: () {
                                    controller.deleteRole(role['id']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
