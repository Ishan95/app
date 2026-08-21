// import 'package:app/app/models/chat/contact.dart';
// import 'package:app/providers/chat_provider.dart';
// import 'package:app/providers/filtter_provider.dart';
// import 'package:app/screens/chat/message_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:provider/provider.dart';
// import '../../../../providers/auth_provider.dart';
// import 'chat_screen.dart';
// import '../../../../../app/export.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final filterProvider =
//           Provider.of<FiltterProvider>(context, listen: false);
//       final userId = filterProvider.firebaseUser?.uid;
//       if (userId != null && userId.isNotEmpty) {
//         Provider.of<ChatProvider>(context, listen: false).getChats(userId);
//       }
//     });
//     _tabController = TabController(length: 2, vsync: this);
//     _tabController.index = 0;
//   }

//   void _onChatTapped(String chatPartnerId) {
//     Contact? contact = Provider.of<ChatProvider>(context, listen: false)
//         .contactsList
//         .where((contact) => contact.id == chatPartnerId)
//         .firstOrNull;
//     // Contact contact = Contact(id: '439', name: 'isueu madusjan', role: 'Driver');
//     // final ChatProvider provider = Provider.of<ChatProvider>(context, listen: false);
//     //         provider.contactsList.forEach((c) => print('${c.name} | ${c.role} | ${c.status}'));
//     //         print('contact?.status');
//     if (contact != null) {
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => MessageScreen(
//             contact: contact,
//           ),
//         ),
//       );
//     }
//   }

//   void _onContactTapped(Contact contact) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => MessageScreen(
//           contact: contact,
//         ),
//       ),
//     );
//   }

//   /// **Handle Chat Deletion**
//   void _deleteChat(String userId, String chatRoomId) {
//     Provider.of<ChatProvider>(context, listen: false)
//         .deleteChat(userId, chatRoomId);
//     setState(() {});
//   }

//   /// **Handle Mute Action**
//   void _muteOrUnMuteChat(String userId, String chatRoomId, bool isMute) {
//     Provider.of<ChatProvider>(context, listen: false)
//         .muteChat(userId, chatRoomId, isMute);
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     final AuthenticationProvider authProvider =
//         Provider.of<AuthenticationProvider>(context, listen: false);
//       final filterProvider =
//           Provider.of<FiltterProvider>(context, listen: false);
//     final ChatProvider provider =
//         Provider.of<ChatProvider>(context, listen: false);
//     return SizedBox(
//       width: context.screenWidth,
//       height: context.screenHeight - 10.0,
//       child: Column(
//         children: [
//           SizedBox(
//             height: context.verticalSize(40),
//           ),
//           Center(
//             child: Text(
//               'Chats',
//               style: context.semiBold20(color: ColorManager.blackMedium),
//             ),
//           ),
//           SizedBox(
//             height: context.verticalSize(20),
//           ),
//           Padding(
//             padding: context.padding(horizontal: 24, vertical: 16),
//             child: Container(
//               height: context.verticalSize(50),
//               decoration: BoxDecoration(
//                   color: ColorManager.white10,
//                   borderRadius: BorderRadius.circular(25.0)),
//               child: TabBar(
//                 onTap: (value) => setState(() {}),
//                 controller: _tabController,
//                 labelColor: ColorManager.black,
//                 labelStyle: context.bold12(color: ColorManager.black),
//                 labelPadding: EdgeInsets.zero,
//                 indicatorSize: TabBarIndicatorSize.tab,
//                 dividerColor: Colors.transparent,
//                 indicatorColor: ColorManager.kPrimary,
//                 indicator: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: ColorManager.gradientButtons2,
//                       begin: const Alignment(1.00, -0.00),
//                       end: const Alignment(-1, 0),
//                     ),
//                     borderRadius: BorderRadius.circular(40.0)),
//                 unselectedLabelColor: ColorManager.disabledText,
//                 tabs: const [
//                   Tab(
//                     text: 'Chats',
//                   ),
//                   Tab(
//                     text: 'Contacts',
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 SafeArea(
//                   child: Padding(
//                       padding: context.padding(horizontal: 24),
//                       child: authProvider.appUser?.id != null
//                           ? StreamBuilder(
//                               stream: provider
//                                   .getChats(filterProvider.firebaseUser?.uid ?? ""),
//                               builder: (context, snapshot) {
//                                 if (snapshot.hasError) {
//                                   return const Text("Error");
//                                 } else if (snapshot.connectionState ==
//                                     ConnectionState.waiting) {
//                                   return const Text("Loading");
//                                 }
//                                 return ListView(
//                                   children: snapshot.data!.docs.map((doc) {
//                                     return Slidable(
//                                       key: ValueKey(1),
//                                       endActionPane: ActionPane(
//                                         motion: const DrawerMotion(),
//                                         children: [
//                                           /// **Mute Chat Action**
//                                           SlidableAction(
//                                             onPressed: (context) =>
//                                                 _muteOrUnMuteChat(
//                                                     authProvider.appUser?.id ??
//                                                         "",
//                                                     doc.id,
//                                                     !doc['is_mute']),
//                                             backgroundColor: Colors.orange,
//                                             foregroundColor: Colors.white,
//                                             icon: doc['is_mute']
//                                                 ? Icons.volume_up
//                                                 : Icons.volume_off,
//                                             label: doc['is_mute']
//                                                 ? 'UnMute'
//                                                 : 'Mute',
//                                           ),

//                                           /// **Delete Chat Action**
//                                           SlidableAction(
//                                             onPressed: (context) => _deleteChat(
//                                                 authProvider.appUser?.id ?? "",
//                                                 doc.id),
//                                             backgroundColor: Colors.red,
//                                             foregroundColor: Colors.white,
//                                             icon: Icons.delete,
//                                             label: 'Delete',
//                                           ),
//                                         ],
//                                       ),
//                                       child: ChatCard(
//                                         name: doc['name'],
//                                         lastMessage: doc['message'],
//                                         time: DateFormat('hh:mm a')
//                                             .format(doc['time'].toDate()),
//                                         profileImage: "",
//                                         onTap: () {
//                                           List<String> ids = doc.id.split("_");
//                                           if (ids[0] ==
//                                               authProvider.appUser?.id) {
//                                             _onChatTapped(ids[1]);
//                                           } else {
//                                             _onChatTapped(ids[0]);
//                                           }
//                                         },
//                                         isMute: doc['is_mute'],
//                                       ),
//                                     );
//                                   }).toList(),
//                                 );
//                               })
//                           : const SizedBox()),
//                 ),

//                 /// **Contacts List**
//                 /// **Contacts List**
//                 // SafeArea(
//                 //   child: Padding(
//                 //     padding: context.padding(horizontal: 24),
//                 //     child: contacts.isNotEmpty
//                 //         ? Consumer<ChatProvider>(
//                 //             builder: (context, provider, _) {
//                 //             if (provider.isLoading) {
//                 //               return Center(
//                 //                 child: SpinKitFadingCircle(
//                 //                   color: ColorManager.kPrimary,
//                 //                   size: 40,
//                 //                 ),
//                 //               );
//                 //             } else {
//                 //               return ListView.builder(
//                 //                 itemCount: provider.contactsList.length +
//                 //                     1, // +1 to include "Find People Nearby"
//                 //                 itemBuilder: (context, index) {
//                 //                   if (index == 0) {
//                 //                     // **First item should be "Find People Nearby"**
//                 //                     return Column(
//                 //                       children: [
//                 //                         // FindPeopleNearbyCard(
//                 //                         //   onTap: () {
//                 //                         //     print(
//                 //                         //         "Find People Nearby tapped");
//                 //                         //   },
//                 //                         // ),
//                 //                         // const SizedBox(
//                 //                         //     height:
//                 //                         //         8), // **Added spacing**
//                 //                       ],
//                 //                     );
//                 //                   }

//                 //                   // **Render normal contacts**
//                 //                   final contactIndex =
//                 //                       index - 1; // Adjust index for contacts
//                 //                   return Slidable(
//                 //                     key: ValueKey(1),
//                 //                     endActionPane: ActionPane(
//                 //                       motion: const DrawerMotion(),
//                 //                       children: [
//                 //                         /// **Delete Chat Action**
//                 //                         SlidableAction(
//                 //                           onPressed: (context) {
//                 //                             print('object');
//                 //                           },
//                 //                           backgroundColor: Colors.red,
//                 //                           foregroundColor: Colors.white,
//                 //                           icon: Icons.delete,
//                 //                           label: 'Delete',
//                 //                         ),
//                 //                       ],
//                 //                     ),
//                 //                     child: Padding(
//                 //                       padding: context.padding(right: 10),
//                 //                       child: ContactCardNew(
//                 //                         name: provider
//                 //                                 .contactsList[contactIndex]
//                 //                                 .name ??
//                 //                             "Empty",
//                 //                         role: provider
//                 //                                 .contactsList[contactIndex]
//                 //                                 .role ??
//                 //                             "Empty",
//                 //                         profileImage: provider
//                 //                             .contactsList[contactIndex]
//                 //                             .profileImage,
//                 //                         onTap: () => _onContactTapped(provider
//                 //                             .contactsList[contactIndex]),
//                 //                       ),
//                 //                     ),
//                 //                   );
//                 //                 },
//                 //               );
//                 //             }
//                 //           })
//                 //         : const Center(
//                 //             child: Text(
//                 //               "No contacts available",
//                 //               style: TextStyle(
//                 //                   color: Colors.black54, fontSize: 16),
//                 //             ),
//                 //           ),
//                 //   ),
//                 // ),
//               ],
//             ),
//           ),
//           SizedBox(
//             height: context.verticalSize(50),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:app/app/models/chat/chat_model.dart';
import 'package:app/app/models/chat/contact.dart';
import 'package:app/app/themes/text_themes.dart';
import 'package:app/app/utils/color_manager.dart';
import 'package:app/app/utils/responsive_size_config.dart';
import 'package:app/app/widgets/chat_card.dart';
import 'package:app/providers/chat_provider.dart';
import 'package:app/providers/filtter_provider.dart';
import 'package:app/screens/chat/message_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For DateFormat
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:app/app/utils/color_manager.dart'; // Assuming ColorManager and other utils
// import 'package:app/app/utils/context_extensions.dart'; // Assuming context extensions
import 'package:flutter_spinkit/flutter_spinkit.dart'; // For SpinKitFadingCircle
// import 'package:flutter_slidable/flutter_slidable.dart'; // If you're using slidable
// import 'package:app/app/export.dart'; // Or specific imports for ChatProvider, ChatCard, Contact, MessageScreen, AuthenticationProvider, FiltterProvider

// (Placeholders for ColorManager, ContextExtensions, etc. as defined above if needed)

class ChatScreen extends StatefulWidget {
  // Renamed from _ContactScreenState to ChatScreen
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

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // Potentially fetch initial contacts if not handled elsewhere
    //   final filterProvider = Provider.of<FiltterProvider>(
    //     context,
    //     listen: false,
    //   );
    //   if (filterProvider.firebaseUser?.uid != null) {
    //     Provider.of<ChatProvider>(
    //       context,
    //       listen: false,
    //     ).getContactList(filterProvider.firebaseUser!.uid);
    //   }
    // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //  Navigation to MessageScreen from a ChatCard
  void _onChatTapped(ChatModel chatItem) {
    // You need to fetch the full Contact object for the chat partner
    // This assumes you have access to a list of all users/contacts.
    // For simplicity, we'll create a Contact from the chatItem's metadata,
    // but in a real app, you might look this up from your main user list.
    final contact = Contact(
      id: chatItem.chatPartnerId,
      name: chatItem.name,
      role: 'Chat Partner', // Placeholder role
      profileImage: null, // You'd fetch this if available
      status: '', // You'd fetch this if available
    );

    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MessageScreen(contact: contact)));
  }

  //  Navigation to MessageScreen from a ContactCard
  void _onContactTapped(Contact contact) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MessageScreen(contact: contact)));
  }

  @override
  Widget build(BuildContext context) {
    final FiltterProvider filterProvider = Provider.of<FiltterProvider>(context, listen: false);
    final ChatProvider chatProvider = Provider.of<ChatProvider>(context); // Listen to changes for contactsList

    final String? currentUserId = filterProvider.firebaseUser?.uid;

    return SizedBox(
      width: context.screenWidth,
      height: context.screenHeight - 10.0,
      child: Column(
        children: [
          SizedBox(height: context.verticalSize(60)),
          Center(child: Text('Chats', style: context.semiBold20(color: ColorManager.blackMedium))),
          SizedBox(height: context.verticalSize(20)),
          // Padding(
          //   padding: context.padding(horizontal: 24, vertical: 16),
          //   child: Container(
          //     height: context.verticalSize(50),
          //     decoration: BoxDecoration(
          //       color: ColorManager.white10,
          //       borderRadius: BorderRadius.circular(25.0),
          //     ),
          //     child: TabBar(
          //       onTap: (value) => setState(() {}),
          //       controller: _tabController,
          //       labelColor: ColorManager.black,
          //       labelStyle: context.bold12(color: ColorManager.black),
          //       labelPadding: EdgeInsets.zero,
          //       indicatorSize: TabBarIndicatorSize.tab,
          //       dividerColor: Colors.transparent,
          //       indicatorColor: ColorManager.kPrimary,
          //       indicator: BoxDecoration(
          //         gradient: LinearGradient(
          //           colors: ColorManager.gradientButtons2,
          //           begin: const Alignment(1.00, -0.00),
          //           end: const Alignment(-1, 0),
          //         ),
          //         borderRadius: BorderRadius.circular(40.0),
          //       ),
          //       unselectedLabelColor: ColorManager.disabledText,
          //       tabs: const [Tab(text: 'Chats'), Tab(text: 'Contacts')],
          //     ),
          //   ),
          // ),
          Expanded(
            // child: TabBarView(
            //   controller: _tabController,
            //   children: [
            //  CHATS TAB
            child: Padding(
              padding: context.padding(horizontal: 24),
              child:
                  currentUserId != null
                      ? StreamBuilder<List<ChatModel>>(
                        stream: chatProvider.getChats(currentUserId),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
                            );
                          } else if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Text("No active chats.", style: TextStyle(color: ColorManager.grayText)),
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
                                // Re-enabled Slidable
                                key: ValueKey(chatItem.chatRoomId), // Use unique key
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
                                      label: chatItem.isMute ? 'UnMute' : 'Mute',
                                    ),
                                    SlidableAction(
                                      onPressed:
                                          (context) => chatProvider.deleteChat(currentUserId, chatItem.chatRoomId),
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                  ],
                                ),
                                child: ChatCard(
                                  name: chatItem.name,
                                  lastMessage: chatItem.message,
                                  time: DateFormat('MMM d, hh:mm a').format(chatItem.time.toDate()),
                                  profileImage: "", // You'd fetch this from the actual contact
                                  onTap: () => _onChatTapped(chatItem),
                                  isMute: chatItem.isMute,
                                ),
                              );
                            },
                          );
                        },
                      )
                      : Center(
                        child: Text("Please login to see chats.", style: TextStyle(color: ColorManager.grayText)),
                      ),
            ),
          ),

          //  CONTACTS TAB
          // SafeArea(
          //   child: Padding(
          //     padding: context.padding(horizontal: 24),
          //     child:
          //         chatProvider.isLoading
          //             ? Center(
          //               child: SpinKitFadingCircle(
          //                 color: ColorManager.kPrimary,
          //                 size: 40,
          //               ),
          //             )
          //             : chatProvider.contactsList.isNotEmpty
          //             ? ListView.builder(
          //               itemCount:
          //                   chatProvider
          //                       .contactsList
          //                       .length, // Removed +1 for "Find People Nearby" unless you add it back
          //               itemBuilder: (context, index) {
          //                 final contact =
          //                     chatProvider.contactsList[index];
          //                 return Slidable(
          //                   // Re-enabled Slidable
          //                   key: ValueKey(contact.id), // Use unique key
          //                   endActionPane: ActionPane(
          //                     motion: const DrawerMotion(),
          //                     children: [
          //                       SlidableAction(
          //                         onPressed: (context) {
          //                           // Handle contact specific action, e.g., block, delete from list
          //                           print(
          //                             'Delete contact action for ${contact.name}',
          //                           );
          //                         },
          //                         backgroundColor: Colors.red,
          //                         foregroundColor: Colors.white,
          //                         icon: Icons.delete,
          //                         label: 'Delete',
          //                       ),
          //                     ],
          //                   ),
          //                   child: Padding(
          //                     padding: context.padding(right: 10),
          //                     child: ContactCardNew(
          //                       // Assuming ContactCardNew is your widget for contacts
          //                       name: contact.name ?? "",
          //                       role: contact.role ?? "",
          //                       profileImage: contact.profileImage,
          //                       onTap: () => _onContactTapped(contact),
          //                     ),
          //                   ),
          //                 );
          //               },
          //             )
          //             : ListView.builder(
          //         padding: EdgeInsets.zero,
          //         itemCount: filterProvider.filteredUsersData.length,
          //         itemBuilder: (context, index) {
          //           final user = filterProvider.filteredUsersData[index];
          //           // return ChatCard(
          //           //               name: "${user.firstName}",
          //           //               lastMessage: "",
          //           //               time: DateFormat(
          //           //                 'hh:mm a',
          //           //               ).format(chatItem.time.toDate()),
          //           //               profileImage:
          //           //                   "", // You'd fetch this from the actual contact
          //           //               onTap: () => _onChatTapped(ChatModel(name: "${user.firstName}", message: "", chatPartnerId: user.uid, time: Timestamp(0, 0), isMute: false, chatRoomId: chatRoomId)),
          //           //               // isMute: chatItem.isMute,
          //           //             );
          //         },
          //       ),
          //       // Center(
          //       //         child: Text(
          //       //           "No contacts available",
          //       //           style: TextStyle(
          //       //             color: ColorManager.blackMedium,
          //       //             fontSize: 16,
          //       //           ),
          //       //         ),
          //       //       ),
          //   ),
          // ),
          //   ],
          // ),
          // Removed the extra SizedBox at the bottom as it was inside the TabBarView
        ],
      ),
    );
  }
}

// Ensure you have this import for Slidable

// Assuming you have this widget for displaying individual contacts
class ContactCardNew extends StatelessWidget {
  final String name;
  final String role;
  final String? profileImage;
  final VoidCallback onTap;

  const ContactCardNew({super.key, required this.name, required this.role, this.profileImage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // color: Colors.grey.shade100, // Example background
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                // backgroundImage: profileImage != null && profileImage!.isNotEmpty
                //     ? NetworkImage(profileImage!) : null,
                backgroundColor: ColorManager.kPrimary, // Placeholder
                child:
                    name.isNotEmpty
                        ? Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18))
                        : const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: context.semiBold18(color: ColorManager.blackMedium, fontSize: 16)),
                    const SizedBox(height: 3),
                    Text(role, style: context.medium16(color: ColorManager.grayText, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
