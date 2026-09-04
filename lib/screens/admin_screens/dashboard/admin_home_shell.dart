import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/themes.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/admin_drawer.dart';
import '../../../widgets/notification_bell.dart';
import '../../../core/services/admin/permission_service.dart';
import 'admin_dashboard_tab.dart';
import '../shops/admin_shops_tab.dart';
import '../orders/admin_orders_screen.dart';
import '../payments/payment_screen.dart';
import '../../../controllers/admin/admin_shell_controller.dart';

class AdminHomeShell extends StatefulWidget {
  const AdminHomeShell({super.key});

  @override
  State<AdminHomeShell> createState() => _AdminHomeShellState();
}

class _AdminHomeShellState extends State<AdminHomeShell> {
  final AdminShellController _shellController = Get.put(AdminShellController());

  final List<Widget> _tabs = const [
    AdminDashboardTab(),
    AdminShopsTab(),
    AdminOrdersScreen(),
    PaymentScreen(),
  ];

  // Titles shown in the persistent top bar per tab.
  static const List<String> _titles = [
    "Admin Dashboard",
    "Shops",
    "Orders",
    "Payments",
  ];

  static const List<_NavItemData> _navItems = [
    _NavItemData(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: "Dashboard",
    ),
    _NavItemData(
      icon: Icons.store_outlined,
      activeIcon: Icons.store,
      label: "Shops",
    ),
    _NavItemData(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
      label: "Orders",
    ),
    _NavItemData(
      icon: Icons.payments_outlined,
      activeIcon: Icons.payments,
      label: "Payments",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Drawer now lives here, so it's reachable from every tab.
        drawer: const AdminDrawer(),
        appBar: AppBar(
          title: Obx(() => Text(_titles[_shellController.selectedIndex.value])),
          centerTitle: true,
          actions: [
            if (PermissionService.hasPermission('create sellers'))
              _appBarAction(
                icon: Icons.add,
                label: "Add Shop",
                color: AppColors.darkGreen,
                onTap: () => Get.toNamed(AppRoutes.addSeller),
              ),

            // =========================
            // NOTIFICATIONS — now wrapped in the same icon+label layout as
            // Add Shop / Settings so all three sit at equal height with
            // matching labels underneath, instead of the bell floating alone.
            // =========================
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 38,
                    height: 38,
                    child: NotificationBell(iconColor: Colors.white, size: 27),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Alerts",
                    style: TextStyle(fontSize: 10, color: AppColors.darkGreen),
                  ),
                ],
              ),
            ),

            if (PermissionService.hasPermission('manage settings'))
              _appBarAction(
                icon: Icons.settings,
                label: "Settings",
                color: Colors.blue,
                onTap: () => Get.toNamed(AppRoutes.adminSettings),
              ),
          ],
        ),
        body: Obx(
          () => IndexedStack(
            index: _shellController.selectedIndex.value,
            children: _tabs,
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _appBarAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cream.withOpacity(0.92),
            AppColors.cream.withOpacity(0.98),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: AppColors.borderGold.withOpacity(0.55)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final selected = _shellController.selectedIndex.value == i;

                return _NavButton(
                  item: item,
                  selected: selected,
                  onTap: () => _shellController.selectedIndex.value = i,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavButton extends StatelessWidget {
  final _NavItemData item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? item.activeIcon : item.icon,
            color: selected
                ? AppColors.darkGreen
                : AppColors.darkGreen.withOpacity(0.4),
            size: 23,
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? AppColors.darkGreen
                  : AppColors.darkGreen.withOpacity(0.4),
            ),
            child: Text(item.label),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 3,
            width: selected ? 22 : 0,
            decoration: BoxDecoration(
              color: AppColors.golden,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
