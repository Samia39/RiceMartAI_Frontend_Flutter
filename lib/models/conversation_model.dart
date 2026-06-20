class ConversationModel {
  final int id;
  final int buyerId;
  final int sellerId;
  final int shopId;
  final String? shopName;
  final String? buyerName;
  final String? sellerName;
  final String? lastMessage;
  final String? lastMessageAt;

  ConversationModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.shopId,
    this.shopName,
    this.buyerName,
    this.sellerName,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      buyerId: json['buyer_id'],
      sellerId: json['seller_id'],
      shopId: json['shop_id'],
      shopName: json['shop'] != null ? json['shop']['name'] : null,
      buyerName: json['buyer'] != null ? json['buyer']['name'] : null,
      sellerName: json['seller'] != null ? json['seller']['name'] : null,
      lastMessage: json['last_message'] != null
          ? json['last_message']['message']
          : null,
      lastMessageAt: json['last_message_at'],
    );
  }
}