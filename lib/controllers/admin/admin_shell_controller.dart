import 'package:get/get.dart';

/// Stable identifiers for each admin dashboard tab. Using an enum instead
/// of a raw index means the Drawer never needs to know which position a
/// tab happens to sit at in AdminHomeShell's filtered, permission-based
/// tab list — it just asks for the tab it means, and the shell resolves
/// it to whatever index that tab currently occupies (or ignores it if the
/// admin doesn't have permission to see it at all).
enum AdminTab { dashboard, shops, orders, payments }

/// Lets the AdminDrawer switch AdminHomeShell's bottom-nav tab
/// (and the Shops sub-tab) instead of pushing a duplicate screen.
class AdminShellController extends GetxController {
  final Rx<AdminTab> selectedTab = AdminTab.dashboard.obs;

  // 0 = Pending, 1 = Approved, 2 = Rejected (matches AdminShopsTab's TabController)
  final RxInt shopsSubTabIndex = 0.obs;

  void goToTab(AdminTab tab) {
    selectedTab.value = tab;
  }

  void goToShopsTab(int subTabIndex) {
    selectedTab.value = AdminTab.shops;
    shopsSubTabIndex.value = subTabIndex;
  }
}
