import 'package:flutter/material.dart';

import '../../../core/utils/themes.dart';

class ShopDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> shop;

  const ShopDetailsScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final riceList = shop["rice_categories"] ?? [];

    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: Text(shop["shop_name"] ?? "")),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // SHOP INFO
              Container(
                padding: const EdgeInsets.all(16),

                decoration: AppDecorations.card,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      shop["shop_name"] ?? "",
                      style: AppTextStyles.heading2,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Owner: ${shop["owner_name"]}",
                      style: AppTextStyles.bodyLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Phone: ${shop["phone"]}",
                      style: AppTextStyles.bodyLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Address: ${shop["address"]}",
                      style: AppTextStyles.bodyLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      shop["description"] ?? "",
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // TITLE
              Text("Available Rice", style: AppTextStyles.heading3),

              const SizedBox(height: 14),

              // EMPTY
              if (riceList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),

                  decoration: AppDecorations.card,

                  child: const Text("No rice available"),
                ),

              // RICE LIST
              ...riceList.map<Widget>((rice) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),

                  padding: const EdgeInsets.all(16),

                  decoration: AppDecorations.card,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(rice["name"] ?? "", style: AppTextStyles.heading4),

                      const SizedBox(height: 10),

                      Text(
                        "Price: Rs ${rice["price"]}",
                        style: AppTextStyles.bodyLarge,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Stock: ${rice["stock"]} KG",
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
