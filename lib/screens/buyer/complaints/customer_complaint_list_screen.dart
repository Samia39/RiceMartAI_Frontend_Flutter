import 'package:flutter/material.dart';
import '../../../core/services/complaint_service.dart';
import '../../../core/utils/themes.dart';
import 'customer_new_complaint_screen.dart';
import 'customer_complaint_detail_screen.dart';

class CustomerComplaintListScreen extends StatefulWidget {
  const CustomerComplaintListScreen({super.key});

  @override
  State<CustomerComplaintListScreen> createState() =>
      _CustomerComplaintListScreenState();
}

class _CustomerComplaintListScreenState
    extends State<CustomerComplaintListScreen> {
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
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        padding: const EdgeInsets.all(14),
                        decoration: AppDecorations.card.copyWith(
                          border: Border.all(
                            color: AppColors.warning.withOpacity(0.55),
                          ),
                          color: AppColors.warning.withOpacity(0.10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.support_agent,
                              color: AppColors.warning,
                              size: 26,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'For urgent issues, contact Super Admin directly',
                                    style: AppTextStyles.heading4,
                                  ),
                                  const SizedBox(height: 6),
                                  if (_emergencyPhone.isNotEmpty)
                                    Text(
                                      'Phone: $_emergencyPhone',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  if (_emergencyEmail.isNotEmpty)
                                    Text(
                                      'Email: $_emergencyEmail',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_complaints.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Center(
                          child: Text(
                            'No complaints yet',
                            style: AppTextStyles.bodyMedium,
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
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            c.subject,
                            style: AppTextStyles.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              c.category[0].toUpperCase() +
                                  c.category.substring(1),
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(c.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _statusColor(c.status).withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              _statusLabel(c.status),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: _statusColor(c.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomerComplaintDetailScreen(
                                  complaintId: c.id,
                                ),
                              ),
                            );
                            _loadData();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CustomerNewComplaintScreen(),
            ),
          );
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Complaint'),
      ),
    );
  }
}
