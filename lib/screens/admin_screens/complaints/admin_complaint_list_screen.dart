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

class AdminComplaintListScreen extends StatefulWidget {
  const AdminComplaintListScreen({super.key});

  @override
  State<AdminComplaintListScreen> createState() =>
      _AdminComplaintListScreenState();
}

class _AdminComplaintListScreenState extends State<AdminComplaintListScreen> {
  final ComplaintService _service = ComplaintService();
  List<Complaint> _all = [];
  bool _loading = true;
  String _filter = 'all'; // all | open | in_progress | resolved

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final complaints = await _service.getAllComplaints();
    setState(() {
      _all = complaints;
      _loading = false;
    });
  }

  List<Complaint> get _filtered =>
      _filter == 'all' ? _all : _all.where((c) => c.status == _filter).toList();

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

  // Role badge colors — seller vs customer, so admin can tell at a glance
  Color _roleColor(String role) =>
      role == 'seller' ? AppColors.golden : AppColors.lightGreen;

  Widget _filterChip(String value, String label, int count) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text('$label${count > 0 ? ' ($count)' : ''}'),
        selected: selected,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: AppColors.golden.withOpacity(0.32),
        backgroundColor: AppColors.cream.withOpacity(0.25),
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.darkGreen,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: StadiumBorder(
          side: BorderSide(color: AppColors.borderGold.withOpacity(0.5)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final openCount = _all.where((c) => c.status == 'open').length;
    final progressCount = _all.where((c) => c.status == 'in_progress').length;
    final resolvedCount = _all.where((c) => c.status == 'resolved').length;

    return Scaffold(
      appBar: AppBar(title: const Text('All Complaints')),
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterChip('all', 'All', _all.length),
                            _filterChip('open', 'Open', openCount),
                            _filterChip(
                              'in_progress',
                              'In Progress',
                              progressCount,
                            ),
                            _filterChip('resolved', 'Resolved', resolvedCount),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: _filtered.isEmpty
                          ? ListView(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 90),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: AppColors.cream.withOpacity(
                                              0.35,
                                            ),
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
                                          'No complaints here',
                                          style: AppTextStyles.heading4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView(
                              padding: const EdgeInsets.only(
                                bottom: 24,
                                top: 4,
                              ),
                              children: _filtered.map((c) {
                                return Container(
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
                                      onTap: () async {
                                        // Converted from Navigator.push(MaterialPageRoute(...))
                                        // to the named route so
                                        // AuthMiddleware/PermissionMiddleware
                                        // ('view complaints') run for it.
                                        await Get.toNamed(
                                          AppRoutes.adminComplaintDetail,
                                          arguments: c.id,
                                        );
                                        _load();
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
                                                color: AppColors.golden
                                                    .withOpacity(0.16),
                                                borderRadius:
                                                    BorderRadius.circular(12),
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      // ── Role badge ──
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 2,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: _roleColor(
                                                            c.role,
                                                          ).withOpacity(0.18),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                          border: Border.all(
                                                            color: _roleColor(
                                                              c.role,
                                                            ).withOpacity(0.5),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          c.role == 'seller'
                                                              ? 'Seller'
                                                              : 'Customer',
                                                          style: AppTextStyles
                                                              .bodySmall
                                                              .copyWith(
                                                                color: AppColors
                                                                    .darkGreen,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 10.5,
                                                              ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          c.userName ??
                                                              'Unknown user',
                                                          style: AppTextStyles
                                                              .bodySmall,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _statusColor(
                                                  c.status,
                                                ).withOpacity(0.14),
                                                borderRadius:
                                                    BorderRadius.circular(20),
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
                                                    size: 12,
                                                    color: _statusColor(
                                                      c.status,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    _statusLabel(c.status),
                                                    style: AppTextStyles
                                                        .bodySmall
                                                        .copyWith(
                                                          color: _statusColor(
                                                            c.status,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 10.5,
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
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
