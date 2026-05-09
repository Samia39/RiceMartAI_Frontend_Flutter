import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/services/shop_service.dart';
import '../../../core/utils/themes.dart';
import '../shop/edit_shop_screen.dart';

class MyShopScreen extends StatefulWidget {
  const MyShopScreen({super.key});

  @override
  State<MyShopScreen> createState() => _MyShopScreenState();
}

class _MyShopScreenState extends State<MyShopScreen> {
  String shopName = "";
  String ownerName = "";
  String phone = "";
  String address = "";
  String description = "";

  @override
  void initState() {
    super.initState();

    loadShopData();
  }

  void loadShopData() {
    final box = GetStorage();

    shopName = box.read("shop_name") ?? "";
    ownerName = box.read("owner_name") ?? "";
    phone = box.read("phone") ?? "";
    address = box.read("address") ?? "";
    description = box.read("description") ?? "";

    setState(() {});
  }

  // =========================
  // DELETE SHOP
  // =========================
  Future<void> deleteShop() async {
    final box = GetStorage();

    String token = box.read("token") ?? "";

    int? shopId = box.read("shop_id");

    if (shopId == null) return;

    final result = await ShopService().deleteShop(token: token, shopId: shopId);

    if (result["success"] == true) {
      // CLEAR STORAGE
      box.remove("has_shop");
      box.remove("shop_approved");
      box.remove("shop_id");

      box.remove("shop_name");
      box.remove("owner_name");
      box.remove("phone");
      box.remove("address");
      box.remove("description");

      Get.snackbar("Success", "Shop deleted");

      Get.back();
    } else {
      Get.snackbar("Error", "Failed to delete shop");
    }
  }

  Widget infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card,

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: AppColors.darkGreen),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(title, style: AppTextStyles.bodyMedium),

                const SizedBox(height: 4),

                Text(value, style: AppTextStyles.heading4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("My Shop")),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              infoTile(icon: Icons.store, title: "Shop Name", value: shopName),

              infoTile(icon: Icons.person, title: "Owner", value: ownerName),

              infoTile(icon: Icons.phone, title: "Phone", value: phone),

              infoTile(
                icon: Icons.location_on,
                title: "Address",
                value: address,
              ),

              infoTile(
                icon: Icons.info,
                title: "Description",
                value: description,
              ),

              const SizedBox(height: 30),

              // =========================
              // EDIT SHOP
              // =========================
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => const EditShopScreen());
                  },

                  icon: const Icon(Icons.edit),

                  label: const Text("Edit Shop"),
                ),
              ),

              const SizedBox(height: 14),

              // =========================
              // DELETE SHOP
              // =========================
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                  onPressed: () {
                    Get.defaultDialog(
                      title: "Delete Shop",
                      middleText: "Are you sure?",

                      textConfirm: "Delete",
                      textCancel: "Cancel",

                      confirmTextColor: Colors.white,

                      onConfirm: () {
                        Get.offAllNamed('/dashboard');
                        deleteShop();
                      },
                    );
                  },

                  icon: const Icon(Icons.delete),

                  label: const Text("Delete Shop"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
