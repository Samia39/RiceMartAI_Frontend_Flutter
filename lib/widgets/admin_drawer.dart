import 'package:flutter/material.dart';
import 'package:frontend/screens/admin_screens/complaints/admin_complaint_list_screen.dart';
import 'package:frontend/screens/admin_screens/courier_management/courier_charge_screen.dart';
import 'package:frontend/screens/admin_screens/payout/admin_payouts_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_routes.dart';
import '../controllers/admin/user_management/permissions_controller.dart';
import '../core/utils/themes.dart';
import '../screens/admin_screens/courier_management/city_screen.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  // =========================
  // SAFE NAVIGATION HELPER
  // Closes the drawer first, then waits for the NEXT frame (i.e. after
  // the drawer's close animation has actually started/settled) before
  // pushing the new route. Doing Navigator.pop(context) and
  // Get.toNamed()/Get.to() back-to-back in the same callback causes the
  // Navigator transition lock to clash, which is what was making the
  // drawer "stuck" until a hot restart.
  // =========================
  void _navigate(BuildContext context, VoidCallback action) {
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      action();
    });
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final userName = box.read("name") ?? "Admin";
    final userEmail = box.read("email") ?? "";

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
                drawerItem(
                  icon: Icons.dashboard,
                  title: "Dashboard",
                  onTap: () {
                    _navigate(context, () {
                      Get.toNamed(AppRoutes.adminDashboard);
                    });
                  },
                ),

                // PENDING SHOPS
                drawerItem(
                  icon: Icons.pending_actions,
                  title: "Pending Shops",
                  onTap: () {
                    _navigate(context, () {
                      Get.toNamed(AppRoutes.sellerApprovals);
                    });
                  },
                ),

                // APPROVED SHOPS
                drawerItem(
                  icon: Icons.verified,
                  title: "Approved Shops",
                  onTap: () {
                    _navigate(context, () {
                      Get.toNamed(AppRoutes.approvedShops);
                    });
                  },
                ),

                // ORDERS
                drawerItem(
                  icon: Icons.shopping_bag,
                  title: "Orders",
                  onTap: () {
                    _navigate(context, () {
                      Get.toNamed(AppRoutes.adminordersscreen);
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
                    // CITY SCREEN
                    ListTile(
                      leading: const Icon(
                        Icons.location_city,
                        color: AppColors.darkGreen,
                      ),
                      title: const Text("Cities"),
                      onTap: () {
                        _navigate(context, () {
                          Get.to(() => const CityScreen());
                        });
                      },
                    ),
                    // COURIER CHARGES
                    ListTile(
                      leading: const Icon(
                        Icons.attach_money,
                        color: AppColors.darkGreen,
                      ),
                      title: const Text("Courier Charges"),
                      onTap: () {
                        _navigate(context, () {
                          Get.to(() => const CourierChargeScreen());
                        });
                      },
                    ),
                  ],
                ),

                // PAYMENT APPROVALS
                drawerItem(
                  icon: Icons.pending_actions,
                  title: "Payment Approvals",
                  onTap: () {
                    _navigate(context, () {
                      Get.toNamed(AppRoutes.paymentScreen);
                    });
                  },
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

                // SELLER PAYOUTS
                drawerItem(
                  icon: Icons.account_balance_wallet,
                  title: "Seller Payouts",
                  onTap: () {
                    _navigate(context, () {
                      Get.to(() => const AdminPayoutsScreen());
                    });
                  },
                ),

                drawerItem(
                  icon: Icons.report_problem,
                  title: "Complaints",
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const AdminComplaintListScreen());
                  },
                ),

                // SETTINGS → navigates to profile.dart
                drawerItem(
                  icon: Icons.person,
                  title: "profiles",
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
              Get.offAllNamed("/login");
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
