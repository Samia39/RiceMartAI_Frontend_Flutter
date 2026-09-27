import 'package:get/get.dart';

enum AdminTab { dashboard, shops, orders, payments }

class AdminShellController extends GetxController {
  final Rx<AdminTab> selectedTab = AdminTab.dashboard.obs;

  final RxInt shopsSubTabIndex = 0.obs;

  void goToTab(AdminTab tab) {
    selectedTab.value = tab;
  }

  void goToShopsTab(int subTabIndex) {
    selectedTab.value = AdminTab.shops;
    shopsSubTabIndex.value = subTabIndex;
  }
}
