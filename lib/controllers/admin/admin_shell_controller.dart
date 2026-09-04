import 'package:get/get.dart';

/// Lets the AdminDrawer switch AdminHomeShell's bottom-nav tab
/// (and the Shops sub-tab) instead of pushing a duplicate screen.
class AdminShellController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  // 0 = Pending, 1 = Approved, 2 = Rejected (matches AdminShopsTab's TabController)
  final RxInt shopsSubTabIndex = 0.obs;

  void goToTab(int index) {
    selectedIndex.value = index;
  }

  void goToShopsTab(int subTabIndex) {
    selectedIndex.value = 1; // Shops tab
    shopsSubTabIndex.value = subTabIndex;
  }
}
