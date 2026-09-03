import 'package:app/app/export.dart';
import 'package:flutter/material.dart';

class ChatCard extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final String? profileImage; // Optional profile image
  final VoidCallback onTap; // Required onTap callback
  final bool? isMute;
  final int unreadCount;

  const ChatCard({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.profileImage,
    required this.onTap,
    this.isMute,
    this.unreadCount = 0, // Defaults to 0
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Call function when tapped
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: ColorManager.white, borderRadius: BorderRadius.circular(10)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// **Profile Image or Blue Circle**
              profileImage != null && profileImage!.isNotEmpty
                  ? CircleAvatar(radius: 24, backgroundImage: AssetImage(profileImage!))
                  : CircleAvatar(
                    radius: 24,
                    backgroundColor: ColorManager.kPrimary,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?", // Initial
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
              const SizedBox(width: 12), // Space between avatar and text
              /// **Name & Last Message**
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: context.semiBold18(color: ColorManager.blackMedium, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lastMessage,
                      style: context
                          .medium16(
                            color: unreadCount > 0 ? ColorManager.blackMedium : ColorManager.grayText,
                            fontSize: 14,
                          )
                          .copyWith(fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              /// **Message Time, Mute Icon & Unread Badge**
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    time,
                    style: context
                        .medium16(color: unreadCount > 0 ? Colors.green : ColorManager.grayText, fontSize: 12)
                        .copyWith(fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isMute == true) Icon(Icons.volume_off, color: ColorManager.grayText, size: 16.0),

                      if (isMute == true && unreadCount > 0) const SizedBox(width: 6),

                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
