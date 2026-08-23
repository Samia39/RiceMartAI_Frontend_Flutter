import 'package:flutter/material.dart';
import '../../../core/utils/themes.dart';
import 'admin_dashboard_tab.dart';
import '../shops/admin_shops_tab.dart';
import '../orders/admin_orders_screen.dart';
import '../payments/payment_screen.dart';

class AdminHomeShell extends StatefulWidget {
  const AdminHomeShell({super.key});

  @override
  State<AdminHomeShell> createState() => _AdminHomeShellState();
}

class _AdminHomeShellState extends State<AdminHomeShell> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    AdminDashboardTab(),
    AdminShopsTab(),
    AdminOrdersScreen(),
    PaymentScreen(),
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
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        // Translucent cream + a hint of gold, echoing AppDecorations.card
        // instead of a flat opaque block — blends into the gradient body
        // rather than sitting on top of it.
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final selected = _selectedIndex == i;
              return _NavButton(
                item: item,
                selected: selected,
                onTap: () => setState(() => _selectedIndex = i),
              );
            }),
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
          // Golden underline accent — same language as the app's
          // TabBar indicatorColor: AppColors.golden, so the selected
          // state reads consistently across the whole admin panel.
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
