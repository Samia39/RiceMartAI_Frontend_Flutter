import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../admin screen/content_management.dart';

// ─────────────────────────────────────────────
//  COLOR PALETTE
// ─────────────────────────────────────────────
class _C {
  static const darkGreen = Color(0xFF1A2820);
  static const lightGreen = Color(0xFF5A8A6E);
  static const golden = Color(0xFF9D7E3F);
  static const cream = Color(0xFFD4C9A8);
  static const border = Color(0xFFB8A97A);
}

// ─────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────
class _Stat {
  final String label, value, change;
  final IconData icon;
  final Color iconBg;
  const _Stat({
    required this.label,
    required this.value,
    required this.change,
    required this.icon,
    required this.iconBg,
  });
}

class _Activity {
  final String title, timeAgo;
  const _Activity({required this.title, required this.timeAgo});
}

// ─────────────────────────────────────────────
//  ADMIN SCREEN
// ─────────────────────────────────────────────
class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _loadingStats = true;

  final List<_Stat> _stats = const [
    _Stat(
      label: 'Total Users',
      value: '12,580',
      change: '+12.5%',
      icon: Icons.group_outlined,
      iconBg: Color(0xFF1565C0),
    ),
    _Stat(
      label: 'Active Sellers',
      value: '456',
      change: '+8.3%',
      icon: Icons.storefront_outlined,
      iconBg: Color(0xFF6A1B9A),
    ),
    _Stat(
      label: 'Total Shops',
      value: '389',
      change: '+9.2%',
      icon: Icons.store_outlined,
      iconBg: Color(0xFFBF360C),
    ),
    _Stat(
      label: 'Products Listed',
      value: '2,140',
      change: '+5.7%',
      icon: Icons.inventory_2_outlined,
      iconBg: Color(0xFF2E7D32),
    ),
  ];

  final List<_Activity> _activities = const [
    _Activity(title: 'New user registered: Ahmad Khan', timeAgo: '5 min ago'),
    _Activity(
      title: 'New product listed: Premium Kainat Rice',
      timeAgo: '25 min ago',
    ),
    _Activity(title: 'New shop created: Basmati Mart', timeAgo: '1 hour ago'),
    _Activity(
      title: 'Market price updated: Basmati Rice',
      timeAgo: '2 hours ago',
    ),
    _Activity(title: 'User verified: Tariq Hussain', timeAgo: '3 hours ago'),
    _Activity(title: 'Shop suspended: XYZ Store', timeAgo: '5 hours ago'),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(milliseconds: 800),
      () => setState(() => _loadingStats = false),
    );
  }

  // ── Card wrapper ──────────────────────────────────────────────
  Widget _card({required Widget child, EdgeInsets? padding}) => Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _C.cream.withOpacity(0.22),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _C.border.withOpacity(0.45)),
      boxShadow: [
        BoxShadow(
          color: _C.darkGreen.withOpacity(0.07),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );

  // ── Section title ─────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
    child: Row(
      children: [
        Icon(icon, size: 17, color: _C.darkGreen),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _C.darkGreen,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );

  // ── Stat card ─────────────────────────────────────────────────
  Widget _statCard(_Stat s) => _card(
    child: Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: s.iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(s.icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _C.darkGreen,
                ),
              ),
              Text(
                s.label,
                style: TextStyle(
                  fontSize: 12.5,
                  color: _C.darkGreen.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
          ),
          child: Text(
            s.change,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
      ],
    ),
  );

  // ── Activity tile ─────────────────────────────────────────────
  Widget _activityTile(_Activity a, bool isLast) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : Border(
              bottom: BorderSide(color: _C.border.withOpacity(0.25), width: 1),
            ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 5),
          decoration: const BoxDecoration(
            color: _C.golden,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                a.title,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: _C.darkGreen,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                a.timeAgo,
                style: TextStyle(
                  fontSize: 11.5,
                  color: _C.darkGreen.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _C.darkGreen,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          'Platform monitoring and management',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _C.darkGreen.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _C.cream.withOpacity(0.30),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _C.border.withOpacity(0.45)),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.darkGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Stats ────────────────────────────────
            _sectionTitle('Overview', Icons.bar_chart_outlined),
            if (_loadingStats)
              _card(
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: _C.golden,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              )
            else
              ..._stats.map((s) => _statCard(s)),

            const SizedBox(height: 4),

            // ── Recent Activities ────────────────────
            _sectionTitle('Recent Activities', Icons.timeline_outlined),
            _card(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: _activities
                      .asMap()
                      .entries
                      .map(
                        (e) => _activityTile(
                          e.value,
                          e.key == _activities.length - 1,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // ── Management — ONLY Content Management ─
            _sectionTitle('Management', Icons.settings_outlined),
            _card(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => Get.to(
                    () => const ContentManagementScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 300),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    child: Row(
                      children: [
                        // Icon badge
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.remove_red_eye_outlined,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Text
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Content Management',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _C.darkGreen,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'App content and settings',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0x801A2820),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Arrow
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 13,
                          color: _C.darkGreen.withOpacity(0.45),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
