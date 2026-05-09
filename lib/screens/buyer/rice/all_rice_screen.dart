import 'package:flutter/material.dart';

import '../../../core/services/rice_service.dart';
import '../../../core/utils/themes.dart';

import 'rice_detail_screen.dart';

class AllRiceScreen extends StatefulWidget {
  const AllRiceScreen({super.key});

  @override
  State<AllRiceScreen> createState() => _AllRiceScreenState();
}

class _AllRiceScreenState extends State<AllRiceScreen> {
  List<Map<String, dynamic>> riceList = [];

  List<Map<String, dynamic>> filteredRice = [];

  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    fetchRice();
  }

  // FETCH ALL RICE
  Future<void> fetchRice() async {
    final data = await RiceService().fetchAllRice();

    setState(() {
      riceList = data;

      filteredRice = data;

      isLoading = false;
    });
  }

  // SEARCH
  void searchRice(String value) {
    final results = riceList.where((rice) {
      final name = rice["name"].toString().toLowerCase();

      return name.contains(value.toLowerCase());
    }).toList();

    setState(() {
      filteredRice = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Rice Marketplace")),

        body: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              // SEARCH
              Container(
                decoration: AppDecorations.inputField,

                child: TextField(
                  controller: searchController,

                  onChanged: searchRice,

                  decoration: const InputDecoration(
                    hintText: "Search rice...",
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // LOADING
              if (isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              // EMPTY
              else if (filteredRice.isEmpty)
                const Expanded(child: Center(child: Text("No rice found")))
              // LIST
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredRice.length,

                    itemBuilder: (context, index) {
                      final rice = filteredRice[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (_) => RiceDetailScreen(rice: rice),
                            ),
                          );
                        },

                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),

                          padding: const EdgeInsets.all(16),

                          decoration: AppDecorations.card,

                          child: Row(
                            children: [
                              // ICON
                              Container(
                                width: 70,
                                height: 70,

                                decoration: BoxDecoration(
                                  color: AppColors.cream,

                                  borderRadius: BorderRadius.circular(16),
                                ),

                                child: const Icon(
                                  Icons.rice_bowl,
                                  size: 40,
                                  color: AppColors.darkGreen,
                                ),
                              ),

                              const SizedBox(width: 16),

                              // INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      rice["name"] ?? "",

                                      style: AppTextStyles.heading4,
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      "Rs ${rice["price"]} / KG",

                                      style: AppTextStyles.bodyLarge,
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      "Stock: ${rice["stock"]} KG",

                                      style: AppTextStyles.bodyMedium,
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      rice["shop"]?["shop_name"] ?? "",

                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(Icons.arrow_forward_ios, size: 18),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
