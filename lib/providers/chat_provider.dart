import 'package:app/app/models/chat/chat_model.dart';
import 'package:app/app/models/chat/contact.dart';
import 'package:app/app/models/chat/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  final FirebaseFirestore _firebaseFireStore = FirebaseFirestore.instance;
  List<Contact> contactsList = [];
  List<ChatModel> chatList = []; // This will hold the metadata for the 'Chats' tab

  // Helper to generate a consistent chatRoomId
  String _getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort(); // Sort to ensure consistent ID regardless of who initiates
    return ids.join("_");
  }

  // Future<void> sendMessage(
  //     {required String receiverId,
  //     required String message,
  //     required String receiverName,
  //     required String senderName,
  //     required String senderId}) async {
  //   // final prefs = await SharedPreferences.getInstance();
  //   // final userID = prefs.getString('userId');

  //   Timestamp now = Timestamp.now();
  //   Message newMessage = Message(
  //       senderId: senderId,
  //       receiverId: receiverId,
  //       message: message,
  //       time: now);

  //   List<String> ids = [senderId, receiverId];
  //   ids.sort();

  //   String chatRoomId = ids.join("_");

  //   await _firebaseFireStore
  //       .collection("chat_users")
  //       .doc(senderId)
  //       .collection("chatList")
  //       .doc(chatRoomId)
  //       .collection("messages")
  //       .add(newMessage.toJson());
  //   await _firebaseFireStore
  //       .collection("chat_users")
  //       .doc(receiverId)
  //       .collection("chatList")
  //       .doc(chatRoomId)
  //       .collection("messages")
  //       .add(newMessage.toJson());

  //     //DocumentSnapshot documentSnapshot = await _firebaseFireStore.collection("users").doc(userID).collection("chatList").doc(chatRoomId).get();
  //     DocumentSnapshot chatRoom = await _firebaseFireStore
  //         .collection("chat_users")
  //         .doc(senderId)
  //         .collection("chatList")
  //         .doc(chatRoomId)
  //         .get();
  //     if (chatRoom.exists) {
  //       await _firebaseFireStore
  //           .collection("chat_users")
  //           .doc(senderId)
  //           .collection("chatList")
  //           .doc(chatRoomId)
  //           .update({
  //         "name": receiverName,
  //         "message": message,
  //         "chatPartnerId": receiverId,
  //         "time": now
  //       });
  //     } else {
  //       _firebaseFireStore
  //           .collection("chat_users")
  //           .doc(senderId)
  //           .collection("chatList")
  //           .doc(chatRoomId)
  //           .set({
  //         "name": receiverName,
  //         "message": message,
  //         "chatPartnerId": receiverId,
  //         "time": now,
  //         "is_mute": false
  //       });
  //     }

  //   DocumentSnapshot receiverChatRoom = await _firebaseFireStore
  //       .collection("chat_users")
  //       .doc(receiverId)
  //       .collection("chatList")
  //       .doc(chatRoomId)
  //       .get();
  //   if (receiverChatRoom.exists) {
  //       print(senderName);
  //     await _firebaseFireStore
  //         .collection("chat_users")
  //         .doc(receiverId)
  //         .collection("chatList")
  //         .doc(chatRoomId)
  //         .update({
  //       "name": senderName,
  //       "message": message,
  //       "chatPartnerId": receiverId,
  //       "time": now
  //     });
  //   } else {
  //     _firebaseFireStore
  //         .collection("chat_users")
  //         .doc(receiverId)
  //         .collection("chatList")
  //         .doc(chatRoomId)
  //         .set({
  //       "name": senderName,
  //       "message": message,
  //       "chatPartnerId": receiverId,
  //       "time": now,
  //       "is_mute": false
  //     });
  //   }
  // }

  //  SEND MESSAGE
  Future<void> sendMessage({
    required String receiverId,
    required String message,
    required String receiverName,
    required String senderName,
    required String senderId, // Passed from current user
  }) async {
    final Timestamp now = Timestamp.now();
    final String chatRoomId = _getChatRoomId(senderId, receiverId);

    // 1. Create the Message object
    final Message newMessage = Message(
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      time: now,
    );

    // 2. Add message to the central 'chats/{chatRoomId}/messages' subcollection
    await _firebaseFireStore
        .collection("chats") // Central chats collection
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toJson());

    // 3. Update or create chat metadata for SENDER in their `users_chat_metadata/{senderId}/chatList`
    await _firebaseFireStore
        .collection("users_chat_metadata") // Or your "chat_users" collection
        .doc(senderId)
        .collection("chatList")
        .doc(chatRoomId)
        .set(
          {
            "chatPartnerId": receiverId,
            "name": receiverName, // Display name of the person sender is chatting with
            "message": message,
            "time": now,
            "is_mute": false, // Default to false if not already set
          },
          SetOptions(merge: true), // Merge to preserve existing fields like 'is_mute'
        );

    // 4. Update or create chat metadata for RECEIVER in their `users_chat_metadata/{receiverId}/chatList`
    await _firebaseFireStore
        .collection("users_chat_metadata") // Or your "chat_users" collection
        .doc(receiverId)
        .collection("chatList")
        .doc(chatRoomId)
        .set(
          {
            "chatPartnerId": senderId,
            "name": senderName, // Display name of the person receiver is chatting with
            "message": message,
            "time": now,
            "is_mute": false, // Default to false if not already set
          },
          SetOptions(merge: true),
        );
  }

  //  GET MESSAGES (Real-time Stream)
  Stream<List<Message>> getMessages(String userId, String otherUserId) {
    final String chatRoomId = _getChatRoomId(userId, otherUserId);

    return _firebaseFireStore
        .collection("chats") // Listen to the central chats collection
        .doc(chatRoomId)
        .collection("messages")
        .orderBy('time', descending: false) // Oldest message first
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromFirestore(doc))
            .toList());
  }

  //  GET CHATS LIST FOR A USER (Real-time Stream for ContactScreen's "Chats" tab)
  Stream<List<ChatModel>> getChats(String? userID) {
    if (userID == null || userID.isEmpty) {
      return Stream.value([]); // Return an empty stream if userID is invalid
    }

    return _firebaseFireStore
        .collection("users_chat_metadata") // Or your "chat_users" collection
        .doc(userID)
        .collection("chatList")
        .orderBy("time", descending: true) // Newest chat first
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromFirestore(doc))
            .toList());
  }

  //  DELETE CHAT
  Future<void> deleteChat(String userId, String chatRoomId) async {
    // Delete the chat metadata from the user's chatList
    await _firebaseFireStore
        .collection("users_chat_metadata")
        .doc(userId)
        .collection("chatList")
        .doc(chatRoomId)
        .delete();

    // NOTE: You might also want to delete the entire /chats/{chatRoomId} and its messages
    // This is more complex as it affects both users. For a simple delete (like WhatsApp),
    // it usually just removes it from the current user's view, not the other user's.
    // If you want to delete for both, you'd need logic to check if the other user
    // has also "deleted" it, or a separate mechanism.
    // For now, this just removes it from the current user's `chatList` view.
  }

  //  MUTE CHAT
  Future<void> muteChat(String userID, String chatRoomId, bool isMute) async {
    await _firebaseFireStore
        .collection("users_chat_metadata")
        .doc(userID)
        .collection("chatList")
        .doc(chatRoomId)
        .update({"is_mute": isMute});
  }

  //  GET CONTACT LIST (if fetching from Firestore directly)
  // The original getContactList was commented out and seemed to be doing something with 'response.data["data"]'
  // which hints at an API call. If you're fetching contacts from Firestore users collection,
  // this is a basic example. Adjust as per your actual user data structure.
  Future<void> getContactList(String currentUserId) async {
    setLoading(true);
    contactsList.clear();
    try {
      // Assuming your user data is in a 'users' collection
      QuerySnapshot querySnapshot = await _firebaseFireStore.collection("users").get();
      contactsList = querySnapshot.docs.map((doc) => Contact.fromJson(doc.data() as Map<String, dynamic>)).toList();
      contactsList.removeWhere((element) => element.id == currentUserId); // Don't show current user in contacts
    } catch (e) {
      print("Error fetching contacts: $e");
    } finally {
      setLoading(false);
    }
  }

  // bool _isLoading = false;

  // bool get isLoading => _isLoading;

  // setLoading(bool loading) {
  //   _isLoading = loading;
  //   notifyListeners();
  // }

  // final FirebaseFirestore _firebaseFireStore = FirebaseFirestore.instance;
  // List<Contact> contactsList = [];
  // List<ChatModel> chatList = [];

  // Future<void> sendMessage(
  //     {required String receiverId,
  //     required String message,
  //     required String receiverName,
  //     required String senderName}) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userID = prefs.getString('userId');

  //   Timestamp now = Timestamp.now();
  //   Message newMessage = Message(
  //       senderId: userID ?? "",
  //       receiverId: receiverId,
  //       message: message,
  //       time: now);

  //   List<String> ids = [userID ?? "", receiverId];
  //   ids.sort();

  //   String chatRoomId = ids.join("_");

  //   await _firebaseFireStore
  //       .collection("chat_users")
  //       .doc(userID)
  //       .collection("chatList")
  //       .doc(chatRoomId)
  //       .collection("messages")
  //       .add(newMessage.toJson());
  //   await _firebaseFireStore
  //       .collection("chat_users")
  //       .doc(receiverId)
  //       .collection("chatList")
  //       .doc(chatRoomId)
  //       .collection("messages")
  //       .add(newMessage.toJson());
  //   if (userID != null) {
  //     //DocumentSnapshot documentSnapshot = await _firebaseFireStore.collection("users").doc(userID).collection("chatList").doc(chatRoomId).get();
  //     DocumentSnapshot chatRoom = await _firebaseFireStore
  //         .collection("chat_users")
  //         .doc(userID)
  //         .collection("chatList")
  //         .doc(chatRoomId)
  //         .get();
  //     if (chatRoom.exists) {
  //       await _firebaseFireStore
  //           .collection("chat_users")
  //           .doc(userID)
  //           .collection("chatList")
  //           .doc(chatRoomId)
  //           .update({
  //         "name": receiverName,
  //         "message": message,
  //         "chatPartnerId": receiverId,
  //         "time": now
  //       });
  //     } else {
  //       _firebaseFireStore
  //           .collection("chat_users")
  //           .doc(userID)
  //           .collection("chatList")
  //           .doc(chatRoomId)
  //           .set({
  //         "name": receiverName,
  //         "message": message,
  //         "chatPartnerId": receiverId,
  //         "time": now,
  //         "is_mute": false
  //       });
  //     }
  //   }

  //   DocumentSnapshot receiverChatRoom = await _firebaseFireStore
  //       .collection("chat_users")
  //       .doc(receiverId)
  //       .collection("chatList")
  //       .doc(chatRoomId)
  //       .get();
  //   if (receiverChatRoom.exists) {
  //       print(senderName);
  //     await _firebaseFireStore
  //         .collection("chat_users")
  //         .doc(receiverId)
  //         .collection("chatList")
  //         .doc(chatRoomId)
  //         .update({
  //       "name": senderName,
  //       "message": message,
  //       "chatPartnerId": receiverId,
  //       "time": now
  //     });
  //   } else {
  //     _firebaseFireStore
  //         .collection("chat_users")
  //         .doc(receiverId)
  //         .collection("chatList")
  //         .doc(chatRoomId)
  //         .set({
  //       "name": senderName,
  //       "message": message,
  //       "chatPartnerId": receiverId,
  //       "time": now,
  //       "is_mute": false
  //     });
  //   }
  // }

  // Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
  //   List<String> ids = [userId, otherUserId];
  //   ids.sort();

  //   String chatRoomId = ids.join("_");
  //   return _firebaseFireStore
  //       .collection("chat_users")
  //       .doc(userId)
  //       .collection("chatList")
  //       .doc(chatRoomId)
  //       .collection("messages")
  //       .orderBy('time', descending: false)
  //       .snapshots();
  // }

  // Stream<QuerySnapshot> getChats(String? userID) {
  //   if (userID == null || userID.isEmpty) {
  //     return const Stream.empty();
  //   }

  //   return _firebaseFireStore
  //       .collection("chat_users")
  //       .doc(userID)
  //       .collection("chatList")
  //       .orderBy("time", descending: true)
  //       .snapshots();
  // }

  // Future<void> getContactList(String userId) async {
  //   setLoading(true);
  //   contactsList.clear();
  //   try {
  //         contactsList = response.data["data"]
  //             .map<Contact>((contact) => Contact.fromJson(contact))
  //             .toList();
  //   } catch (ex) {
  //     setLoading(false);
  //   }

  //   QuerySnapshot querySnapshot = await _firebaseFireStore.collection("chat_users").get();
  //   contactsList = querySnapshot.docs.map((doc) => Contact.fromJson(doc.data() as Map<String, dynamic>)).toList();
  //   contactsList.removeWhere((element) => element.id == userID);
  // }

  // Future<void> deleteChat(String userId, String chatRoomId) async {
  //   final docRef = FirebaseFirestore.instance
  //       .collection("chat_users")
  //       .doc(userId)
  //       .collection("chatList")
  //       .doc(chatRoomId);

  //   final messagesSnapshot = await docRef.collection("messages").get();
  //   final batch = FirebaseFirestore.instance.batch();

  //   for (var doc in messagesSnapshot.docs) {
  //     batch.delete(doc.reference);
  //   }

  //   batch.delete(docRef);
  //   await batch.commit();
  // }

  // Future<void> muteChat(String userID, String chatRoomId, bool isMute) async {
  //   await _firebaseFireStore
  //       .collection("chat_users")
  //       .doc(userID)
  //       .collection("chatList")
  //       .doc(chatRoomId)
  //       .update({"is_mute": isMute});
  // }
}
