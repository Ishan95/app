import 'package:app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/app/export.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.onPress});

  final Function(int) onPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.black.withOpacity(0.91),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A05241A), // Shadow color
            offset: Offset(3, 3), // Shadow offset
            blurRadius: 10, // Blur radius
            spreadRadius: 4, // Spread radius
          ),
        ],
      ),
      padding: EdgeInsets.all(12),
      child: Consumer<AuthenticationProvider>(
        builder: (context, auth, child) {
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
                        children: [
                          Icon(Icons.home, color: ColorManager.white),
                          SizedBox(height: context.verticalSize(4)),
                          Text(
                            'Home',
                            style: context.regular12(color: ColorManager.white),
                          ),
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
                        children: [
                          Icon(Icons.notifications, color: ColorManager.white),
                          SizedBox(height: context.verticalSize(4)),
                          Text(
                            'Notifications',
                            style: context.regular12(color: ColorManager.white),
                          ),
                          SizedBox(height: context.verticalSize(4)),
                        ],
                      ),
                    ),
                  ),
                  // Spacer(flex: 1), // Add spacing for the middle button
                  // Expanded(
                  //   flex: 2,
                  //   child: GestureDetector(
                  //     onTap: () => onPress(2),
                  //     behavior: HitTestBehavior.translucent,
                  //     child: Column(
                  //       children: [
                  //         // SvgPicture.asset(
                  //         //   Assets.CarBottomTab,
                  //         // ),
                  //         SizedBox(height: context.verticalSize(2)),
                  //         Text(
                  //           'Vehicles',
                  //           style: context.regular12(color: ColorManager.white),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => onPress(2),
                      behavior: HitTestBehavior.translucent,
                      child: Column(
                        children: [
                          Icon(Icons.chat, color: ColorManager.white),
                          SizedBox(height: context.verticalSize(4)),
                          Text(
                            'Chat',
                            style: context.regular12(color: ColorManager.white),
                          ),
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
                        children: [
                          Icon(Icons.person, color: ColorManager.white),
                          SizedBox(height: context.verticalSize(4)),
                          Text(
                            'Account',
                            style: context.regular12(color: ColorManager.white),
                          ),
                          SizedBox(height: context.verticalSize(4)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Positioned(
              //   top: -context.verticalSize(
              //       50), // Adjust to move the icon above the bar
              //   child: GestureDetector(
              //     // onTap: () => onPress(2),
              //     behavior: HitTestBehavior.translucent,
              //     child: SizedBox(
              //       width: context.verticalSize(70),
              //       height: context.verticalSize(70),
              //       child: SvgPicture.asset(Assets.googleLogoSVG2),
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }
}
