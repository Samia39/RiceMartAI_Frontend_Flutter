// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/utils/themes.dart';
import '../../core/services/chat_service.dart';
import '../../models/conversation_model.dart';
import '../../models/message_model.dart';
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ConversationModel conversation;
  List<MessageModel> messages = [];
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = true;
  bool isSending = false;
  Timer? _pollingTimer;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    conversation = Get.arguments as ConversationModel;
    _getCurrentUser();
    loadMessages();
    // Polling every 5 seconds
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => loadMessages(silent: true),
    );
  }

  void _getCurrentUser() {
    final box = GetStorage();
    final userStr = box.read('user');
    if (userStr != null) {
      final user = jsonDecode(userStr);
      currentUserId = user['id'];
    }
  }

  Future<void> loadMessages({bool silent = false}) async {
    if (!silent) setState(() => isLoading = true);
    final newMessages =
        await ChatService.getMessages(conversation.id);
    setState(() {
      messages = newMessages;
      isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() => isSending = true);
    _msgController.clear();

    await ChatService.sendMessage(conversation.id, text);
    await loadMessages(silent: true);
    setState(() => isSending = false);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: AppDecorations.iconButton,
                        child: Icon(Icons.arrow_back,
                            color: AppColors.darkGreen, size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.darkGreen.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.store,
                          color: AppColors.darkGreen, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation.shopName ?? 'Shop',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGreen,
                            ),
                          ),
                          Text(
                            conversation.sellerName ?? 'Seller',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: AppColors.darkGreen.withOpacity(0.60),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Messages ─────────────────────────────────
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : messages.isEmpty
                        ? Center(
                            child: Text('Koi message nahi — pehla message bhejo!',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: AppColors.darkGreen.withOpacity(0.55),
                                )),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: messages.length,
                            itemBuilder: (ctx, i) {
                              final msg = messages[i];
                              final isMe = msg.senderId == currentUserId;
                              return _messageBubble(msg, isMe);
                            },
                          ),
              ),

              // ── Input Box ────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.cream.withOpacity(0.30),
                  border: Border(
                    top: BorderSide(
                        color: AppColors.borderGold.withOpacity(0.40)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: AppDecorations.inputField,
                        child: TextField(
                          controller: _msgController,
                          style: AppTextStyles.bodyLarge,
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: AppTextStyles.hint,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: isSending ? null : sendMessage,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.darkGreen,
                          shape: BoxShape.circle,
                        ),
                        child: isSending
                            ? const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2)
                            : const Icon(Icons.send,
                                color: Colors.white, size: 20),
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
  }

  Widget _messageBubble(MessageModel msg, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.darkGreen.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.store,
                  color: AppColors.darkGreen, size: 18),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.darkGreen
                    : AppColors.cream.withOpacity(0.60),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Text(
                msg.message,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: isMe ? Colors.white : AppColors.darkGreen,
                ),
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}