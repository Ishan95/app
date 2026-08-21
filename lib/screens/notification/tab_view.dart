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

class TabView extends StatefulWidget {
  final int index;
  const TabView({super.key, required this.index});

  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> {
  Set<String> expandedIds = {};

  Future<void> markAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .delete();

      // Optional: Show a small snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Notification deleted"),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print("Error deleting: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final bool isUnreadList = widget.index == 1;

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
          return Center(
            child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 40),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Text(
              "No notifications",
              style: context.semiBold14(color: ColorManager.white),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final notification = NotificationModel.fromFirestore(
              data,
              docs[index].id,
            );
            bool isExpanded = expandedIds.contains(notification.id);

            // inside your ListView.builder
            return Dismissible(
              key: Key(notification.id), // Unique key for the notification
              direction:
                  DismissDirection.endToStart, // Swipe from right to left
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                deleteNotification(notification.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: ColorManager.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // STAGE 1: THE PREVIEW TILE
                    ListTile(
                      // leading: Icon(Icons.person_add, color: ColorManager.blue),
                      leading: Image.asset(
                        notification.title.contains("Choice 1")
                            ? Assets.choice1
                            : notification.title.contains("Choice 2")
                            ? Assets.choice2
                            : Assets.choice3,
                        width: context.horizontalSize(40)
                      ),
                      title: Text(
                        notification.title,
                        style: context.bold14(
                          color:
                              notification.title.contains("Choice 1")
                                  ? ColorManager
                                      .yellow // Top priority
                                  : notification.title.contains("Choice 2")
                                  ? ColorManager.greenPrimary
                                  : ColorManager.white,
                        ),
                      ),
                      subtitle: Text(
                        notification.message,
                        style: context.regular14(color: ColorManager.white),
                      ),
                      trailing:
                          isUnreadList
                              ? (notification.isRead
                                  ? Icon(
                                    Icons.check_circle,
                                    color: ColorManager.kPrimary,
                                  ) // Becomes green on click
                                  : Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: ColorManager.kPrimary,
                                  ))
                              : null,
                      onTap: () {

                        // 2. Toggle the expansion locally
                        setState(() {
                          if (isExpanded) {
                            expandedIds.remove(notification.id);
                          } else {
                            expandedIds.add(notification.id);
                          }
                        });
                      },
                    ),

                    // STAGE 2: THE EXPANDED PERSON CARD
                    if (isExpanded)
                      FutureBuilder<DocumentSnapshot>(
                        future:
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(
                                  notification.senderID,
                                ) // Using the ID to get live data
                                .get(),
                        builder: (context, userSnap) {
                          if (userSnap.connectionState ==
                              ConnectionState.waiting) {
                            return Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: SpinKitFadingCircle(
                                  color: ColorManager.kPrimary,
                                  size: 40,
                                ),
                              ),
                            );
                          }

                          if (!userSnap.hasData || !userSnap.data!.exists) {
                            return Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "User details no longer available",
                                style: context.semiBold14(
                                  color: ColorManager.white,
                                ),
                              ),
                            );
                          }

                          // Map data using your existing factory
                          final userDetails = PersonDetailsModel.fromJson(
                            userSnap.data!.data() as Map<String, dynamic>,
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                PersonCard(personDetails: userDetails),
                                SizedBox(height: context.verticalSize(10)),
                                !notification.isRead ? GestureDetector(
                                      onTap: () async {
                                        await markAsRead(notification.id);
                                      },
                                      child: Text("Mark as Read ✅", style: context.semiBold14(
                                  color: ColorManager.kPrimary,
                                ),)
                                    ) : SizedBox.shrink()
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
