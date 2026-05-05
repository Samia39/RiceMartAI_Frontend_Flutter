import 'package:flutter/material.dart';
import '../../../core/utils/themes.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> users = [
    {"name": "Sam", "role": "Customer", "status": "Active"},

    {"name": "Ali Traders", "role": "Seller", "status": "Active"},

    {"name": "Ahmed", "role": "Customer", "status": "Suspended"},
  ];

  void suspendUser(int index) {
    setState(() {
      users[index]["status"] = "Suspended";
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("User Suspended")));
  }

  void deleteUser(int index) {
    setState(() {
      users.removeAt(index);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("User Deleted")));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("User Management")),

        body: ListView.builder(
          padding: const EdgeInsets.all(18),

          itemCount: users.length,

          itemBuilder: (context, index) {
            var user = users[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 18),

              padding: const EdgeInsets.all(16),

              decoration: AppDecorations.card,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(user["name"], style: AppTextStyles.heading4),

                  const SizedBox(height: 8),

                  Text("Role: ${user["role"]}"),

                  Text("Status: ${user["status"]}"),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            suspendUser(index);
                          },
                          child: const Text("Suspend"),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            deleteUser(index);
                          },
                          child: const Text("Delete"),
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
