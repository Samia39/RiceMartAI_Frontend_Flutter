import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────
//  COLOR PALETTE (same as dashboard)
// ─────────────────────────────────────────────
class _C {
  static const darkGreen = Color(0xFF1A2820);
  static const lightGreen = Color(0xFF5A8A6E);
  static const golden = Color(0xFF9D7E3F);
  static const cream = Color(0xFFD4C9A8);
  static const border = Color(0xFFB8A97A);
}

// ─────────────────────────────────────────────
//  CONTENT MANAGEMENT SCREEN
// ─────────────────────────────────────────────
class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({Key? key}) : super(key: key);

  @override
  State<ContentManagementScreen> createState() =>
      _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Notification form controllers ─────────────────────────────
  final _titleEnCtrl = TextEditingController();
  final _titleUrCtrl = TextEditingController();
  final _messageEnCtrl = TextEditingController();
  final _messageUrCtrl = TextEditingController();
  bool _sendingNotif = false;

  // ── FAQ data ──────────────────────────────────────────────────
  final List<Map<String, dynamic>> _faqs = [
    {
      'q': 'How do I list my rice product?',
      'a':
          'Go to the Create tab, select "List a Product", fill in the details and submit.',
      'expanded': false,
    },
    {
      'q': 'How are rice prices updated?',
      'a':
          'Prices are updated in real-time from our market data API and can also be manually updated by admins via Price Management.',
      'expanded': false,
    },
    {
      'q': 'How do I register my shop?',
      'a':
          'Go to the Create tab, select "Register Shop", enter your shop details and submit for admin review.',
      'expanded': false,
    },
    {
      'q': 'How does AI rice detection work?',
      'a':
          'Upload a clear image of your rice sample. Our AI model analyzes grain shape, color and texture to detect variety and quality grade.',
      'expanded': false,
    },
    {
      'q': 'What languages does the app support?',
      'a':
          'Rice Mart fully supports English and Urdu. Switch languages using the language toggle on the home screen.',
      'expanded': false,
    },
    {
      'q': 'How do I contact support?',
      'a':
          'Email us at support@ricemart.pk or use the Help & Support option in your Profile screen.',
      'expanded': false,
    },
  ];

  // ── Settings toggles ──────────────────────────────────────────
  bool _maintenanceMode = false;
  bool _registrationOpen = true;
  bool _showPriceBanner = true;
  bool _aiDetectionEnabled = true;
  bool _aiRecommEnabled = true;
  bool _urduEnabled = true;
  String _selectedVersion = 'v1.0.0';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleEnCtrl.dispose();
    _titleUrCtrl.dispose();
    _messageEnCtrl.dispose();
    _messageUrCtrl.dispose();
    super.dispose();
  }

  // ── Helper: input field ───────────────────────────────────────
  Widget _inputField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    bool isUrdu = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _C.darkGreen,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: _C.cream.withOpacity(0.28),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.border.withOpacity(0.55)),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            textAlign: isUrdu ? TextAlign.right : TextAlign.left,
            textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: 13.5,
              color: _C.darkGreen,
              fontFamily: isUrdu ? 'Jameel' : null,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintTextDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
              hintStyle: TextStyle(
                fontSize: 13,
                color: _C.darkGreen.withOpacity(0.45),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helper: card wrapper ──────────────────────────────────────
  Widget _card({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) => Container(
    width: double.infinity,
    margin: margin ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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

  // ── Helper: settings toggle row ───────────────────────────────
  Widget _settingToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
    bool showDivider = true,
  }) => Column(
    children: [
      SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor ?? _C.golden,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: _C.darkGreen,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11.5,
            color: _C.darkGreen.withOpacity(0.6),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        dense: true,
      ),
      if (showDivider)
        Divider(
          height: 1,
          color: _C.border.withOpacity(0.25),
          indent: 16,
          endIndent: 16,
        ),
    ],
  );

  // ─────────────────────────────────────────────
  //  TAB 1 — NOTIFICATIONS
  // ─────────────────────────────────────────────
  Widget _notificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _C.darkGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 18,
                    color: _C.darkGreen,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Send Platform-Wide Notification',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _C.darkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title (English)
            _inputField(
              ctrl: _titleEnCtrl,
              label: 'Title (English)',
              hint: 'Enter notification title',
            ),
            const SizedBox(height: 14),

            // Title (Urdu)
            _inputField(
              ctrl: _titleUrCtrl,
              label: 'Title (Urdu)',
              hint: 'اطلاع کا عنوان درج کریں',
              isUrdu: true,
            ),
            const SizedBox(height: 14),

            // Message (English)
            _inputField(
              ctrl: _messageEnCtrl,
              label: 'Message (English)',
              hint: 'Enter notification message',
              maxLines: 3,
            ),
            const SizedBox(height: 14),

            // Message (Urdu)
            _inputField(
              ctrl: _messageUrCtrl,
              label: 'Message (Urdu)',
              hint: 'اطلاع کا پیغام درج کریں',
              isUrdu: true,
              maxLines: 3,
            ),
            const SizedBox(height: 22),

            // Send button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendingNotif
                    ? null
                    : () async {
                        if (_titleEnCtrl.text.trim().isEmpty ||
                            _messageEnCtrl.text.trim().isEmpty) {
                          Get.snackbar(
                            'Missing Fields',
                            'Please fill in at least English title and message.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: _C.cream.withOpacity(0.95),
                            colorText: _C.darkGreen,
                            borderRadius: 10,
                            margin: const EdgeInsets.all(16),
                          );
                          return;
                        }
                        setState(() => _sendingNotif = true);
                        await Future.delayed(const Duration(seconds: 2));
                        setState(() => _sendingNotif = false);
                        _titleEnCtrl.clear();
                        _titleUrCtrl.clear();
                        _messageEnCtrl.clear();
                        _messageUrCtrl.clear();
                        Get.snackbar(
                          'Sent!',
                          'Notification sent to all users successfully.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: _C.cream.withOpacity(0.95),
                          colorText: _C.darkGreen,
                          icon: const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2E7D32),
                          ),
                          borderRadius: 10,
                          margin: const EdgeInsets.all(16),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.darkGreen,
                  disabledBackgroundColor: _C.darkGreen.withOpacity(0.35),
                  foregroundColor: _C.cream,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  elevation: 0,
                ),
                child: _sendingNotif
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _C.cream.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Sending...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_active_outlined, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Send to All Users',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  TAB 2 — FAQs
  // ─────────────────────────────────────────────
  Widget _faqsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      child: Column(
        children: [
          // Add FAQ button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAddFaqDialog(),
                icon: const Icon(Icons.add, size: 18, color: _C.darkGreen),
                label: const Text(
                  'Add New FAQ',
                  style: TextStyle(
                    color: _C.darkGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _C.border.withOpacity(0.6)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // FAQ list
          ..._faqs.asMap().entries.map((e) {
            final i = e.key;
            final faq = e.value;
            return _card(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Question row
                  InkWell(
                    onTap: () => setState(
                      () => _faqs[i]['expanded'] = !_faqs[i]['expanded'],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: _C.darkGreen.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                'Q',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _C.darkGreen,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              faq['q'],
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: _C.darkGreen,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedRotation(
                            turns: faq['expanded'] ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: _C.darkGreen.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Answer
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      children: [
                        Divider(
                          height: 1,
                          color: _C.border.withOpacity(0.3),
                          indent: 16,
                          endIndent: 16,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: _C.golden.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    'A',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _C.golden,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  faq['a'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _C.darkGreen.withOpacity(0.8),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Delete & Edit row
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            children: [
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setState(() => _faqs.removeAt(i)),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.25),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 14,
                                        color: Colors.red.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Delete',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red.shade600,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    crossFadeState: faq['expanded']
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showAddFaqDialog() {
    final qCtrl = TextEditingController();
    final aCtrl = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: const Color(0xFFF0EBD8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add New FAQ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _C.darkGreen,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qCtrl,
                style: const TextStyle(color: _C.darkGreen, fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: 'Question',
                  labelStyle: TextStyle(color: _C.darkGreen.withOpacity(0.7)),
                  filled: true,
                  fillColor: _C.cream.withOpacity(0.35),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _C.border.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _C.border.withOpacity(0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: aCtrl,
                maxLines: 3,
                style: const TextStyle(color: _C.darkGreen, fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: 'Answer',
                  labelStyle: TextStyle(color: _C.darkGreen.withOpacity(0.7)),
                  filled: true,
                  fillColor: _C.cream.withOpacity(0.35),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _C.border.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _C.border.withOpacity(0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _C.border.withOpacity(0.6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: _C.darkGreen),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (qCtrl.text.trim().isEmpty ||
                            aCtrl.text.trim().isEmpty)
                          return;
                        setState(
                          () => _faqs.add({
                            'q': qCtrl.text.trim(),
                            'a': aCtrl.text.trim(),
                            'expanded': false,
                          }),
                        );
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.darkGreen,
                        foregroundColor: _C.cream,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  TAB 3 — SETTINGS
  // ─────────────────────────────────────────────
  Widget _settingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      child: Column(
        children: [
          // ── App Feature Toggles ─────────────────
          _card(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  _sectionHeader('App Features'),
                  _settingToggle(
                    title: 'Maintenance Mode',
                    subtitle: 'Disable app access for all users',
                    value: _maintenanceMode,
                    onChanged: (v) => setState(() => _maintenanceMode = v),
                    activeColor: Colors.red,
                  ),
                  _settingToggle(
                    title: 'User Registration',
                    subtitle: 'Allow new users to register',
                    value: _registrationOpen,
                    onChanged: (v) => setState(() => _registrationOpen = v),
                  ),
                  _settingToggle(
                    title: 'Show Price Banner',
                    subtitle: 'Display real-time price banner on home',
                    value: _showPriceBanner,
                    onChanged: (v) => setState(() => _showPriceBanner = v),
                  ),
                  _settingToggle(
                    title: 'Urdu Language Support',
                    subtitle: 'Enable Urdu language toggle',
                    value: _urduEnabled,
                    onChanged: (v) => setState(() => _urduEnabled = v),
                    showDivider: false,
                  ),
                ],
              ),
            ),
          ),

          // ── AI Features ─────────────────────────
          _card(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  _sectionHeader('AI Features'),
                  _settingToggle(
                    title: 'AI Detection & Suggestion',
                    subtitle: 'Enable rice quality analysis feature',
                    value: _aiDetectionEnabled,
                    onChanged: (v) => setState(() => _aiDetectionEnabled = v),
                  ),
                  _settingToggle(
                    title: 'AI Recommendation',
                    subtitle: 'Enable recipe-based rice recommendation',
                    value: _aiRecommEnabled,
                    onChanged: (v) => setState(() => _aiRecommEnabled = v),
                    showDivider: false,
                  ),
                ],
              ),
            ),
          ),

          // ── App Version ──────────────────────────
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader('App Version', noPadding: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Version',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: _C.darkGreen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Deployed to production',
                            style: TextStyle(
                              fontSize: 12,
                              color: _C.darkGreen.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _C.darkGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _C.border.withOpacity(0.5)),
                      ),
                      child: Text(
                        _selectedVersion,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _C.darkGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Danger Zone ──────────────────────────
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Colors.red.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Danger Zone',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Get.snackbar(
                      'Cache Cleared',
                      'App cache cleared successfully.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: _C.cream.withOpacity(0.95),
                      colorText: _C.darkGreen,
                      borderRadius: 10,
                      margin: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(
                      Icons.cleaning_services_outlined,
                      size: 16,
                    ),
                    label: const Text('Clear App Cache'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      side: BorderSide(color: Colors.orange.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmReset(),
                    icon: const Icon(Icons.restore, size: 16),
                    label: const Text('Reset All Settings'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.withOpacity(0.35)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {bool noPadding = false}) => noPadding
      ? Row(
          children: [
            Icon(
              Icons.settings_outlined,
              size: 15,
              color: _C.darkGreen.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: _C.darkGreen,
              ),
            ),
          ],
        )
      : Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _C.darkGreen.withOpacity(0.08),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _C.darkGreen,
            ),
          ),
        );

  void _confirmReset() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFFF0EBD8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reset Settings?',
          style: TextStyle(color: _C.darkGreen, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will reset all settings to default. Are you sure?',
          style: TextStyle(
            color: _C.darkGreen.withOpacity(0.8),
            fontSize: 13.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: _C.darkGreen)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _maintenanceMode = false;
                _registrationOpen = true;
                _showPriceBanner = true;
                _aiDetectionEnabled = true;
                _aiRecommEnabled = true;
                _urduEnabled = true;
              });
              Get.back();
              Get.snackbar(
                'Reset Done',
                'All settings restored to defaults.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: _C.cream.withOpacity(0.95),
                colorText: _C.darkGreen,
                borderRadius: 10,
                margin: const EdgeInsets.all(16),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_C.lightGreen, _C.golden],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: Row(
                  children: [
                    // Title
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Content Management',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _C.darkGreen,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'App content and settings',
                            style: TextStyle(fontSize: 12, color: _C.darkGreen),
                          ),
                        ],
                      ),
                    ),
                    // Back button
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
                          border: Border.all(
                            color: _C.border.withOpacity(0.45),
                          ),
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
              const SizedBox(height: 16),

              // ── Tab Bar (Notifications | FAQs | Settings) ─
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: _C.cream.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border.withOpacity(0.4)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: _C.cream,
                    unselectedLabelColor: _C.darkGreen.withOpacity(0.65),
                    labelStyle: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                    indicator: BoxDecoration(
                      color: _C.darkGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    padding: const EdgeInsets.all(4),
                    tabs: const [
                      Tab(text: 'Notifications'),
                      Tab(text: 'FAQs'),
                      Tab(text: 'Settings'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // ── Tab Views ───────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_notificationsTab(), _faqsTab(), _settingsTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
