import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/core/services/shop_service.dart';
import '../../../core/utils/themes.dart';

class ShopDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> shop;

  const ShopDetailsScreen({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final List riceCategories =
        shop["rice_categories"] ?? shop["riceCategories"] ?? [];

    String cnicImage = "";
    if (shop["cnic_image"] != null &&
        shop["cnic_image"].toString().isNotEmpty) {
      cnicImage = "http://127.0.0.1:8000/storage/${shop["cnic_image"]}";
    }

    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text("Seller Verification"),
          centerTitle: true,
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.all(18),
                decoration: AppDecorations.card,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 32,
                      child: Icon(Icons.store, size: 32),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop["shop_name"] ?? "-",
                            style: AppTextStyles.heading3,
                          ),

                          const SizedBox(height: 6),

                          Text(
                            (shop["status"] ?? "pending")
                                .toString()
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SELLER INFO
              sectionTitle("Seller Information"),

              infoCard([
                infoRow("Owner", shop["owner_name"]),
                infoRow("CNIC", shop["cnic"]),
                infoRow("Phone", shop["phone"]),
                infoRow("Address", shop["address"]),
              ]),

              const SizedBox(height: 20),

              // SHOP INFO
              sectionTitle("Shop Information"),

              infoCard([
                infoRow("Shop Name", shop["shop_name"]),
                infoRow("Description", shop["description"]),
              ]),

              const SizedBox(height: 20),

              // CNIC
              sectionTitle("CNIC Document"),

              Container(
                height: 220,
                width: double.infinity,
                decoration: AppDecorations.card,
                child: cnicImage.isNotEmpty
                    ? InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) {
                              return Dialog(
                                child: InteractiveViewer(
                                  child: Image.network(
                                    cnicImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(cnicImage, fit: BoxFit.cover),
                        ),
                      )
                    : const Center(child: Text("No CNIC image")),
              ),

              const SizedBox(height: 20),

              // RICE
              sectionTitle("Rice Categories"),

              if (riceCategories.isEmpty)
                const Text("No rice categories found")
              else
                ...riceCategories.map<Widget>((rice) {
                  String riceImage = "";

                  if (rice["image"] != null &&
                      rice["image"].toString().isNotEmpty) {
                    riceImage =
                        "http://127.0.0.1:8000/storage/${rice["image"]}";
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(16),
                    decoration: AppDecorations.card,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rice["name"] ?? "-",
                          style: AppTextStyles.heading4,
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: Text("Stock: ${rice["stock"]} Kg"),
                              ),
                            ),

                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: Text("Price: Rs ${rice["price"]}"),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (riceImage.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              riceImage,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          const Text("No rice image"),
                      ],
                    ),
                  );
                }).toList(),

              const SizedBox(height: 30),

              // BUTTONS
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        print(shop["id"]);

                        String token = GetStorage().read("token") ?? "";

                        final result = await ShopService().approveShop(
                          token: token,
                          shopId: int.parse(shop["id"].toString()),
                        );

                        print(result);

                        if (result["success"] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Shop Approved")),
                          );

                          Navigator.pop(context, true);
                        }
                      },

                      child: const Text("Approve"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        correctionDialog(context);
                      },
                      child: const Text("Correction"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    String token = GetStorage().read("token") ?? "";

                    final result = await ShopService().rejectShop(
                      token: token,
                      shopId: int.parse(shop["id"].toString()),
                    );

                    if (result["success"] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Shop Rejected")),
                      );

                      Navigator.pop(context, true);
                    }
                  },

                  child: const Text("Reject"),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTextStyles.heading3),
    );
  }

  Widget infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.card,
      child: Column(children: children),
    );
  }

  Widget infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 5, child: Text(value?.toString() ?? "-")),
        ],
      ),
    );
  }

  void correctionDialog(BuildContext context) {
    TextEditingController reason = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Request Correction"),

          content: TextField(
            controller: reason,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Write correction reason...",
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Correction: ${reason.text}")),
                );
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }
}
