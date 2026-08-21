import 'package:app/app/models/chat/message.dart';
import 'package:app/app/themes/text_themes.dart';
import 'package:app/app/utils/color_manager.dart';
import 'package:app/providers/account_provider.dart';
import 'package:app/providers/filtter_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../app/models/chat/contact.dart';
import '../../../../providers/chat_provider.dart';

class MessageScreen extends StatefulWidget {
  final Contact? contact; // The user you're chatting with

  const MessageScreen({super.key, required this.contact});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController =
      ScrollController(); // To scroll to the bottom

  // Get current user's UID (you'll need your AuthenticationProvider for this)
  String? _currentUserId; // To be initialized in initState

  @override
  void initState() {
    super.initState();
    // Fetch current user's ID from your AuthenticationProvider
    _currentUserId =
        Provider.of<FiltterProvider>(context, listen: false).firebaseUser?.uid;

    // Listen for new messages and scroll to bottom
    // This is handled by the StreamBuilder and the ScrollController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Build individual message item ---
  Widget _buildMessageItem(Message message, String currentUserId) {
    bool isCurrentUser = message.senderId == currentUserId;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue.shade600 : Colors.grey.shade700,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isCurrentUser
                    ? const Radius.circular(16)
                    : const Radius.circular(2),
            bottomRight:
                isCurrentUser
                    ? const Radius.circular(2)
                    : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: context.regular16(color: ColorManager.white),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(message.time.toDate()),
              style: context.regular12(color: ColorManager.white75),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    String formattedDate;

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      formattedDate = "Today";
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      formattedDate = "Yesterday";
    } else {
      formattedDate = DateFormat('MMMM d, yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            formattedDate,
            style: context.regular12(color: ColorManager.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ChatProvider chatProvider = Provider.of<ChatProvider>(
      context,
      listen: false,
    );
    final accProvider = Provider.of<AccountProvider>(context, listen: false);
    // Ensure we have both current user and contact to chat
    if (_currentUserId == null || widget.contact == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Cannot load chat. Missing user ID or contact.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorManager.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: ColorManager.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ColorManager.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          flexibleSpace: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  // Use widget.contact?.profileImage if available, else a placeholder
                  // backgroundImage: widget.contact?.profileImage != null && widget.contact!.profileImage!.isNotEmpty
                  //     ? NetworkImage(widget.contact!.profileImage!) : const AssetImage('assets/images/default_user.png'),
                  backgroundColor: ColorManager.blue, // Placeholder background
                  child:
                      widget.contact?.name?.isNotEmpty == true
                          ? Text(
                            "${widget.contact!.name?[0].toUpperCase()}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          )
                          : const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.contact?.name ?? "Unknown User",
                  style: TextStyle(
                    color: ColorManager.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: chatProvider.getMessages(
                _currentUserId!,
                widget.contact!.id,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: TextStyle(color: ColorManager.red),
                    ),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "Say hello!",
                      style: TextStyle(color: ColorManager.white10),
                    ),
                  );
                }

                // If data exists, display messages
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final message = snapshot.data![index];
                    bool showDateHeader = false;

                    if (index == 0) {
                      showDateHeader = true;
                    } else {
                      final previousMessage = snapshot.data![index - 1];

                      DateTime currentDate = message.time.toDate();
                      DateTime previousDate = previousMessage.time.toDate();

                      showDateHeader =
                          currentDate.year != previousDate.year ||
                          currentDate.month != previousDate.month ||
                          currentDate.day != previousDate.day;
                    }
                    return Column(
                      children: [
                        if (showDateHeader)
                          _buildDateHeader(message.time.toDate()),
                        _buildMessageItem(message, _currentUserId!),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: ColorManager.black,
              child: Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: ColorManager.gray, // Slightly lighter than background
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: _messageController,
              style: TextStyle(color: ColorManager.black),
              autocorrect: false, 
              enableSuggestions: false,
              keyboardType: TextInputType.multiline,
              maxLines: null, // Allows the box to expand as the user types
              decoration: InputDecoration(
                hintText: 'Message...',
                hintStyle: TextStyle(color: ColorManager.black),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Round Send Button
        GestureDetector(
          onTap: () => _sendMessage(
            chatProvider: chatProvider,
            accProvider: accProvider,
          ),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: ColorManager.blue, // Use your primary action color
            child: Icon(Icons.send, color: ColorManager.white, size: 20),
          ),
        ),
      ],
    ),
              // child: Column(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     const SizedBox(height: 8),
              //     Container(
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 16,
              //         vertical: 2,
              //       ),
              //       decoration: BoxDecoration(
              //         color: ColorManager.black,
              //         borderRadius: BorderRadius.circular(20),
              //         border: Border.all(color: ColorManager.gray, width: 1),
              //       ),
              //       child: Row(
              //         children: [
              //           Expanded(
              //             child: TextField(
              //               controller: _messageController,
              //               style: TextStyle(color: ColorManager.white),
              //               decoration: InputDecoration(
              //                 hintText: 'Send a message',
              //                 hintStyle: TextStyle(color: ColorManager.white10),
              //                 border: InputBorder.none,
              //               ),
              //               onSubmitted: (value) {
              //                 // Call the sendMessage function
              //                 _sendMessage(
              //                   chatProvider: chatProvider,
              //                   filterProvider: filterProvider,
              //                 );
              //               },
              //             ),
              //           ),
              //           IconButton(
              //             icon: Icon(
              //               Icons.send,
              //               color: ColorManager.white10,
              //             ), // Changed to send icon
              //             onPressed: () {
              //               _sendMessage(
              //                 chatProvider: chatProvider,
              //                 filterProvider: filterProvider,
              //               );
              //             },
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage({
    required ChatProvider chatProvider,
    required AccountProvider accProvider,
  }) {
    print("Sending ID: ${_currentUserId}");
    print("Contact ID: ${widget.contact?.id}");
    print("Message: ${_messageController.text.trim()}");
    print("Receiver Name: ${widget.contact?.name}");
    print("Sender Name: ${accProvider.appUser?.firstName}");
    print("ID: ${accProvider.appUser?.uid}");
    if (_messageController.text.trim().isNotEmpty &&
        _currentUserId != null &&
        widget.contact != null &&
        accProvider.appUser?.firstName != null) {
      chatProvider.sendMessage(
        receiverId: widget.contact!.id,
        message: _messageController.text.trim(),
        receiverName: "${widget.contact?.name}",
        senderName: "${accProvider.appUser!.firstName}",
        senderId: _currentUserId!,
      );
      _messageController.clear(); // Clear input after sending
    }
  }
}