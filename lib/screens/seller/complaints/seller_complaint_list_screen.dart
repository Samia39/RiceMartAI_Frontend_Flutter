import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/complaint_service.dart';
import '../../../core/utils/themes.dart';
import '../../../routes/app_routes.dart';

IconData _categoryIcon(String category) {
  switch (category) {
    case 'payment':
      return Icons.payments_outlined;
    case 'order':
      return Icons.shopping_bag_outlined;
    case 'account':
      return Icons.person_outline;
    default:
      return Icons.help_outline;
  }
}

String _categoryLabel(String category) {
  switch (category) {
    case 'payment':
      return 'Payment Issue';
    case 'order':
      return 'Order Issue';
    case 'account':
      return 'Account Issue';
    default:
      return 'Other';
  }
}

class SellerComplaintListScreen extends StatefulWidget {
  const SellerComplaintListScreen({super.key});

  @override
  State<SellerComplaintListScreen> createState() =>
      _SellerComplaintListScreenState();
}

class _SellerComplaintListScreenState extends State<SellerComplaintListScreen> {
  final ComplaintService _service = ComplaintService();
  List<Complaint> _complaints = [];
  String _emergencyEmail = '';
  String _emergencyPhone = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final complaints = await _service.getMyComplaints();
    final contact = await _service.getEmergencyContact();
    setState(() {
      _complaints = complaints;
      _emergencyEmail = contact['email'] ?? '';
      _emergencyPhone = contact['phone'] ?? '';
      _loading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
        return AppColors.success;
      case 'in_progress':
        return AppColors.info;
      default:
        return AppColors.warning;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'resolved':
        return Icons.check_circle_outline;
      case 'in_progress':
        return Icons.autorenew;
      default:
        return Icons.schedule;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'resolved':
        return 'Resolved';
      case 'in_progress':
        return 'In Progress';
      default:
        return 'Open';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 90),
                  children: [
                    if (_emergencyEmail.isNotEmpty ||
                        _emergencyPhone.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.warning.withOpacity(0.16),
                              AppColors.warning.withOpacity(0.06),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.warning.withOpacity(0.45),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.support_agent,
                                color: AppColors.warning,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Need urgent help?',
                                    style: AppTextStyles.heading4,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Contact Super Admin directly for serious issues.',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  if (_emergencyPhone.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          size: 14,
                                          color: AppColors.darkGreen
                                              .withOpacity(0.7),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _emergencyPhone,
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  if (_emergencyEmail.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.email_outlined,
                                            size: 14,
                                            color: AppColors.darkGreen
                                                .withOpacity(0.7),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _emergencyEmail,
                                            style: AppTextStyles.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_complaints.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 90),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.cream.withOpacity(0.35),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.inbox_outlined,
                                  size: 42,
                                  color: AppColors.iconMuted,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'No complaints yet',
                                style: AppTextStyles.heading4,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap “New Complaint” to get started',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ..._complaints.map(
                      (c) => Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: AppDecorations.card,
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            // Converted from Navigator.push(MaterialPageRoute(...))
                            // to a named route so AuthMiddleware runs for it.
                            onTap: () async {
                              await Get.toNamed(
                                AppRoutes.sellerComplaintDetail,
                                arguments: c.id,
                              );
                              _loadData();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.golden.withOpacity(0.16),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _categoryIcon(c.category),
                                      color: AppColors.darkGreen,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.subject,
                                          style: AppTextStyles.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _categoryLabel(c.category),
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(
                                        c.status,
                                      ).withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _statusColor(
                                          c.status,
                                        ).withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _statusIcon(c.status),
                                          size: 13,
                                          color: _statusColor(c.status),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _statusLabel(c.status),
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: _statusColor(c.status),
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Converted from Navigator.push(MaterialPageRoute(...)) to a
        // named route so AuthMiddleware/PermissionMiddleware run for it.
        onPressed: () async {
          await Get.toNamed(AppRoutes.sellerNewComplaint);
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Complaint'),
      ),
    );
  }
}
