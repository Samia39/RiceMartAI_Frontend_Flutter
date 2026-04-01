import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// ─────────────────────────────────────────────
//  COLOR PALETTE  (splash-matched)
// ─────────────────────────────────────────────
class _C {
  static const darkGreen = Color(0xFF1A2820);
  static const lightGreen = Color(0xFF5A8A6E);
  static const golden = Color(0xFF9D7E3F);
  static const cream = Color(0xFFD4C9A8);
  static const gradTop = Color(0xFF5A8A6E);
  static const gradBottom = Color(0xFF9D7E3F);
}

// ─────────────────────────────────────────────
//  NOTIFICATION SETTINGS SCREEN
// ─────────────────────────────────────────────
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final GetStorage _box = GetStorage();

  late bool _pushEnabled;
  late bool _emailEnabled;
  late bool _orderUpdates;
  late bool _promotions;
  late bool _reminders;
  late bool _appUpdates;
  late bool _soundEnabled;
  late bool _vibrationEnabled;

  @override
  void initState() {
    super.initState();
    _pushEnabled = _box.read('notif_push') ?? true;
    _emailEnabled = _box.read('notif_email') ?? true;
    _orderUpdates = _box.read('notif_order') ?? true;
    _promotions = _box.read('notif_promo') ?? false;
    _reminders = _box.read('notif_reminders') ?? true;
    _appUpdates = _box.read('notif_app_updates') ?? false;
    _soundEnabled = _box.read('notif_sound') ?? true;
    _vibrationEnabled = _box.read('notif_vibration') ?? true;
  }

  void _save(String key, bool value) => _box.write(key, value);

  // ── card ──────────────────────────────────
  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
    decoration: BoxDecoration(
      color: _C.darkGreen.withOpacity(0.22),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _C.darkGreen.withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
          color: _C.darkGreen.withOpacity(0.12),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );

  // ── toggle row ────────────────────────────
  Widget _toggleRow({
    required IconData icon,
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
    bool enabled = true,
  }) {
    final labelColor = enabled ? _C.darkGreen : _C.darkGreen.withOpacity(0.38);
    final subColor = enabled
        ? _C.darkGreen.withOpacity(0.6)
        : _C.darkGreen.withOpacity(0.28);
    final iconBg = enabled
        ? _C.darkGreen.withOpacity(0.18)
        : _C.darkGreen.withOpacity(0.1);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: labelColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: labelColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 11.5, color: subColor),
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: enabled ? onChanged : null,
                activeColor: _C.cream,
                activeTrackColor: _C.darkGreen.withOpacity(0.65),
                inactiveThumbColor: _C.darkGreen.withOpacity(0.4),
                inactiveTrackColor: _C.darkGreen.withOpacity(0.15),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: _C.darkGreen.withOpacity(0.15),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_C.gradTop, _C.gradBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── AppBar ──────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: _C.darkGreen,
                      ),
                      onPressed: () => Get.back(),
                    ),
                    const Expanded(
                      child: Text(
                        'Notification Settings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _C.darkGreen,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              // ── Content ─────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // General
                      _sectionLabel('General'),
                      _card(
                        child: Column(
                          children: [
                            _toggleRow(
                              icon: Icons.notifications_outlined,
                              label: 'Push Notifications',
                              subtitle: 'Receive alerts on your device',
                              value: _pushEnabled,
                              onChanged: (v) {
                                setState(() => _pushEnabled = v);
                                _save('notif_push', v);
                              },
                            ),
                            _toggleRow(
                              icon: Icons.mail_outline,
                              label: 'Email Notifications',
                              subtitle: 'Get updates via email',
                              value: _emailEnabled,
                              onChanged: (v) {
                                setState(() => _emailEnabled = v);
                                _save('notif_email', v);
                              },
                              showDivider: false,
                            ),
                          ],
                        ),
                      ),

                      // Activity
                      _sectionLabel('Activity'),
                      _card(
                        child: Column(
                          children: [
                            _toggleRow(
                              icon: Icons.receipt_long_outlined,
                              label: 'Order Updates',
                              subtitle: 'Status changes & confirmations',
                              value: _orderUpdates,
                              enabled: _pushEnabled,
                              onChanged: (v) {
                                setState(() => _orderUpdates = v);
                                _save('notif_order', v);
                              },
                            ),
                            _toggleRow(
                              icon: Icons.local_offer_outlined,
                              label: 'Promotions & Offers',
                              subtitle: 'Deals, discounts & campaigns',
                              value: _promotions,
                              enabled: _pushEnabled,
                              onChanged: (v) {
                                setState(() => _promotions = v);
                                _save('notif_promo', v);
                              },
                            ),
                            _toggleRow(
                              icon: Icons.alarm_outlined,
                              label: 'Reminders',
                              subtitle: 'Scheduled & task reminders',
                              value: _reminders,
                              enabled: _pushEnabled,
                              onChanged: (v) {
                                setState(() => _reminders = v);
                                _save('notif_reminders', v);
                              },
                            ),
                            _toggleRow(
                              icon: Icons.system_update_outlined,
                              label: 'App Updates',
                              subtitle: 'New features & release notes',
                              value: _appUpdates,
                              enabled: _pushEnabled,
                              onChanged: (v) {
                                setState(() => _appUpdates = v);
                                _save('notif_app_updates', v);
                              },
                              showDivider: false,
                            ),
                          ],
                        ),
                      ),

                      // Sound & Haptics
                      _sectionLabel('Sound & Haptics'),
                      _card(
                        child: Column(
                          children: [
                            _toggleRow(
                              icon: Icons.volume_up_outlined,
                              label: 'Sound',
                              subtitle: 'Play sound for notifications',
                              value: _soundEnabled,
                              enabled: _pushEnabled,
                              onChanged: (v) {
                                setState(() => _soundEnabled = v);
                                _save('notif_sound', v);
                              },
                            ),
                            _toggleRow(
                              icon: Icons.vibration_outlined,
                              label: 'Vibration',
                              subtitle: 'Vibrate on notification',
                              value: _vibrationEnabled,
                              enabled: _pushEnabled,
                              onChanged: (v) {
                                setState(() => _vibrationEnabled = v);
                                _save('notif_vibration', v);
                              },
                              showDivider: false,
                            ),
                          ],
                        ),
                      ),

                      // Hint when push is off
                      if (!_pushEnabled)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: _C.darkGreen.withOpacity(0.65),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Enable Push Notifications to configure activity & sound settings.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: _C.darkGreen.withOpacity(0.65),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: _C.darkGreen.withOpacity(0.8),
        letterSpacing: 0.3,
      ),
    ),
  );
}
