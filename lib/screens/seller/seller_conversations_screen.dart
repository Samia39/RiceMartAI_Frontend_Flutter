// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/themes.dart';
import '../../core/services/chat_service.dart';
import '../../models/conversation_model.dart';

class SellerConversationsScreen extends StatefulWidget {
  const SellerConversationsScreen({super.key});
  @override
  State<SellerConversationsScreen> createState() =>
      _SellerConversationsScreenState();
}

class _SellerConversationsScreenState
    extends State<SellerConversationsScreen> {
  List<ConversationModel> conversations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadConversations();
  }

  Future<void> loadConversations() async {
    setState(() => isLoading = true);
    conversations = await ChatService.getConversations();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Text('Buyer Messages',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            )),
        const SizedBox(height: 16),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 60,
                              color: AppColors.darkGreen.withOpacity(0.35)),
                          const SizedBox(height: 12),
                          Text('Abhi tak koi buyer message nahi',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: AppColors.darkGreen.withOpacity(0.55),
                              )),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadConversations,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: conversations.length,
                        itemBuilder: (ctx, i) {
                          final conv = conversations[i];
                          return GestureDetector(
                            onTap: () => Get.toNamed(
                              '/chat-screen',
                              arguments: conv,
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.cream.withOpacity(0.22),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color:
                                        AppColors.borderGold.withOpacity(0.45)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppColors.darkGreen
                                          .withOpacity(0.10),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.person,
                                        color: AppColors.darkGreen, size: 26),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          conv.buyerName ?? 'Buyer',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          conv.shopName ?? '',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 11,
                                            color: AppColors.golden,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          conv.lastMessage ??
                                              'No messages yet',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            color: AppColors.darkGreen
                                                .withOpacity(0.60),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios,
                                      size: 14,
                                      color:
                                          AppColors.darkGreen.withOpacity(0.45)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}