import 'package:app/app/models/person_details_model.dart';
import 'package:app/app/themes/text_themes.dart';
import 'package:app/app/utils/asset_manager.dart';
import 'package:app/app/utils/color_manager.dart';
import 'package:app/app/utils/responsive_size_config.dart';
import 'package:app/screens/notification/notification_model.dart';
import 'package:app/screens/notification/widget/person_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/l10n/app_localizations.dart';

class TabView extends StatefulWidget {
  final int index;
  final bool isActive;
  const TabView({super.key, required this.index, this.isActive = true});

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> {
  Set<String> expandedIds = {};
  final Map<String, NotificationModel> _openedNotifications = {};

  @override
  void didUpdateWidget(TabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive && !widget.isActive) {
      _openedNotifications.clear();
      expandedIds.clear();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await FirebaseFirestore.instance.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  Future<void> deleteNotification(String notificationId, AppLocalizations l10n) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').doc(notificationId).delete();
      _openedNotifications.remove(notificationId);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.notificationDeleted), duration: const Duration(seconds: 1)));
    } catch (e) {
      print("Error deleting: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final bool isUnreadList = widget.index == 1;
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('notifications')
              .where('receiverId', isEqualTo: "${currentUser?.uid}")
              .where('isRead', isEqualTo: !isUnreadList)
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 40));
        }

        final visibleNotifications = <String, NotificationModel>{
          for (final doc in snapshot.data!.docs)
            doc.id: NotificationModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id),
          if (isUnreadList) ..._openedNotifications,
        };
        final notifications = visibleNotifications.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (notifications.isEmpty) {
          return Center(child: Text(l10n.noNotifications, style: context.semiBold14(color: ColorManager.grayText)));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            bool isExpanded = expandedIds.contains(notification.id);

            return Dismissible(
              key: Key(notification.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                deleteNotification(notification.id, l10n);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 5, offset: Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Image.asset(
                        notification.title.contains("Choice 1")
                            ? Assets.choice1
                            : notification.title.contains("Choice 2")
                            ? Assets.choice2
                            : Assets.choice3,
                        width: context.horizontalSize(40),
                      ),
                      title: Text(
                        notification.title,
                        style: context.bold14(
                          color:
                              notification.title.contains("Choice 1")
                                  ? ColorManager.kPrimary
                                  : notification.title.contains("Choice 2")
                                  ? ColorManager.kPrimaryDark
                                  : ColorManager.blackMedium,
                        ),
                      ),
                      subtitle: Text(
                        notification.message,
                        maxLines: notification.senderID == '23' && !isExpanded ? 3 : null,
                        overflow: notification.senderID == '23' && !isExpanded ? TextOverflow.ellipsis : null,
                        style: context.regular14(color: ColorManager.grayText),
                      ),
                      trailing:
                          isUnreadList
                              ? (notification.isRead
                                  ? Icon(Icons.check_circle, color: ColorManager.kPrimary)
                                  : Icon(Icons.circle, size: 10, color: ColorManager.kPrimary))
                              : null,
                      onTap: () async {
                        setState(() {
                          if (isExpanded) {
                            expandedIds.remove(notification.id);
                          } else {
                            expandedIds.add(notification.id);
                            if (isUnreadList && !notification.isRead) {
                              _openedNotifications[notification.id] = NotificationModel(
                                id: notification.id,
                                title: notification.title,
                                message: notification.message,
                                receiverID: notification.receiverID,
                                senderID: notification.senderID,
                                isRead: true,
                                createdAt: notification.createdAt,
                              );
                            }
                          }
                        });
                        if (!isExpanded && isUnreadList && !notification.isRead) {
                          try {
                            await markAsRead(notification.id);
                          } catch (e) {
                            if (mounted) {
                              setState(() => _openedNotifications.remove(notification.id));
                            }
                            debugPrint('Could not mark notification as read: $e');
                          }
                        }
                      },
                    ),

                    if (isExpanded && notification.senderID == '23' && !notification.isRead)
                      Padding(
                        padding: const EdgeInsets.only(right: 18, bottom: 12),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => markAsRead(notification.id),
                            child: Text(l10n.markAsRead),
                          ),
                        ),
                      ),

                    if (isExpanded && notification.senderID != '23')
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(notification.senderID).get(),
                        builder: (context, userSnap) {
                          if (userSnap.connectionState == ConnectionState.waiting) {
                            return Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 40)),
                            );
                          }

                          if (!userSnap.hasData || !userSnap.data!.exists) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                l10n.userDetailsUnavailable,
                                style: context.semiBold14(color: ColorManager.grayText),
                              ),
                            );
                          }

                          final userDetails = PersonDetailsModel.fromJson(
                            userSnap.data!.data() as Map<String, dynamic>,
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                PersonCard(personDetails: userDetails),
                                SizedBox(height: context.verticalSize(10)),
                                !notification.isRead
                                    ? GestureDetector(
                                      onTap: () async {
                                        await markAsRead(notification.id);
                                      },
                                      child: Text(
                                        l10n.markAsRead,
                                        style: context.semiBold14(color: ColorManager.kPrimary),
                                      ),
                                    )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
