import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin/user_management/users_controller.dart';
import '../../../core/utils/themes.dart';

class UsersScreen extends StatelessWidget {
  UsersScreen({super.key});

  final controller = Get.put(UsersController());

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(Icons.person_add),
              SizedBox(width: 10),
              Text(
                "Add User",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 20),

          buildField(controller.nameController, "Name"),
          buildField(controller.emailController, "Email"),
          buildField(controller.passwordController, "Password"),

          const SizedBox(height: 10),

          Obx(() {
            return DropdownButtonFormField<String>(
              value: controller.selectedRole.value.isEmpty
                  ? null
                  : controller.selectedRole.value,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.cream,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: controller.roles.map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (value) {
                controller.selectedRole.value = value!;
              },
            );
          }),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (controller.editingUserId.value == 0) {
                  controller.createUser();
                } else {
                  controller.updateUser();
                }
              },
              child: Obx(
                () => Text(
                  controller.editingUserId.value == 0
                      ? "Create User"
                      : "Update User",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final user = controller.users[index];

            return Card(
              child: ListTile(
                leading: Text(
                  "${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                title: Text(user['name']),
                subtitle: Text(
                  "${user['email']}\nRole: ${user['roles'].isNotEmpty ? user['roles'][0]['name'] : 'No Role'}",
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        controller.setEditUser(user);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        controller.deleteUser(user['id']);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Users Management"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;

            if (isWide) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(child: _formCard()),
                    ),
                    const SizedBox(width: 20),
                    Expanded(flex: 3, child: _listCard()),
                  ],
                ),
              );
            }

            // NARROW (mobile) — whole page scrolls as one; list gets a
            // fixed height instead of Expanded so it can sit inside the
            // outer scroll view without an unbounded-height conflict.
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _formCard(),
                  const SizedBox(height: 20),
                  SizedBox(height: 500, child: _listCard()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.cream,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
