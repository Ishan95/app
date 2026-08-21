import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String message;
  final Timestamp time;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.time,
  });

  Map<String, dynamic> toJson(){
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'time': time,
    };
  }

  //
  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Message(
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      message: data['message'],
      time: data['time'],
    );
  }
}