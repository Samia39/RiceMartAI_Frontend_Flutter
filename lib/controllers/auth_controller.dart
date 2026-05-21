import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/screens/admin_screens/dashboard/admin_dashboard.dart';
import 'package:frontend/screens/buyer/dashboard/buyer_dashboard_screen.dart';
import 'package:frontend/screens/seller/dashboard/seller_dashboard_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final box = GetStorage();

  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");

      return;
    }

    try {
      isLoading.value = true;

      var response = await _authService.login(email, password);

      print(response);

      if (response['token'] != null) {
        box.erase();

        box.write('token', response['token']);
        box.write('role', response['role']);
        box.write('user', response['user']);

        final shop = response['shop'];

        box.write('has_shop', shop != null);

        if (shop != null) {
          box.write("shop_id", shop["id"]);
          box.write("shop_name", shop["shop_name"]);
          box.write("owner_name", shop["owner_name"]);
          box.write("phone", shop["phone"]);
          box.write("address", shop["address"]);
          box.write("description", shop["description"]);
        }

        Get.snackbar("Success", "Login successful");

        String role = "customer";

        if (response['roles'] != null && response['roles'].isNotEmpty) {
          role = response['roles'][0];
        }

        print("ROLE IS: $role");

        if (role == "admin") {
          Get.offAll(() => const AdminDashboard());
          return;
        }

        if (role == "seller") {
          if (shop != null && shop['status'] == 'approved') {
            Get.offAll(() => const SellerDashboardScreen());
          } else {
            Get.snackbar("Pending", "Your shop is waiting for admin approval");
          }

          return;
        }

        Get.offAll(() => const BuyerDashboardScreen());
      } else {
        Get.snackbar("Error", response['message'] ?? "Login failed");
      }
    } catch (e) {
      print(e);

      Get.snackbar("Error", "Server error");
    } finally {
      isLoading.value = false;
    }
  }
}
