import 'package:app/app/models/chat/message.dart';
import 'package:app/app/themes/text_themes.dart';
import 'package:app/app/utils/color_manager.dart';
import 'package:app/providers/account_provider.dart';
import 'package:app/providers/filtter_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:app/l10n/app_localizations.dart';

import '../../../../app/models/chat/contact.dart';
import '../../../../providers/chat_provider.dart';

class MessageScreen extends StatefulWidget {
  final Contact? contact;

  const MessageScreen({super.key, required this.contact});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = Provider.of<FiltterProvider>(context, listen: false).firebaseUser?.uid;

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

  Widget _buildMessageItem(Message message, String currentUserId) {
    bool isCurrentUser = message.senderId == currentUserId;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isCurrentUser ? ColorManager.kPrimary : ColorManager.whiteddd,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isCurrentUser ? const Radius.circular(16) : const Radius.circular(2),
            bottomRight: isCurrentUser ? const Radius.circular(2) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: context.regular16(color: isCurrentUser ? ColorManager.white : ColorManager.blackMedium),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(message.time.toDate()),
              style: context.regular12(color: isCurrentUser ? ColorManager.white75 : ColorManager.grayText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, AppLocalizations l10n) {
    String formattedDate;

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      formattedDate = l10n.today;
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      formattedDate = l10n.yesterday;
    } else {
      formattedDate = DateFormat('MMMM d, yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: ColorManager.kPrimaryBlack, borderRadius: BorderRadius.circular(12)),
          child: Text(formattedDate, style: context.regular12(color: ColorManager.grayText)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final accProvider = Provider.of<AccountProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (_currentUserId == null || widget.contact == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.errorPrefix, style: TextStyle(color: ColorManager.blackMedium)),
          backgroundColor: ColorManager.white,
          iconTheme: IconThemeData(color: ColorManager.blackMedium),
        ),
        body: Center(child: Text(l10n.cannotLoadChat, style: TextStyle(color: ColorManager.blackMedium))),
      );
    }

    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: ColorManager.white,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ColorManager.blackMedium),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          flexibleSpace: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: ColorManager.kPrimary,
                  child:
                      widget.contact?.name?.isNotEmpty == true
                          ? Text(
                            "${widget.contact!.name?[0].toUpperCase()}",
                            style: const TextStyle(color: Colors.white, fontSize: 24),
                          )
                          : const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.contact?.name ?? l10n.unknownUser,
                  style: TextStyle(color: ColorManager.blackMedium, fontSize: 18, fontWeight: FontWeight.bold),
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
              stream: chatProvider.getMessages(_currentUserId!, widget.contact!.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("${l10n.errorPrefix}: ${snapshot.error}", style: TextStyle(color: ColorManager.red)),
                  );
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(l10n.sayHello, style: TextStyle(color: ColorManager.grayText)));
                }

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
                        if (showDateHeader) _buildDateHeader(message.time.toDate(), l10n),
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
              color: ColorManager.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: ColorManager.whiteddd, borderRadius: BorderRadius.circular(25)),
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(color: ColorManager.blackMedium),
                        autocorrect: false,
                        enableSuggestions: false,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: l10n.messageHint,
                          hintStyle: TextStyle(color: ColorManager.grayText),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(chatProvider: chatProvider, accProvider: accProvider),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: ColorManager.kPrimary,
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

  void _sendMessage({required ChatProvider chatProvider, required AccountProvider accProvider}) {
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
      _messageController.clear();
    }
  }
}
