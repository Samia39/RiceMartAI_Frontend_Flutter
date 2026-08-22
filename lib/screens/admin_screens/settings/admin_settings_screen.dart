import 'package:flutter/material.dart';
import '../../../core/utils/themes.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final TextEditingController commissionController = TextEditingController(
    text: "5",
  );

  final TextEditingController riceController = TextEditingController();

  bool shopRegistration = true;

  void saveSettings() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Settings Updated")));
  }

  void addRiceCategory() {
    if (riceController.text.isEmpty) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Added ${riceController.text}")));

    riceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,

      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(title: const Text("Admin Settings")),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text("Commission Settings", style: AppTextStyles.heading3),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card,

                child: Column(
                  children: [
                    TextField(
                      controller: commissionController,

                      decoration: const InputDecoration(
                        labelText: "Commission %",
                      ),
                    ),

                    const SizedBox(height: 15),

                    ElevatedButton(
                      onPressed: saveSettings,
                      child: const Text("Update Commission"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Text("Rice Categories", style: AppTextStyles.heading3),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card,

                child: Column(
                  children: [
                    TextField(
                      controller: riceController,

                      decoration: const InputDecoration(
                        labelText: "New Rice Category",
                      ),
                    ),

                    const SizedBox(height: 15),

                    ElevatedButton(
                      onPressed: addRiceCategory,
                      child: const Text("Add Category"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Text("Shop Controls", style: AppTextStyles.heading3),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card,

                // SwitchListTile paints its background/ink splash on the
                // nearest Material ancestor. Without this Material wrap,
                // the parent Container's own decoration sits on top and
                // hides those effects — that's the
                // "ListTile background color or ink splashes may be
                // invisible" warning. Wrapping it here (transparent, so
                // the card's own background/border still show through)
                // gives SwitchListTile its own Material to paint on.
                child: Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    title: const Text("Enable Shop Registration"),

                    value: shopRegistration,

                    onChanged: (value) {
                      setState(() {
                        shopRegistration = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
