import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessage {
  final String senderId;
  final String senderName;
  final String message;
  final Timestamp time;

  GroupMessage({required this.senderId, required this.senderName, required this.message, required this.time});

  Map<String, dynamic> toJson() {
    return {'senderId': senderId, 'senderName': senderName, 'message': message, 'time': time};
  }

  factory GroupMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return GroupMessage(
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Unknown User',
      message: data['message'] ?? '',
      time: data['time'] ?? Timestamp.now(),
    );
  }
}
