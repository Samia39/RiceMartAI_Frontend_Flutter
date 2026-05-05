import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/core/services/shop_service.dart';
import '../../../core/utils/themes.dart';
import 'shop_details_screen.dart';

class ShopApprovalsScreen extends StatefulWidget {
  const ShopApprovalsScreen({super.key});

  @override
  State<ShopApprovalsScreen> createState() => _ShopApprovalsScreenState();
}

class _ShopApprovalsScreenState extends State<ShopApprovalsScreen> {
  List<Map<String, dynamic>> pendingShops = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadShops();
  }

  Future loadShops() async {
    String token = GetStorage().read("token") ?? "";

    final data = await ShopService().fetchPendingShops(token: token);

    setState(() {
      pendingShops = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Seller Approvals")),

        body: loading
            ? const Center(child: CircularProgressIndicator())
            : pendingShops.isEmpty
            ? Center(
                child: Text(
                  "No pending approvals",
                  style: AppTextStyles.heading3,
                ),
              )
            : RefreshIndicator(
                onRefresh: loadShops,

                child: ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: pendingShops.length,

                  itemBuilder: (context, index) {
                    final shop = pendingShops[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(18),
                      decoration: AppDecorations.card,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            shop["shop_name"] ?? "-",
                            style: AppTextStyles.heading3,
                          ),

                          const SizedBox(height: 10),

                          Text("Owner: ${shop["owner_name"] ?? "-"}"),

                          Text("CNIC: ${shop["cnic"] ?? "-"}"),

                          Text("Phone: ${shop["phone"] ?? "-"}"),

                          const SizedBox(height: 15),

                          ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ShopDetailsScreen(shop: shop),
                                ),
                              );

                              if (result == true) {
                                loadShops();
                              }
                            },

                            child: const Text("View Details"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
