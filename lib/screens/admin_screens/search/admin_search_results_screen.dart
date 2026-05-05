import 'package:flutter/material.dart';
import '../../../core/utils/themes.dart';

class AdminSearchResultsScreen extends StatelessWidget {
  final String query;

  const AdminSearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final results = [
      "Ali Traders (Seller)",
      "Order #1021",
      "Complaint #44",
      "Punjab Rice Shop",
    ];

    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: Text('Results for "$query"')),

        body: ListView.builder(
          padding: const EdgeInsets.all(18),

          itemCount: results.length,

          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 15),

              padding: const EdgeInsets.all(16),

              decoration: AppDecorations.card,

              child: Row(
                children: [
                  const Icon(Icons.search, size: 32),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Text(results[index], style: AppTextStyles.heading4),
                  ),

                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
