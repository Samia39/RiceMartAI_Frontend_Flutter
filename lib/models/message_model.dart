class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String message;
  final bool isRead;
  final String createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      senderName: json['sender'] != null ? json['sender']['name'] : 'Unknown',
      message: json['message'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] ?? '',
    );
  }
}