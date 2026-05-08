import 'package:flutter/material.dart';
import 'package:frontend/core/services/shop_service.dart';
import 'package:get_storage/get_storage.dart';

import '../shop/create_shop_screen.dart';
import '../rice/add_rice_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  bool hasShop = false;
  bool isApproved = false;

  @override
  void initState() {
    super.initState();

    loadSellerData();

    checkApprovalStatus();
  }

  void loadSellerData() {
    final box = GetStorage();

    hasShop = box.read("has_shop") ?? false;

    isApproved = box.read("shop_approved") ?? false;

    setState(() {});
  }

  Future<void> checkApprovalStatus() async {
    final box = GetStorage();

    int? savedShopId = box.read("shop_id");

    if (savedShopId == null) return;

    final shops = await ShopService().fetchApprovedShops();

    bool approved = shops.any((shop) => shop["id"] == savedShopId);

    if (approved) {
      box.write("shop_approved", true);

      isApproved = true;

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // NO SHOP
    if (!hasShop) {
      return const CreateShopScreen();
    }

    // PENDING APPROVAL
    if (hasShop && !isApproved) {
      return const Scaffold(
        body: Center(child: Text("Your shop is pending admin approval")),
      );
    }

    // APPROVED
    return const AddRiceScreen();
  }
}
