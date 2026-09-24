import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin/user_management/roles_controller.dart';
import '../../../core/utils/themes.dart';

class RolesScreen extends StatelessWidget {
  RolesScreen({super.key});

  final controller = Get.put(RolesController());

  // ---------------- Add / Edit form (shown inside a dialog) ----------------

  Widget _formCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      decoration: BoxDecoration(
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
                  Icons.security,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => Text(
                    controller.editingRoleId.value == 0
                        ? "Add Role"
                        : "Edit Role",
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

          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 2),
            child: Text(
              "Role Name",
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen.withOpacity(0.80),
                letterSpacing: 0.2,
              ),
            ),
          ),
          TextField(
            controller: controller.roleController,
            style: TextStyle(color: AppColors.darkGreen, fontSize: 14.5),
            decoration: InputDecoration(
              hintText: "e.g. moderator",
              hintStyle: TextStyle(
                color: AppColors.darkGreen.withOpacity(0.45),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.55),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.borderGold.withOpacity(0.6),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.borderGold.withOpacity(0.6),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.darkGreen, width: 1.6),
              ),
            ),
          ),

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
                  if (controller.editingRoleId.value == 0) {
                    controller.createRole();
                  } else {
                    controller.updateRole();
                  }
                  Navigator.of(context).pop();
                },
                child: Text(
                  controller.editingRoleId.value == 0
                      ? "Create Role"
                      : "Update Role",
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

  // ---------------- Roles list (name only) ----------------

  Widget _listCard(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.roles.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text("No roles yet.", style: AppTextStyles.bodyMedium),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: controller.roles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final role = controller.roles[index];

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.golden,
                      child: Icon(
                        Icons.security,
                        color: AppColors.cream,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        role['name'] ?? '',
                        style: AppTextStyles.heading4,
                        overflow: TextOverflow.ellipsis,
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
                          controller.setEditRole(role);
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
                          controller.deleteRole(role['id']);
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
            title: const Text("Roles Management"),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: _listCard(context),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              controller.roleController.clear();
              controller.editingRoleId.value = 0;
              _openFormDialog(context);
            },
            backgroundColor: AppColors.darkGreen,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Add Role",
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
