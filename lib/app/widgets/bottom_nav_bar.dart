import 'package:app/app/models/chat/chat_model.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/chat_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/app/export.dart';
import 'package:app/l10n/app_localizations.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.onPress});

  final Function(int) onPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ChatProvider chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: const [BoxShadow(color: Color(0x0A05241A), offset: Offset(3, 3), blurRadius: 10, spreadRadius: 4)],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Consumer<AuthenticationProvider>(
            builder: (context, auth, child) {
              final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () => onPress(0),
                          behavior: HitTestBehavior.translucent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.home, color: ColorManager.grayText),
                              SizedBox(height: context.verticalSize(4)),
                              Text(l10n.homeNav, style: context.regular12(color: ColorManager.grayText)),
                              SizedBox(height: context.verticalSize(4)),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () => onPress(1),
                          behavior: HitTestBehavior.translucent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.notifications, color: ColorManager.grayText),
                              SizedBox(height: context.verticalSize(4)),
                              Text(l10n.notificationsNav, style: context.regular12(color: ColorManager.grayText)),
                              SizedBox(height: context.verticalSize(4)),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () => onPress(2),
                          behavior: HitTestBehavior.translucent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StreamBuilder<List<ChatModel>>(
                                stream: chatProvider.getChats(currentUserId),
                                builder: (context, snapshot) {
                                  int totalUnread = 0;
                                  if (snapshot.hasData) {
                                    totalUnread = snapshot.data!.fold(0, (sum, chat) => sum + chat.unreadCount);
                                  }
                                  return Badge(
                                    isLabelVisible: totalUnread > 0,
                                    label: Text(totalUnread > 99 ? '99+' : totalUnread.toString()),
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.chat, color: ColorManager.grayText),
                                  );
                                },
                              ),
                              SizedBox(height: context.verticalSize(4)),
                              Text(l10n.chatNav, style: context.regular12(color: ColorManager.grayText)),
                              SizedBox(height: context.verticalSize(4)),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () => onPress(3),
                          behavior: HitTestBehavior.translucent,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person, color: ColorManager.grayText),
                              SizedBox(height: context.verticalSize(4)),
                              Text(l10n.accountNav, style: context.regular12(color: ColorManager.grayText)),
                              SizedBox(height: context.verticalSize(4)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
