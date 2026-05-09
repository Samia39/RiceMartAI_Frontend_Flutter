import 'package:flutter/material.dart';

import '../../../core/utils/themes.dart';

class RiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> rice;

  const RiceDetailScreen({super.key, required this.rice});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: Text(rice["name"] ?? "Rice Details")),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // IMAGE
              Container(
                height: 220,
                width: double.infinity,

                decoration: AppDecorations.card,

                child: const Icon(
                  Icons.rice_bowl,
                  size: 100,
                  color: AppColors.darkGreen,
                ),
              ),

              const SizedBox(height: 20),

              // RICE INFO
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: AppDecorations.card,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(rice["name"] ?? "", style: AppTextStyles.heading2),

                    const SizedBox(height: 14),

                    Text(
                      "Price: Rs ${rice["price"]}",
                      style: AppTextStyles.heading4,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Stock: ${rice["stock"]} KG",
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SHOP INFO
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: AppDecorations.card,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text("Seller Information", style: AppTextStyles.heading3),

                    const SizedBox(height: 16),

                    infoTile(
                      icon: Icons.store,
                      title: "Shop",
                      value: rice["shop"]["shop_name"] ?? "",
                    ),

                    infoTile(
                      icon: Icons.person,
                      title: "Owner",
                      value: rice["shop"]["owner_name"] ?? "",
                    ),

                    infoTile(
                      icon: Icons.phone,
                      title: "Phone",
                      value: rice["shop"]["phone"] ?? "",
                    ),

                    infoTile(
                      icon: Icons.location_on,
                      title: "Address",
                      value: rice["shop"]["address"] ?? "",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},

                      icon: const Icon(Icons.call),

                      label: const Text("Call"),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},

                      icon: const Icon(Icons.chat),

                      label: const Text("WhatsApp"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Row(
        children: [
          Icon(icon, color: AppColors.darkGreen),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(title, style: AppTextStyles.bodyMedium),

                const SizedBox(height: 4),

                Text(value, style: AppTextStyles.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
