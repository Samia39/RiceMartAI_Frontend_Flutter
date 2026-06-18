import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/core/services/chat_service.dart';
import '../../../core/utils/themes.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Arguments passed via Get.toNamed(AppRoutes.chat, arguments: {...})
  int get conversationId => (Get.arguments as Map)["conversation_id"] as int;
  String get otherName =>
      (Get.arguments as Map)["other_name"] as String? ?? "Chat";

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  bool isSending = false;
  Timer? _pollTimer;

  // Current user's id (stored in GetStorage on login)
  int get myUserId => GetStorage().read("user_id") ?? 0;

  @override
  void initState() {
    super.initState();
    fetchMessages();

    // Poll every 5 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchMessages(silent: true);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchMessages({bool silent = false}) async {
    final data = await ChatService().fetchMessages(
      conversationId: conversationId,
    );

    if (mounted) {
      setState(() {
        messages = data;
        if (!silent) isLoading = false;
        isLoading = false;
      });

      // Scroll to bottom when new messages arrive
      if (data.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  Future<void> sendMessage() async {
    final body = _inputController.text.trim();
    if (body.isEmpty || isSending) return;

    setState(() => isSending = true);
    _inputController.clear();

    final sent = await ChatService().sendMessage(
      conversationId: conversationId,
      body: body,
    );

    if (sent != null && mounted) {
      setState(() {
        messages.add(sent);
        isSending = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(otherName),
              Text(
                "Tap to view shop",
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // =====================
            // MESSAGES LIST
            // =====================
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : messages.isEmpty
                  ? const Center(
                      child: Text("Say hello! Start the conversation."),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMine = msg["is_mine"] == true;

                        return _MessageBubble(
                          body: msg["body"] ?? "",
                          isMine: isMine,
                          senderName: msg["sender_name"] ?? "",
                          createdAt: msg["created_at"] ?? "",
                        );
                      },
                    ),
            ),

            // =====================
            // INPUT BAR
            // =====================
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 8,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: AppDecorations.inputField,
                      child: TextField(
                        controller: _inputController,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => sendMessage(),
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: sendMessage,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.darkGreen,
                        shape: BoxShape.circle,
                      ),
                      child: isSending
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send,
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
    );
  }
}

// ============================================================
// MESSAGE BUBBLE WIDGET
// ============================================================
class _MessageBubble extends StatelessWidget {
  final String body;
  final bool isMine;
  final String senderName;
  final String createdAt;

  const _MessageBubble({
    required this.body,
    required this.isMine,
    required this.senderName,
    required this.createdAt,
  });

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? AppColors.darkGreen : AppColors.cream,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  senderName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            Text(
              body,
              style: TextStyle(
                fontSize: 14,
                color: isMine ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(createdAt),
              style: TextStyle(
                fontSize: 10,
                color: isMine ? Colors.white.withOpacity(0.65) : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
