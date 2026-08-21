import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatModel{
  final String name;
  final String message;
  final String chatPartnerId;
  final Timestamp time;
  //
  final bool isMute;
  final String chatRoomId; // Added for convenience

  ChatModel({
    required this.name,
    required this.message,
    required this.chatPartnerId,
    required this.time,
    required this.isMute,
    required this.chatRoomId,
  });

  // factory ChatModel.fromJson(Map<String, dynamic> json){
  //   return ChatModel(
  //       name: json['name'],
  //       message: json['message'],
  //       chatPartnerId: json['chatPartnerId'],
  //       time: DateFormat('hh:mm a').format(json['time'].toDate())
  //   );
  // }

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      name: data['name'],
      message: data['message'],
      chatPartnerId: data['chatPartnerId'],
      time: data['time'],
      isMute: data['is_mute'] ?? false,
      chatRoomId: doc.id, // The document ID is the chatRoomId
    );
  }
}