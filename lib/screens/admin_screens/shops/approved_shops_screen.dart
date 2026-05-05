import 'package:flutter/material.dart';
import 'package:frontend/core/services/shop_service.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text("Approved Shops")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : shops.isEmpty
          ? const Center(child: Text("No approved shops"))
          : RefreshIndicator(
              onRefresh: loadApproved,
              child: ListView.builder(
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  final shop = shops[index];

                  return Card(
                    margin: const EdgeInsets.all(14),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop["shop_name"],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text("Owner: ${shop["owner_name"]}"),

                          Text("Phone: ${shop["phone"]}"),

                          Text("Status: ${shop["status"]}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
