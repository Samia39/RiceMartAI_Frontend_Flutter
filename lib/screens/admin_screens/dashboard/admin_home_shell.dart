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

  late final List<_TabEntry> _visibleTabs;

  @override
  void initState() {
    super.initState();

    final allTabs = <_TabEntry>[
      _TabEntry(
        tab: AdminTab.dashboard,
        permission: 'view admin dashboard',
        title: "Admin Dashboard",
        page: const AdminDashboardTab(),
        nav: const _NavItemData(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          label: "Dashboard",
        ),
      ),
      _TabEntry(
        tab: AdminTab.shops,
        permission: 'view all shops',
        title: "Shops",
        page: const AdminShopsTab(),
        nav: const _NavItemData(
          icon: Icons.store_outlined,
          activeIcon: Icons.store,
          label: "Shops",
        ),
      ),
      _TabEntry(
        tab: AdminTab.orders,
        permission: 'view all orders',
        title: "Orders",
        page: const AdminOrdersScreen(),
        nav: const _NavItemData(
          icon: Icons.shopping_bag_outlined,
          activeIcon: Icons.shopping_bag,
          label: "Orders",
        ),
      ),
      _TabEntry(
        tab: AdminTab.payments,
        permission: 'view all payments',
        title: "Payments",
        page: const PaymentScreen(),
        nav: const _NavItemData(
          icon: Icons.payments_outlined,
          activeIcon: Icons.payments,
          label: "Payments",
        ),
      ),
    ];

    _visibleTabs = allTabs
        .where((tab) => PermissionService.hasPermission(tab.permission))
        .toList();

    // If the controller's currently-selected tab isn't one this admin can
    // see (e.g. Drawer requested a tab with no permission, or a permission
    // was revoked since last login), fall back to the first visible tab.
    if (!_visibleTabs.any((t) => t.tab == _shellController.selectedTab.value)) {
      if (_visibleTabs.isNotEmpty) {
        _shellController.selectedTab.value = _visibleTabs.first.tab;
      }
    }
  }

  int get _selectedIndex {
    final index = _visibleTabs.indexWhere(
      (t) => t.tab == _shellController.selectedTab.value,
    );
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    if (_visibleTabs.isEmpty) {
      return Container(
        decoration: AppDecorations.gradientBackground,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          drawer: const AdminDrawer(),
          appBar: AppBar(title: const Text("Admin")),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                "You don't have any permissions assigned yet.\nPlease contact Super Admin.",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: const AdminDrawer(),
        appBar: AppBar(
          title: Obx(() => Text(_visibleTabs[_selectedIndex].title)),
          centerTitle: true,
          actions: [
            if (PermissionService.hasPermission('create sellers'))
              _appBarAction(
                icon: Icons.add,
                label: "Add Shop",
                color: AppColors.darkGreen,
                onTap: () => Get.toNamed(AppRoutes.addSeller),
              ),
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
            index: _selectedIndex,
            children: _visibleTabs.map((t) => t.page).toList(),
          ),
        ),
        bottomNavigationBar: _visibleTabs.length > 1 ? _buildBottomNav() : null,
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
              children: List.generate(_visibleTabs.length, (i) {
                final entry = _visibleTabs[i];
                final selected = _selectedIndex == i;

                return _NavButton(
                  item: entry.nav,
                  selected: selected,
                  onTap: () => _shellController.selectedTab.value = entry.tab,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabEntry {
  final AdminTab tab;
  final String permission;
  final String title;
  final Widget page;
  final _NavItemData nav;

  const _TabEntry({
    required this.tab,
    required this.permission,
    required this.title,
    required this.page,
    required this.nav,
  });
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
