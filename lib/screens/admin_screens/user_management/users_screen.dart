import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin/user_management/users_controller.dart';
import '../../../core/utils/themes.dart';

class UsersScreen extends StatelessWidget {
  UsersScreen({super.key});

  final controller = Get.put(UsersController());

  // ---------------- Role -> color mapping (kept high-contrast & readable) ----------------

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.info;
      case 'super_admin':
      case 'superadmin':
        return AppColors.error;
      case 'seller':
        return AppColors.warning;
      case 'customer':
        return AppColors.success;
      default:
        return AppColors.darkGreen;
    }
  }

  // ---------------- Count of users matching a filter option ----------------

  int _countFor(String role) {
    if (role == "All Users") return controller.users.length;
    return controller.users.where((u) {
      final roles = u['roles'] as List?;
      if (roles == null || roles.isEmpty) return false;
      return roles.any(
        (r) => (r['name'] ?? '').toString().toLowerCase() == role.toLowerCase(),
      );
    }).length;
  }

  // ---------------- Add / Edit form (shown inside a dialog) ----------------

  Widget _formCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      decoration: BoxDecoration(
        // Solid, on-theme cream card (no see-through) with a gold edge,
        // matching the rest of the app instead of a plain white sheet.
        color: const Color(0xFFEDE6D3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGold, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_alt_1,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => Text(
                    controller.editingUserId.value == 0
                        ? "Add User"
                        : "Edit User",
                    style: AppTextStyles.heading3,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.darkGreen,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          _fieldLabel("Name"),
          _formField(controller.nameController, "Name"),
          const SizedBox(height: 16),

          _fieldLabel("Email"),
          _formField(controller.emailController, "@gmail.com"),
          const SizedBox(height: 16),

          _fieldLabel("Password"),
          _formField(controller.passwordController, "••••••••", obscure: true),
          const SizedBox(height: 16),

          _fieldLabel("Role"),
          Obx(() {
            return DropdownButtonFormField<String>(
              value: controller.selectedRole.value.isEmpty
                  ? null
                  : controller.selectedRole.value,
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.darkGreen),
              dropdownColor: const Color(0xFFF3EEDD),
              style: TextStyle(color: AppColors.darkGreen, fontSize: 14.5),
              decoration: _fieldDecoration(),
              items: controller.roles.map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (value) {
                controller.selectedRole.value = value!;
              },
            );
          }),

          const SizedBox(height: 26),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: AppColors.borderGold, width: 1),
                  ),
                ),
                onPressed: () {
                  if (controller.editingUserId.value == 0) {
                    controller.createUser();
                  } else {
                    controller.updateUser();
                  }
                  Navigator.of(context).pop();
                },
                child: Text(
                  controller.editingUserId.value == 0
                      ? "Create User"
                      : "Update User",
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreen.withOpacity(0.80),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.darkGreen.withOpacity(0.45)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.55),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderGold.withOpacity(0.6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderGold.withOpacity(0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkGreen, width: 1.6),
      ),
    );
  }

  Widget _formField(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: AppColors.darkGreen, fontSize: 14.5),
      decoration: _fieldDecoration(hint: hint),
    );
  }

  void _openFormDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth > 480 ? 420 : screenWidth,
              maxHeight: screenHeight * 0.85,
            ),
            child: SingleChildScrollView(child: _formCard(context)),
          ),
        );
      },
    );
  }

  // ---------------- Role filter chips (with live counts) ----------------

  Widget _roleFilters() {
    return Obx(() {
      // "All Users" plus every role coming from the controller, so the
      // chips automatically match whatever roles exist in the database.
      final roleOptions = ["All Users", ...controller.roles];
      final selected = controller.selectedRoleFilter.value;

      return SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: roleOptions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final role = roleOptions[index];
            final isSelected = role == selected;
            final chipColor = role == "All Users"
                ? AppColors.golden
                : _roleColor(role);
            final count = _countFor(role);

            return GestureDetector(
              onTap: () => controller.selectedRoleFilter.value = role,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? chipColor
                      : Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? chipColor
                        : AppColors.borderGold.withOpacity(0.55),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      role,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.darkGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.30)
                            : AppColors.darkGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "$count",
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.darkGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ---------------- User list ----------------

  Widget _listCard(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final selectedRole = controller.selectedRoleFilter.value;
      final users = controller.users.where((user) {
        if (selectedRole == "All Users") return true;
        final roles = user['roles'] as List?;
        if (roles == null || roles.isEmpty) return false;
        return roles.any(
          (r) =>
              (r['name'] ?? '').toString().toLowerCase() ==
              selectedRole.toLowerCase(),
        );
      }).toList();

      if (users.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              "No users found for this role.",
              style: AppTextStyles.bodyMedium,
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = users[index];
          final roleName = (user['roles'] as List).isNotEmpty
              ? user['roles'][0]['name']
              : 'No Role';
          final badgeColor = _roleColor(roleName);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.golden,
                      child: Text(
                        (user['name'] ?? '?').toString().isNotEmpty
                            ? user['name'][0].toString().toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: AppColors.cream,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'] ?? '',
                            style: AppTextStyles.heading4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user['email'] ?? '',
                            style: AppTextStyles.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              roleName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkGreen,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: BorderSide(color: AppColors.borderGold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          controller.setEditUser(user);
                          _openFormDialog(context);
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text(
                          "Edit",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          controller.deleteUser(user['id']);
                        },
                        icon: const Icon(
                          Icons.delete,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Delete",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Users Management"),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _roleFilters(),
                const SizedBox(height: 16),
                Expanded(child: _listCard(context)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              controller.clearFields();
              if (controller.roles.isNotEmpty) {
                controller.selectedRole.value = controller.roles.first;
              }
              _openFormDialog(context);
            },
            backgroundColor: AppColors.darkGreen,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Add User",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
