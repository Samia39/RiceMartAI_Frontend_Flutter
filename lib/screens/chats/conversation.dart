import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/services/chat_service.dart';
import 'package:get/get.dart';
import '../../../core/utils/themes.dart';
import '../../../routes/app_routes.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  List<Map<String, dynamic>> conversations = [];
  bool isLoading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    fetchConversations();

    // Poll every 5 seconds for new conversations / unread counts
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchConversations(silent: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchConversations({bool silent = false}) async {
    final data = await ChatService().fetchConversations();

    if (mounted) {
      setState(() {
        conversations = data;
        if (!silent) isLoading = false;
        isLoading = false;
      });
    }
  }

  String _formatTime(dynamic isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString.toString()).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        return '$h:$m';
      }
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Messages")),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : conversations.isEmpty
            ? const Center(child: Text("No conversations yet"))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  final unread = (conv["unread_count"] as int? ?? 0);

                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.chat,
                        arguments: {
                          "conversation_id": conv["id"],
                          "other_name": conv["other_name"],
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: AppDecorations.card,
                      child: Row(
                        children: [
                          // Avatar circle
                          CircleAvatar(
                            backgroundColor: AppColors.darkGreen.withOpacity(
                              0.15,
                            ),
                            child: Text(
                              (conv["other_name"] as String)
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(
                                color: AppColors.darkGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Name + last message
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  conv["other_name"] ?? "",
                                  style: AppTextStyles.heading4,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  conv["last_message"] ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Time + unread badge
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatTime(conv["last_at"]),
                                style: AppTextStyles.bodyMedium,
                              ),
                              if (unread > 0) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkGreen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$unread',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
