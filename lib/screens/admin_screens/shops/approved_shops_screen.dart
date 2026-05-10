import 'package:flutter/material.dart';
import 'package:frontend/core/services/shop_service.dart';

import '../../../core/utils/themes.dart';

class ApprovedShopsScreen extends StatefulWidget {
  const ApprovedShopsScreen({super.key});

  @override
  State<ApprovedShopsScreen> createState() => _ApprovedShopsScreenState();
}

class _ApprovedShopsScreenState extends State<ApprovedShopsScreen> {
  List shops = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadApproved();
  }

  Future loadApproved() async {
    final data = await ShopService().fetchApprovedShops();

    setState(() {
      shops = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Approved Shops")),

        body: loading
            ? const Center(child: CircularProgressIndicator())
            : shops.isEmpty
            ? Center(
                child: Text("No approved shops", style: AppTextStyles.heading4),
              )
            : RefreshIndicator(
                onRefresh: loadApproved,

                child: ListView.builder(
                  padding: const EdgeInsets.all(14),

                  itemCount: shops.length,

                  itemBuilder: (context, index) {
                    final shop = shops[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),

                      padding: const EdgeInsets.all(16),

                      decoration: AppDecorations.card,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // SHOP NAME
                          Text(
                            shop["shop_name"],

                            style: AppTextStyles.heading3,
                          ),

                          const SizedBox(height: 14),

                          // OWNER
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: AppColors.darkGreen,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  "Owner: ${shop["owner_name"]}",

                                  style: AppTextStyles.bodyLarge,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // PHONE
                          Row(
                            children: [
                              const Icon(
                                Icons.phone,
                                color: AppColors.darkGreen,
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Text(
                                  "Phone: ${shop["phone"]}",

                                  style: AppTextStyles.bodyLarge,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // STATUS
                          Row(
                            children: [
                              const Icon(Icons.verified, color: Colors.green),

                              const SizedBox(width: 8),

                              Text(
                                "Status: ${shop["status"]}",

                                style: AppTextStyles.bodyLarge,
                              ),
                            ],
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
