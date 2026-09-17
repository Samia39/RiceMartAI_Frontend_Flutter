import 'package:flutter/material.dart';
import '../../../core/utils/themes.dart';
import '../../../core/services/admin/commission_service.dart';
import '../../../core/services/admin/permission_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final commissionController = TextEditingController();
  final CommissionService _commissionService = CommissionService();

  // Commission section state
  final bool _canManageCommission = PermissionService.hasPermission(
    'manage commission',
  );
  bool _loadingCommission = true;
  bool _updatingCommission = false;
  double? _currentCommission;
  List _history = [];
  String? _commissionError;

  @override
  void initState() {
    super.initState();
    if (_canManageCommission) {
      _loadCommissionData();
    } else {
      _loadingCommission = false;
    }
  }

  Future<void> _loadCommissionData() async {
    setState(() => _loadingCommission = true);

    final current = await _commissionService.getCurrentCommission();
    final history = await _commissionService.getCommissionHistory();

    if (!mounted) return;
    setState(() {
      _currentCommission = current;
      commissionController.text = current?.toString() ?? "";
      _history = history;
      _loadingCommission = false;
    });
  }

  Future<void> _confirmAndUpdateCommission() async {
    final input = double.tryParse(commissionController.text.trim());

    if (input == null || input < 0 || input > 100) {
      setState(
        () => _commissionError = "Enter a valid percentage between 0 and 100",
      );
      return;
    }

    setState(() => _commissionError = null);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: const Text("Confirm Commission Change"),
        content: Text(
          "Change platform commission from "
          "${_currentCommission?.toStringAsFixed(2) ?? '-'}% to "
          "${input.toStringAsFixed(2)}%?\n\n"
          "This will apply to all orders paid from now on. "
          "Orders already processed keep their old commission.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _updatingCommission = true);

    final result = await _commissionService.updateCommission(input);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result["success"] == true
              ? "Commission updated successfully"
              : (result["message"] ?? "Failed to update commission"),
        ),
      ),
    );

    setState(() => _updatingCommission = false);

    if (result["success"] == true) {
      await _loadCommissionData();
    }
  }

  Widget _buildCommissionSection() {
    if (!_canManageCommission) {
      return const SizedBox.shrink(); // regular admin never sees this section
    }

    if (_loadingCommission) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Commission Settings", style: AppTextStyles.heading3),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Current commission: ${_currentCommission?.toStringAsFixed(2) ?? '-'}%",
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commissionController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "New commission %",
                ),
              ),
              if (_commissionError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _commissionError!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _updatingCommission
                    ? null
                    : _confirmAndUpdateCommission,
                child: _updatingCommission
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Update Commission"),
              ),
            ],
          ),
        ),
        if (_history.isNotEmpty) ...[
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Recent changes", style: AppTextStyles.heading4),
                const SizedBox(height: 10),
                ..._history.take(5).map((h) {
                  final adminName = h["admin"]?["name"] ?? "System";
                  final pct = h["percentage"]?.toString() ?? "-";
                  final date =
                      h["created_at"]?.toString().split("T").first ?? "";
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      "$pct% — by $adminName on $date",
                      style: AppTextStyles.bodySmall,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
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
            children: [_buildCommissionSection()],
          ),
        ),
      ),
    );
  }
}
