import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/app/export.dart';
import 'package:app/app/models/mutual_transfer_match_model.dart';
import 'package:app/app/models/chat/group_message.dart';
import 'package:app/providers/chat_provider.dart';
import 'package:app/providers/filtter_provider.dart';
import 'package:app/providers/account_provider.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:app/app/utils/translation_service.dart';
import 'group_members_screen.dart';

class GroupChatScreen extends StatefulWidget {
  final MutualTransferMatch match;

  const GroupChatScreen({super.key, required this.match});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _currentUserId;
  int _currentMessageCount = 0;

  StreamSubscription<DocumentSnapshot>? _metadataSubscription;

  @override
  void initState() {
    super.initState();
    _currentUserId = Provider.of<FiltterProvider>(context, listen: false).firebaseUser?.uid;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }

      if (_currentUserId != null) {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        final matchId = widget.match.matchId;

        chatProvider.markAsRead(_currentUserId!, matchId);

        _metadataSubscription = FirebaseFirestore.instance
            .collection("users_chat_metadata")
            .doc(_currentUserId)
            .collection("chatList")
            .doc(matchId)
            .snapshots()
            .listen((snapshot) {
              if (snapshot.exists) {
                final unreadCount = snapshot.data()?['unreadCount'] ?? 0;
                if (unreadCount > 0) {
                  chatProvider.markAsRead(_currentUserId!, matchId);
                }
              }
            });
      }
    });
  }

  @override
  void dispose() {
    _metadataSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessageItem(GroupMessage message, String currentUserId) {
    bool isMe = message.senderId == currentUserId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? ColorManager.kPrimary : ColorManager.whiteddd,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(2),
            bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              Text(message.senderName, style: context.semiBold14(color: ColorManager.kPrimary)),
              const SizedBox(height: 2),
            ],
            Text(
              message.message,
              style: context.regular16(color: isMe ? ColorManager.white : ColorManager.blackMedium),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(message.time.toDate()),
              style: context.regular12(color: isMe ? ColorManager.white : ColorManager.grayText),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final accProvider = Provider.of<AccountProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (_currentUserId == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: ColorManager.white),
        body: Center(child: Text(l10n.cannotLoadChat)),
      );
    }

    String groupName = widget.match.cycle
        .map((e) => TranslationService.translate(context, e.district ?? l10n.unknown))
        .join(' ➔ ');

    String subtitle = widget.match.cycle.map((e) => e.firstName ?? l10n.unknown).join(', ');

    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          backgroundColor: ColorManager.white,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: ColorManager.blackMedium),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => GroupMembersScreen(match: widget.match)));
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: ColorManager.kPrimary,
                  child: const Icon(Icons.group, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        groupName,
                        style: context.bold16(color: ColorManager.blackMedium),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: context.regular12(color: ColorManager.grayText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
            child: StreamBuilder<List<GroupMessage>>(
              stream: chatProvider.getGroupMessages(widget.match.matchId),
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

                if (snapshot.data!.length > _currentMessageCount) {
                  _currentMessageCount = snapshot.data!.length;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                    chatProvider.markAsRead(_currentUserId!, widget.match.matchId);
                  });
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data!.length,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemBuilder: (context, index) {
                    final message = snapshot.data![index];
                    return _buildMessageItem(message, _currentUserId!);
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
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage({required ChatProvider chatProvider, required AccountProvider accProvider}) {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUserId == null) return;

    final filtterProvider = Provider.of<FiltterProvider>(context, listen: false);
    final senderName = accProvider.appUser?.firstName ?? filtterProvider.appUser?.firstName ?? "User";

    String groupName = widget.match.cycle
        .map((e) => TranslationService.translate(context, e.district ?? ''))
        .join(' ➔ ');

    chatProvider.sendGroupMessage(
      match: widget.match,
      message: text,
      senderName: senderName,
      senderId: _currentUserId!,
      groupName: groupName,
    );

    _messageController.clear();
  }
}
