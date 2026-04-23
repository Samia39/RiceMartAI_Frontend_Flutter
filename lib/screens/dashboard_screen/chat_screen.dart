// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/core/utils/themes.dart';

// ─────────────────────────────────────────────
//  CHAT SCREEN
// ─────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <_Msg>[
    _Msg('Hi! How can I help you today?', false),
    _Msg('I want to know about Basmati rice prices.', true),
    _Msg(
      'Basmati is currently Rs 280–320/kg at Anware Sidra Rice Shop.',
      false,
    ),
  ];

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() => _msgs.add(_Msg(t, true)));
    _ctrl.clear();
    _scrollToEnd();
    Future.delayed(const Duration(milliseconds: 900), () {
      setState(
        () => _msgs.add(
          _Msg('Thank you! Our team will get back to you shortly.', false),
        ),
      );
      _scrollToEnd();
    });
  }

  void _scrollToEnd() => Future.delayed(const Duration(milliseconds: 80), () {
    if (_scroll.hasClients)
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: AppDecorations.gradientBackground,
      child: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: AppColors.darkGreen,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rice Mart Support',
                        style: AppTextStyles.heading4,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Online',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              height: 16,
              color: AppColors.divider,
              indent: 18,
              endIndent: 18,
            ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                itemCount: _msgs.length,
                itemBuilder: (_, i) {
                  final m = _msgs[i];
                  return Align(
                    alignment: m.isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.72,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: m.isMe
                            ? AppColors.darkGreen
                            : AppColors.cardFill,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: m.isMe
                              ? const Radius.circular(16)
                              : Radius.zero,
                          bottomRight: m.isMe
                              ? Radius.zero
                              : const Radius.circular(16),
                        ),
                        border: m.isMe
                            ? null
                            : Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        m.text,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: m.isMe ? AppColors.cream : AppColors.darkGreen,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardFill,
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: AppDecorations.inputField,
                      child: TextField(
                        controller: _ctrl,
                        style: AppTextStyles.bodyLarge,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: AppTextStyles.hint,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppGradients.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }
}

class _Msg {
  final String text;
  final bool isMe;
  _Msg(this.text, this.isMe);
}

// ─────────────────────────────────────────────
//  NOTIFICATION SETTINGS SCREEN
// ─────────────────────────────────────────────
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);
  @override
  State<NotificationSettingsScreen> createState() => _NSState();
}

class _NSState extends State<NotificationSettingsScreen> {
  bool _push = true,
      _email = true,
      _orders = true,
      _promos = false,
      _reminders = true,
      _updates = false,
      _sound = true,
      _vibrate = true;

  Widget _tile({
    required IconData icon,
    required String label,
    String? sub,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool last = false,
    bool enabled = true,
  }) {
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
                  color: AppColors.darkGreen.withOpacity(enabled ? 0.12 : 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: AppColors.darkGreen.withOpacity(enabled ? 1 : 0.35),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkGreen.withOpacity(
                          enabled ? 1 : 0.38,
                        ),
                      ),
                    ),
                    if (sub != null)
                      Text(
                        sub,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11.5),
                      ),
                  ],
                ),
              ),
              Switch(value: value, onChanged: enabled ? onChanged : null),
            ],
          ),
        ),
        if (!last)
          Divider(
            height: 1,
            color: AppColors.divider,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _card(Widget child) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
    decoration: AppDecorations.card,
    child: child,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: AppDecorations.gradientBackground,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: AppColors.darkGreen,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  const Expanded(
                    child: Text(
                      'Notification Settings',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading3,
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                      child: Text('General', style: AppTextStyles.sectionTitle),
                    ),
                    _card(
                      Column(
                        children: [
                          _tile(
                            icon: Icons.notifications_outlined,
                            label: 'Push Notifications',
                            sub: 'Receive alerts on device',
                            value: _push,
                            onChanged: (v) => setState(() => _push = v),
                          ),
                          _tile(
                            icon: Icons.mail_outline,
                            label: 'Email Notifications',
                            sub: 'Get updates via email',
                            value: _email,
                            onChanged: (v) => setState(() => _email = v),
                            last: true,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                      child: Text(
                        'Activity',
                        style: AppTextStyles.sectionTitle,
                      ),
                    ),
                    _card(
                      Column(
                        children: [
                          _tile(
                            icon: Icons.receipt_long_outlined,
                            label: 'Order Updates',
                            sub: 'Status & confirmations',
                            value: _orders,
                            enabled: _push,
                            onChanged: (v) => setState(() => _orders = v),
                          ),
                          _tile(
                            icon: Icons.local_offer_outlined,
                            label: 'Promotions',
                            sub: 'Deals & discounts',
                            value: _promos,
                            enabled: _push,
                            onChanged: (v) => setState(() => _promos = v),
                          ),
                          _tile(
                            icon: Icons.alarm_outlined,
                            label: 'Reminders',
                            value: _reminders,
                            enabled: _push,
                            onChanged: (v) => setState(() => _reminders = v),
                          ),
                          _tile(
                            icon: Icons.system_update_outlined,
                            label: 'App Updates',
                            value: _updates,
                            enabled: _push,
                            onChanged: (v) => setState(() => _updates = v),
                            last: true,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                      child: Text(
                        'Sound & Haptics',
                        style: AppTextStyles.sectionTitle,
                      ),
                    ),
                    _card(
                      Column(
                        children: [
                          _tile(
                            icon: Icons.volume_up_outlined,
                            label: 'Sound',
                            value: _sound,
                            enabled: _push,
                            onChanged: (v) => setState(() => _sound = v),
                          ),
                          _tile(
                            icon: Icons.vibration_outlined,
                            label: 'Vibration',
                            value: _vibrate,
                            enabled: _push,
                            onChanged: (v) => setState(() => _vibrate = v),
                            last: true,
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
