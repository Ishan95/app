class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String receiverID;
  final String senderID;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.receiverID,
    required this.senderID,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      receiverID: data['receiverId'] ?? '',
      senderID: data['senderId'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as dynamic).toDate(),
    );
  }
}