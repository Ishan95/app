import 'package:app/app/models/chat/chat_model.dart';
import 'package:app/app/models/chat/contact.dart';
import 'package:app/app/models/mutual_transfer_match_model.dart';
import 'package:app/app/models/person_details_model.dart';
import 'package:app/app/themes/text_themes.dart';
import 'package:app/app/utils/color_manager.dart';
import 'package:app/app/utils/responsive_size_config.dart';
import 'package:app/app/widgets/chat_card.dart';
import 'package:app/providers/chat_provider.dart';
import 'package:app/providers/filtter_provider.dart';
import 'package:app/screens/chat/message_screen.dart';
import 'package:app/screens/chat/group_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = 0; // Default to Chats tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onChatTapped(ChatModel chatItem) {
    final filterProvider = Provider.of<FiltterProvider>(context, listen: false);
    final currentUserId = filterProvider.firebaseUser?.uid;

    if (currentUserId != null) {
      Provider.of<ChatProvider>(context, listen: false).markAsRead(currentUserId, chatItem.chatRoomId);
    }

    if (chatItem.isGroup) {
      List<PersonDetailsModel> cycleUsers = [];
      if (chatItem.cycleData != null) {
        for (var cd in chatItem.cycleData!) {
          String? uid = cd['uid'];
          if (uid == null) continue;

          var index = filterProvider.allUsersData.indexWhere((u) => u.uid == uid);
          if (index != -1) {
            cycleUsers.add(filterProvider.allUsersData[index]);
          } else {
            cycleUsers.add(PersonDetailsModel.fromJson(cd as Map<String, dynamic>));
          }
        }
      }

      MatchType type = MatchType.twoPerson;
      if (chatItem.matchTypeStr == MatchType.threePerson.toString()) {
        type = MatchType.threePerson;
      } else if (chatItem.matchTypeStr == MatchType.fourPerson.toString()) {
        type = MatchType.fourPerson;
      }

      MutualTransferMatch match = MutualTransferMatch(
        matchId: chatItem.chatRoomId,
        matchType: type,
        cycle: cycleUsers,
        matchedChoice: chatItem.matchedChoice ?? 0,
      );

      Navigator.of(context).push(MaterialPageRoute(builder: (context) => GroupChatScreen(match: match)));
    } else {
      final contact = Contact(
        id: chatItem.chatPartnerId,
        name: chatItem.name,
        role: 'Chat Partner',
        profileImage: null,
        status: '',
      );
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MessageScreen(contact: contact)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final FiltterProvider filterProvider = Provider.of<FiltterProvider>(context, listen: false);
    final ChatProvider chatProvider = Provider.of<ChatProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    final String? currentUserId = filterProvider.firebaseUser?.uid;

    return SizedBox(
      width: context.screenWidth,
      height: context.screenHeight - 10.0,
      child: Column(
        children: [
          SizedBox(height: context.verticalSize(60)),
          Center(child: Text(l10n.chatsTitle, style: context.semiBold20(color: ColorManager.blackMedium))),
          SizedBox(height: context.verticalSize(20)),
          Expanded(
            child: Padding(
              padding: context.padding(horizontal: 2),
              child:
                  currentUserId != null
                      ? StreamBuilder<List<ChatModel>>(
                        stream: chatProvider.getChats(currentUserId),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                "${l10n.errorPrefix}: ${snapshot.error}",
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          } else if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Text(l10n.noActiveChats, style: TextStyle(color: ColorManager.grayText)),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final chatItem = snapshot.data![index];
                              return Slidable(
                                key: ValueKey(chatItem.chatRoomId),
                                endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed:
                                          (context) => chatProvider.muteChat(
                                            currentUserId,
                                            chatItem.chatRoomId,
                                            !chatItem.isMute,
                                          ),
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      icon: chatItem.isMute ? Icons.volume_up : Icons.volume_off,
                                      label: chatItem.isMute ? l10n.unmute : l10n.mute,
                                    ),
                                    SlidableAction(
                                      onPressed:
                                          (context) => chatProvider.deleteChat(currentUserId, chatItem.chatRoomId),
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: l10n.delete,
                                    ),
                                  ],
                                ),
                                child: ChatCard(
                                  name: chatItem.name,
                                  lastMessage: chatItem.message,
                                  time: DateFormat('MMM d, hh:mm a').format(chatItem.time.toDate()),
                                  profileImage: "",
                                  onTap: () => _onChatTapped(chatItem),
                                  isMute: chatItem.isMute,
                                  unreadCount: chatItem.unreadCount,
                                ),
                              );
                            },
                          );
                        },
                      )
                      : Center(child: Text(l10n.pleaseLoginToSeeChats, style: TextStyle(color: ColorManager.grayText))),
            ),
          ),
        ],
      ),
    );
  }
}
