import 'package:flutter/material.dart';
import '../../../core/utils/themes.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Map<String, dynamic>> reports = [
    {
      "id": "1001",
      "user": "Hamza",
      "issue": "Wrong rice delivered",
      "status": "Open",
    },

    {
      "id": "1002",
      "user": "Ali",
      "issue": "Shop fraud complaint",
      "status": "Open",
    },
  ];

  void resolveReport(int index) {
    setState(() {
      reports[index]["status"] = "Resolved";
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Report resolved")));
  }

  void dismissReport(int index) {
    setState(() {
      reports.removeAt(index);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Report dismissed")));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Feedback & Reports")),

        body: ListView.builder(
          padding: const EdgeInsets.all(18),

          itemCount: reports.length,

          itemBuilder: (context, index) {
            var report = reports[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 18),

              padding: const EdgeInsets.all(16),

              decoration: AppDecorations.card,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Complaint #${report["id"]}",
                    style: AppTextStyles.heading4,
                  ),

                  const SizedBox(height: 10),

                  Text("User: ${report["user"]}"),

                  Text("Issue: ${report["issue"]}"),

                  const SizedBox(height: 10),

                  Text("Status: ${report["status"]}"),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            resolveReport(index);
                          },
                          child: const Text("Resolve"),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            dismissReport(index);
                          },
                          child: const Text("Dismiss"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
