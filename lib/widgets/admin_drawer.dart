import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ricemart_ai/core/services/admin/permission_service.dart';
import '../routes/app_routes.dart';
import '../controllers/admin/user_management/permissions_controller.dart';
import '../core/utils/themes.dart';
import '../controllers/admin/admin_shell_controller.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({super.key});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  final _box = GetStorage();
  VoidCallback? _storageUnsub;

  @override
  void initState() {
    super.initState();
    _storageUnsub = _box.listen(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _storageUnsub?.call();
    super.dispose();
  }

  void _navigate(BuildContext context, VoidCallback action) {
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      action();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = _box.read("name") ?? "Admin";
    final userEmail = _box.read("email") ?? "";

    return Drawer(
      backgroundColor: AppColors.cream,
      child: Column(
        children: [
          // HEADER
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.darkGreen),
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: AppColors.cream,
              child: Icon(
                Icons.admin_panel_settings,
                size: 40,
                color: AppColors.darkGreen,
              ),
            ),
          ),

          // SCROLLABLE MENU ITEMS
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // DASHBOARD
                if (PermissionService.hasPermission('view admin dashboard'))
                  drawerItem(
                    icon: Icons.dashboard,
                    title: "Dashboard",
                    onTap: () {
                      Navigator.pop(context);
                      Get.find<AdminShellController>().goToTab(
                        AdminTab.dashboard,
                      ); // was: goToTab(0)
                    },
                  ),

                // PENDING SHOPS
                drawerItem(
                  icon: Icons.pending_actions,
                  title: "Pending Shops",
                  onTap: () {
                    Navigator.pop(context);
                    Get.find<AdminShellController>().goToShopsTab(0);
                  },
                ),

                // APPROVED SHOPS
                drawerItem(
                  icon: Icons.verified,
                  title: "Approved Shops",
                  onTap: () {
                    Navigator.pop(context);
                    Get.find<AdminShellController>().goToShopsTab(1);
                  },
                ),

                // ORDERS
                if (PermissionService.hasPermission('view all orders'))
                  drawerItem(
                    icon: Icons.shopping_bag,
                    title: "Orders",
                    onTap: () {
                      Navigator.pop(context);
                      Get.find<AdminShellController>().goToTab(
                        AdminTab.orders,
                      ); // was: goToTab(2)
                    },
                  ),
                // PAYMENT APPROVALS
                if (PermissionService.hasPermission('view all payments'))
                  drawerItem(
                    icon: Icons.pending_actions,
                    title: "Payment Approvals",
                    onTap: () {
                      Navigator.pop(context);
                      Get.find<AdminShellController>().goToTab(
                        AdminTab.payments,
                      ); // was: goToTab(3)
                    },
                  ),

                //categories
                drawerItem(
                  icon: Icons.category,
                  title: "Manage Categories",
                  onTap: () {
                    _navigate(context, () {
                      Get.toNamed(AppRoutes.manageCategories);
                    });
                  },
                ),

                // USER MANAGEMENT
                ExpansionTile(
                  leading: const Icon(
                    Icons.admin_panel_settings,
                    color: AppColors.darkGreen,
                  ),
                  title: const Text(
                    "User Management",
                    style: TextStyle(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.only(left: 20),
                  children: [
                    // USERS
                    ListTile(
                      leading: const Icon(
                        Icons.people,
                        color: AppColors.darkGreen,
                      ),
                      title: const Text("Users"),
                      onTap: () {
                        _navigate(context, () {
                          Get.toNamed(AppRoutes.users);
                        });
                      },
                    ),

                    // ROLES
                    ListTile(
                      leading: const Icon(
                        Icons.badge,
                        color: AppColors.darkGreen,
                      ),
                      title: const Text("Roles"),
                      onTap: () {
                        _navigate(context, () {
                          Get.toNamed(AppRoutes.roles);
                        });
                      },
                    ),

                    // ASSIGN PERMISSIONS
                    ListTile(
                      leading: const Icon(
                        Icons.lock_open,
                        color: AppColors.darkGreen,
                      ),
                      title: const Text("Assign Permissions"),
                      onTap: () {
                        _navigate(context, () {
                          if (!Get.isRegistered<PermissionsController>()) {
                            Get.lazyPut<PermissionsController>(
                              () => PermissionsController(),
                              fenix: true,
                            );
                          }
                          Get.toNamed(AppRoutes.assignPermissions);
                        });
                      },
                    ),
                  ],
                ),

                // COURIER MANAGEMENT
                ExpansionTile(
                  leading: const Icon(
                    Icons.local_shipping,
                    color: AppColors.darkGreen,
                  ),
                  title: const Text(
                    "Courier Management",
                    style: TextStyle(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.only(left: 20),
                  children: [
                    // CITY SCREEN — converted from Get.to() to a named
                    // route so AuthMiddleware/PermissionMiddleware
                    // ('manage cities') actually run for it.
                    ListTile(
                      leading: const Icon(
                        Icons.location_city,
                        color: AppColors.darkGreen,
                      ),
                      title: const Text("Cities"),
                      onTap: () {
                        _navigate(context, () {
                          Get.toNamed(AppRoutes.adminCities);
                        });
                      },
                    ),
                    // COURIER CHARGES — same conversion as above.
                    ListTile(
                      leading: const Icon(
                        Icons.attach_money,
                        color: AppColors.darkGreen,
                      ),
                      title: const Text("Courier Charges"),
                      onTap: () {
                        _navigate(context, () {
                          Get.toNamed(AppRoutes.adminCourierCharges);
                        });
                      },
                    ),
                  ],
                ),

                // PAYMENT SETTINGS
                drawerItem(
                  icon: Icons.payment,
                  title: "Payment Settings",
                  onTap: () {
                    _navigate(context, () {
                      Get.toNamed(AppRoutes.adminPaymentSettings);
                    });
                  },
                ),

                // SELLER PAYOUTS — converted from Get.to() to a named
                // route so AuthMiddleware/PermissionMiddleware actually
                // run for it.
                drawerItem(
                  icon: Icons.account_balance_wallet,
                  title: "Seller Payouts",
                  onTap: () {
                    _navigate(context, () {
                      Get.toNamed(AppRoutes.adminPayouts);
                    });
                  },
                ),

                // COMPLAINTS — converted from Get.to() to a named route.
                // Functionally super_admin-only on the backend ('view
                // complaints' isn't assigned to plain admin), so a plain
                // admin tapping this now gets redirected to Access
                // Denied immediately instead of seeing a broken screen.
                drawerItem(
                  icon: Icons.report_problem,
                  title: "Complaints",
                  onTap: () {
                    _navigate(context, () {
                      Get.toNamed(AppRoutes.adminComplaints);
                    });
                  },
                ),

                // SETTINGS → navigates to profile.dart
                drawerItem(
                  icon: Icons.person,
                  title: "profile",
                  onTap: () {
                    _navigate(context, () {
                      Get.toNamed(AppRoutes.profile);
                    });
                  },
                ),
                drawerItem(
                  icon: Icons.settings,
                  title: "Settings",
                  onTap: () {
                    _navigate(context, () {
                      Get.toNamed(AppRoutes.adminSettings);
                    });
                  },
                ),
              ],
            ),
          ),

          // LOGOUT - always visible at bottom
          const Divider(height: 1),
          drawerItem(
            icon: Icons.logout,
            title: "Logout",
            color: Colors.red,
            onTap: () {
              GetStorage().erase();
              Get.offAllNamed(AppRoutes.login);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AppColors.darkGreen,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}
