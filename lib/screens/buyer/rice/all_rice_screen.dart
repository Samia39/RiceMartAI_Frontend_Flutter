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

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    fetchRice();
  }

  // =========================
  // FETCH ALL RICE
  // =========================
  Future<void> fetchRice() async {
    final data = await RiceService().fetchAllRice();

    setState(() {
      riceList = data;
      filteredRice = data;
      isLoading = false;
    });
  }

  // =========================
  // SEARCH
  // =========================
  void searchRice(String value) {
    final result = riceList.where((rice) {
      final name = rice["name"].toString().toLowerCase();

      return name.contains(value.toLowerCase());
    }).toList();

    setState(() {
      filteredRice = result;
    });
  }

  // =========================
  // PRODUCT CARD
  // =========================
  Widget riceCard(Map<String, dynamic> rice) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(builder: (_) => RiceDetailScreen(rice: rice)),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),

              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // IMAGE
            Container(
              height: 130,
              width: double.infinity,

              decoration: BoxDecoration(
                color: AppColors.cream,

                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),

              child: const Icon(
                Icons.rice_bowl,
                size: 60,
                color: AppColors.darkGreen,
              ),
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.all(12),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    rice["name"] ?? "",

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: AppTextStyles.heading4,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Rs ${rice["price"]}/KG",

                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.darkGreen,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Stock: ${rice["stock"]} KG",

                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Rice Marketplace")),

        body: Column(
          children: [
            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(16),

              child: Container(
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
            ),

            // LOADING
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            // EMPTY
            else if (filteredRice.isEmpty)
              const Expanded(child: Center(child: Text("No rice found")))
            // GRID
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),

                  itemCount: filteredRice.length,

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,

                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,

                    childAspectRatio: 0.68,
                  ),

                  itemBuilder: (context, index) {
                    return riceCard(filteredRice[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
