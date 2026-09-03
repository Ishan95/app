import 'package:app/app/models/chat/chat_model.dart';
import 'package:app/app/models/chat/contact.dart';
import 'package:app/app/models/chat/message.dart';
import 'package:app/app/models/chat/group_message.dart';
import 'package:app/app/models/mutual_transfer_match_model.dart';
import 'package:app/providers/service_providers/onesignal_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  final FirebaseFirestore _firebaseFireStore = FirebaseFirestore.instance;
  List<Contact> contactsList = [];
  List<ChatModel> chatList = [];

  String getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join("_");
  }

  Future<void> markAsRead(String userId, String chatRoomId) async {
    try {
      await _firebaseFireStore
          .collection("users_chat_metadata")
          .doc(userId)
          .collection("chatList")
          .doc(chatRoomId)
          .update({"unreadCount": 0});
    } catch (e) {
      print("Error marking chat as read: $e");
    }
  }

  // 1-ON-1 CHAT LOGIC
  Future<void> sendMessage({
    required String receiverId,
    required String message,
    required String receiverName,
    required String senderName,
    required String senderId,
  }) async {
    final Timestamp now = Timestamp.now();
    final String chatRoomId = getChatRoomId(senderId, receiverId);

    final Message newMessage = Message(senderId: senderId, receiverId: receiverId, message: message, time: now);

    // Save Message to Firestore
    await _firebaseFireStore.collection("chats").doc(chatRoomId).collection("messages").add(newMessage.toJson());

    // Update Sender Metadata
    await _firebaseFireStore.collection("users_chat_metadata").doc(senderId).collection("chatList").doc(chatRoomId).set(
      {
        "chatPartnerId": receiverId,
        "name": receiverName,
        "message": message,
        "time": now,
        "is_mute": false,
        "isGroup": false,
      },
      SetOptions(merge: true),
    );

    // Update Receiver Metadata (Increment unread count)
    await _firebaseFireStore
        .collection("users_chat_metadata")
        .doc(receiverId)
        .collection("chatList")
        .doc(chatRoomId)
        .set({
          "chatPartnerId": senderId,
          "name": senderName,
          "message": message,
          "time": now,
          "is_mute": false,
          "isGroup": false,
          "unreadCount": FieldValue.increment(1),
        }, SetOptions(merge: true));

    // Trigger OneSignal Notification
    await OneSignalService.sendChatMessageNotification(
      receiverUid: receiverId,
      senderName: senderName,
      message: message,
    );
  }

  Stream<List<Message>> getMessages(String userId, String otherUserId) {
    final String chatRoomId = getChatRoomId(userId, otherUserId);

    return _firebaseFireStore
        .collection("chats")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy('time', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  Stream<List<ChatModel>> getChats(String? userID) {
    if (userID == null || userID.isEmpty) {
      return Stream.value([]);
    }

    return _firebaseFireStore
        .collection("users_chat_metadata")
        .doc(userID)
        .collection("chatList")
        .orderBy("time", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
  }

  Future<void> deleteChat(String userId, String chatRoomId) async {
    await _firebaseFireStore
        .collection("users_chat_metadata")
        .doc(userId)
        .collection("chatList")
        .doc(chatRoomId)
        .delete();
  }

  Future<void> muteChat(String userID, String chatRoomId, bool isMute) async {
    await _firebaseFireStore
        .collection("users_chat_metadata")
        .doc(userID)
        .collection("chatList")
        .doc(chatRoomId)
        .update({"is_mute": isMute});
  }

  Future<void> getContactList(String currentUserId) async {
    setLoading(true);
    contactsList.clear();
    try {
      QuerySnapshot querySnapshot = await _firebaseFireStore.collection("users").get();
      contactsList = querySnapshot.docs.map((doc) => Contact.fromJson(doc.data() as Map<String, dynamic>)).toList();
      contactsList.removeWhere((element) => element.id == currentUserId);
    } catch (e) {
      print("Error fetching contacts: $e");
    } finally {
      setLoading(false);
    }
  }

  // CYCLE GROUP CHAT LOGIC
  Future<void> sendGroupMessage({
    required MutualTransferMatch match,
    required String message,
    required String senderId,
    required String senderName,
    required String groupName,
  }) async {
    final Timestamp now = Timestamp.now();
    final String matchId = match.matchId;

    final GroupMessage newGroupMessage = GroupMessage(
      senderId: senderId,
      senderName: senderName,
      message: message,
      time: now,
    );

    // 1. Save to central cycle messages
    await _firebaseFireStore
        .collection("cycle_group_chats")
        .doc(matchId)
        .collection("messages")
        .add(newGroupMessage.toJson());

    // 2. Prepare cycle metadata
    List<Map<String, dynamic>> cycleData =
        match.cycle.map((person) {
          return {
            'uid': person.uid,
            'firstName': person.firstName,
            'district': person.district,
            'phone': person.phone,
            'whatsapp': person.whatsapp,
          };
        }).toList();

    List<String> receiverUids = [];

    // 3. Update metadata for every participant
    for (var person in match.cycle) {
      if (person.uid == null || person.uid!.isEmpty) continue;

      bool isSender = person.uid == senderId;
      if (!isSender) receiverUids.add(person.uid!);

      await _firebaseFireStore
          .collection("users_chat_metadata")
          .doc(person.uid)
          .collection("chatList")
          .doc(matchId)
          .set({
            "chatPartnerId": matchId,
            "name": groupName,
            "message": "$senderName: $message",
            "time": now,
            "is_mute": false,
            "isGroup": true,
            "cycleData": cycleData,
            "matchType": match.matchType.toString(),
            "matchedChoice": match.matchedChoice,
            "unreadCount": isSender ? 0 : FieldValue.increment(1),
          }, SetOptions(merge: true));
    }

    // 4. Send OneSignal Push Notification
    if (receiverUids.isNotEmpty) {
      await OneSignalService.sendGroupChatMessageNotification(
        receiverUids: receiverUids,
        groupName: groupName,
        senderName: senderName,
        message: message,
      );
    }
  }

  Stream<List<GroupMessage>> getGroupMessages(String matchId) {
    return _firebaseFireStore
        .collection("cycle_group_chats")
        .doc(matchId)
        .collection("messages")
        .orderBy('time', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => GroupMessage.fromFirestore(doc)).toList());
  }
}
