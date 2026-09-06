class AppNotificationModel {
  final int id;
  final String type;
  final String title;
  final String message;
  final int? relatedId;
  final bool isRead;
  final String? createdAt;

  AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.relatedId,
    this.isRead = false,
    this.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'],
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      relatedId: json['related_id'],
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at']?.toString(),
    );
  }
}