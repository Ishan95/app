import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String name;
  final String message;
  final String chatPartnerId;
  final Timestamp time;
  final bool isMute;
  final String chatRoomId;

  final bool isGroup;
  final List<dynamic>? cycleData;
  final String? matchTypeStr;
  final int? matchedChoice;
  final int unreadCount;

  ChatModel({
    required this.name,
    required this.message,
    required this.chatPartnerId,
    required this.time,
    required this.isMute,
    required this.chatRoomId,
    this.isGroup = false,
    this.cycleData,
    this.matchTypeStr,
    this.matchedChoice,
    this.unreadCount = 0,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      name: data['name'] ?? '',
      message: data['message'] ?? '',
      chatPartnerId: data['chatPartnerId'] ?? '',
      time: data['time'] ?? Timestamp.now(),
      isMute: data['is_mute'] ?? false,
      chatRoomId: doc.id,
      isGroup: data['isGroup'] ?? false,
      cycleData: data['cycleData'],
      matchTypeStr: data['matchType'],
      matchedChoice: data['matchedChoice'],
      unreadCount: data['unreadCount'] ?? 0,
    );
  }
}
