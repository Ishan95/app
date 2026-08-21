import 'package:app/app/export.dart';
import 'package:app/app/utils/context_helper.dart';
import 'package:app/providers/account_provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/screens/edit_details/change_password_screen.dart';
import 'package:app/screens/edit_details/edit_details_screen.dart';
import 'package:app/screens/edit_details/edit_payment_details_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color dividerColor = const Color(0xffD4D6DD);
  // final accProvider = Provider.of<AccountProvider>(
  //   ContextHelper.navigatorKey.currentContext!,
  //   listen: false,
  // );
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    // Fetch users when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);

      accountProvider.refreshCurrentUser();
      // accProvider;
    });
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
    });
  }

  Future<bool?> _alertDialog(
    BuildContext context,
    String title,
    String content,
    String confirmText,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              textAlign: TextAlign.start,
              style: context.bold16(color: ColorManager.black),
            ),
            content: Text(
              content,
              textAlign: TextAlign.start,
              style: context.regular14(
                color: ColorManager.black.withOpacity(0.8),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: context.semiBold14(color: ColorManager.black),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  confirmText,
                  style: context.semiBold14(color: ColorManager.red),
                ),
              ),
            ],
          ),
    );
  }

// Future<void> launchWhatsApp({
//   required String phone,
//   String message = "",
// }) async {
//   final messageEncoded = Uri.encodeComponent(message);

//   // Try launching the native WhatsApp app
//   final whatsappUri = Uri.parse("whatsapp://send?phone=$phone&text=$messageEncoded");

//   if (await canLaunchUrl(whatsappUri)) {
//     await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
//   } else {
//     // Fallback to WhatsApp Web
//     final fallbackUri = Uri.parse("https://wa.me/$phone?text=$messageEncoded");
//     if (await canLaunchUrl(fallbackUri)) {
//       await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
//     } else {
//       print("Could not launch WhatsApp.");
//     }
//   }
// }

Future<void> contactWhatsApp(String phone, String message) async {
  // Ensure the phone number is in E.164 format
  if (!phone.startsWith('+')) {
    phone = '+$phone'; // Add '+' if missing
  }

  // Encode the message
  final encodedMessage = Uri.encodeComponent(message);

  // Create WhatsApp URLs
  // final uriApp = Uri.parse("whatsapp://send?phone=$phone&text=$encodedMessage");
  final uriApp = Uri.parse("https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage");
  final uriWeb = Uri.parse("https://wa.me/$phone?text=$encodedMessage");

  try {
    // 1. Try opening the WhatsApp app
    if (await canLaunchUrl(uriApp)) {
      print('$uriApp');
      await launchUrl(uriApp, mode: LaunchMode.externalApplication);
      return;
    }

    // 2. Fallback to WhatsApp Web
    if (await canLaunchUrl(uriWeb)) {
      print('$uriWeb');
      await launchUrl(uriWeb, mode: LaunchMode.platformDefault); // For iOS
      return;
    }

    // 3. If both fail, print an error
    print("WhatsApp not available");
  } catch (e) {
    print("Error launching WhatsApp: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final accountProvider = Provider.of<AccountProvider>(context);
    return SizedBox(
      width: context.screenWidth,
      // height: context.screenHeight - 10.0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.verticalSize(40)),
            Center(
              child: Text(
                'My Profile',
                style: context.semiBold20(color: Colors.white),
              ),
            ),
            SizedBox(height: context.verticalSize(20)),
            Center(
              child: ClipOval(
                child: Icon(
                  Icons.person,
                  size: context.horizontalSize(60),
                  color: ColorManager.white,
                ),
              ),
            ),
            SizedBox(height: context.verticalSize(20)),
            Padding(
              padding: context.padding(horizontal: 15),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Occupation",
                        style: context.semiBold14(color: ColorManager.white),
                      ),
                      SizedBox(height: context.verticalSize(10)),
                      Text(
                        "Name",
                        style: context.semiBold14(color: ColorManager.white),
                      ),
                      SizedBox(height: context.verticalSize(10)),
                      Text(
                        "Email",
                        style: context.semiBold14(color: ColorManager.white),
                      ),
                      SizedBox(height: context.verticalSize(10)),
                      Text(
                        "Phone",
                        style: context.semiBold14(color: ColorManager.white),
                      ),
                      SizedBox(height: context.verticalSize(10)),
                      Text(
                        "Province",
                        style: context.semiBold14(color: ColorManager.white),
                      ),

                      SizedBox(height: context.verticalSize(10)),
                      Text(
                        "District",
                        style: context.semiBold14(color: ColorManager.white),
                      ),
                      SizedBox(height: context.verticalSize(10)),
                      Text(
                        (accountProvider.appUser?.job == "Provincial School Teacher" || accountProvider.appUser?.job == "National School Teacher") ? "kalapa" : accountProvider.appUser?.job == "Police Officer" ? "Police Division" : accountProvider.appUser?.job == "Grama Niladari" ? "D. Secretariat" : "Institution",
                        style: context.semiBold14(color: ColorManager.white),
                      ),
                      SizedBox(height: context.verticalSize(10)),
                      Text(
                        (accountProvider.appUser?.job == "Provincial School Teacher" || accountProvider.appUser?.job == "National School Teacher") ? "School" : accountProvider.appUser?.job == "Police Officer" ? "Police Station" : "Office",
                        style: context.semiBold14(color: ColorManager.white),
                      ),
                      SizedBox(height: context.verticalSize(10)),
                      (accountProvider.appUser?.job == "Provincial School Teacher" || accountProvider.appUser?.job == "National School Teacher") ? Text(
                        "scheme",
                        style: context.semiBold14(color: ColorManager.white),
                      ) : 
                      Text(
                        "grade",
                        style: context.semiBold14(color: ColorManager.white),
                      ),
                      SizedBox(height: context.verticalSize((accountProvider.appUser?.job == "Provincial School Teacher" || accountProvider.appUser?.job == "National School Teacher") ? 10 : 0)),
                      (accountProvider.appUser?.job == "Provincial School Teacher" || accountProvider.appUser?.job == "National School Teacher") ? Text(
                        "Subject",
                        style: context.semiBold14(color: ColorManager.white),
                      ) : SizedBox.shrink(),
                      SizedBox(height: context.verticalSize(10)),
                      Text(
                        "Choice 1",
                        style: context.semiBold14(color: ColorManager.white),
                      ),
                      SizedBox(height: context.verticalSize(10)),
                      Text(
                        "Choice 2",
                        style: context.semiBold14(color: ColorManager.white),
                      ),
                      SizedBox(height: context.verticalSize(10)),
                      Text(
                        "Choice 3",
                        style: context.semiBold14(color: ColorManager.white),
                      ),
                      SizedBox(height: context.verticalSize(10)),
                      Text(
                        "Note",
                        style: context.semiBold14(color: ColorManager.white),
                      ),

                      // SizedBox(height: context.verticalSize(40)),
                      // Text(
                      //   "Transfer Date",
                      //   style: context.semiBold14(color: ColorManager.white),
                      // ),
                      // SizedBox(height: context.verticalSize(10)),
                      // Text(
                      //   "Ref No",
                      //   style: context.semiBold14(color: ColorManager.white),
                      // ),
                      // SizedBox(height: context.verticalSize(10)),
                      // Text(
                      //   "Acc Number",
                      //   style: context.semiBold14(color: ColorManager.white),
                      // ),
                      // SizedBox(height: context.verticalSize(10)),
                      // Text(
                      //   "Client name",
                      //   style: context.semiBold14(color: ColorManager.white),
                      // ),
                      // SizedBox(height: context.verticalSize(10)),
                      // Text(
                      //   "Amount",
                      //   style: context.semiBold14(color: ColorManager.white),
                      // ),
                      // SizedBox(height: context.verticalSize(10)),
                      // Text(
                      //   "Service Provi.",
                      //   style: context.semiBold14(color: ColorManager.white),
                      // ),
                      // SizedBox(height: context.verticalSize(10)),
                      // Text(
                      //   "IsEnable",
                      //   style: context.semiBold14(color: ColorManager.white),
                      // ),
                      // SizedBox(height: context.verticalSize(10)),
                      // Text(
                      //   "Photo",
                      //   style: context.semiBold14(color: ColorManager.white),
                      // ),
                    ],
                  ),
                  Consumer<AccountProvider>(
                    builder: (context, accProvider, child) {
                      if (accProvider.isLoading) {
                        return Expanded(
                          child: Center(
                            child: SpinKitFadingCircle(
                              color: ColorManager.kPrimary,
                              size: 40,
                            ),
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            " :  ${accProvider.appUser?.job ?? "--"}",
                            style: context.semiBold14(
                              color: ColorManager.white,
                            ),
                          ),
                          SizedBox(height: context.verticalSize(10)),
                          Text(
                            // filter.appUser != null ? ' :  ${filter.appUser!.name}' : ' :  --',
                            " :  ${accProvider.appUser?.displayName ?? "--"}",
                            style: context.semiBold14(
                              color: ColorManager.white,
                            ),
                          ),
                          SizedBox(height: context.verticalSize(10)),
                          Text(
                            " :  ${accProvider.appUser?.authEmail ?? "--"}",
                            style: context.semiBold14(
                              color: ColorManager.white,
                            ),
                          ),
                          SizedBox(height: context.verticalSize(10)),
                          SizedBox(
                            width: context.screenWidth * 0.65,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    " :  ${accProvider.appUser?.phone ?? '--'}",
                                    style: context.semiBold14(
                                      color: ColorManager.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  (accProvider.appUser?.isPhoneHide == true &&
                                          accProvider.appUser?.phone != null)
                                      ? '(Hidden)'
                                      : '',
                                  style: context.semiBold14(
                                    color: ColorManager.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: context.verticalSize(10)),
                          Text(
                            " :  ${accProvider.appUser?.province ?? "--"}",
                            style: context.semiBold14(
                              color: ColorManager.white,
                            ),
                          ),
                          SizedBox(height: context.verticalSize(10)),
                          Text(
                            " :  ${accProvider.appUser?.district ?? "--"}",
                            style: context.semiBold14(
                              color: ColorManager.white,
                            ),
                          ),
                          SizedBox(height: context.verticalSize(10)),
                          Text(
                            " :  ${(accountProvider.appUser?.job == "Provincial School Teacher" || accountProvider.appUser?.job == "National School Teacher") ? accProvider.appUser?.kalapa ?? "--" : accountProvider.appUser?.job == "Nurse" ? accProvider.appUser?.institutionTypeForNurse ?? "--" : accountProvider.appUser?.job == "Management Assistant" ? accProvider.appUser?.institutionTypeForMA ?? "--" : accountProvider.appUser?.job == "Police Officer" ? accProvider.appUser?.policeDivisions ?? "--" : accProvider.appUser?.divisionalSecretariat ?? "--"}",
                            style: context.semiBold14(
                              color: ColorManager.white,
                            ),
                          ),
                          SizedBox(height: context.verticalSize(10)),
                          SizedBox(
                            width: context.screenWidth * 0.65,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    " :  ${accountProvider.appUser?.job == "Provincial School Teacher" ? accProvider.appUser?.school ?? '--' : accountProvider.appUser?.job == "National School Teacher" ? accProvider.appUser?.nationalSchool ?? '--' : accountProvider.appUser?.job == "Nurse" ? accProvider.appUser?.officeForNurse ?? '--' : accountProvider.appUser?.job == "Management Assistant" ? accProvider.appUser?.officeForMA ?? '--' : accountProvider.appUser?.job == "Police Officer" ? accProvider.appUser?.policeStations ?? "--" : (accProvider.appUser?.gramaNiladhariDivision?.length ?? 0) > 20 ? '${accProvider.appUser?.gramaNiladhariDivision?.substring(0, 20)}...' : accProvider.appUser?.gramaNiladhariDivision ?? "--"}",
                                    style: context.semiBold14(
                                      color: ColorManager.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  (accProvider.appUser?.isSchoolHide == true &&
                                          accProvider.appUser?.school != null)
                                      ? '(Hidden)'
                                      : '',
                                  style: context.semiBold14(
                                    color: ColorManager.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: context.verticalSize(10)),
                          (accountProvider.appUser?.job == "Provincial School Teacher" || accountProvider.appUser?.job == "National School Teacher") ? Text(
                            " :  ${accProvider.appUser?.scheme ?? "--"}",
                            style: context.semiBold14(
                              color: ColorManager.white,
                            ),
                          ) : Text(
                            " :  ${accProvider.appUser?.grade ?? "--"}",
                            style: context.semiBold14(
                              color: ColorManager.white,
                            ),
                          ),
                          SizedBox(height: context.verticalSize((accountProvider.appUser?.job == "Provincial School Teacher" || accountProvider.appUser?.job == "National School Teacher") ? 10 : 0)),
                          (accountProvider.appUser?.job == "Provincial School Teacher" || accountProvider.appUser?.job == "National School Teacher") ? Text(
                            " :  ${(accProvider.appUser?.subject != null && accProvider.appUser?.scheme != "PRIMARY") ? accProvider.appUser?.subject : "--"}",
                            style: context.semiBold14(
                              color: ColorManager.white,
                            ),
                          ) : SizedBox.shrink(),
                          SizedBox(height: context.verticalSize(10)),
                          Text(
                            " :  ${accProvider.appUser?.choice1 ?? "--"}",
                            style: context.semiBold14(
                              color: ColorManager.white,
                            ),
                          ),
                          SizedBox(height: context.verticalSize(10)),
                          Text(
                            " :  ${(accProvider.appUser?.choice2 != null && accProvider.appUser?.choice2 != "") ? accProvider.appUser?.choice2 : "--"}",
                            style: context.semiBold14(
                              color: ColorManager.white,
                            ),
                          ),
                          SizedBox(height: context.verticalSize(10)),
                          Text(
                            " :  ${(accProvider.appUser?.choice3 != null && accProvider.appUser?.choice3 != "") ? accProvider.appUser?.choice3 : "--"}",
                            style: context.semiBold14(
                              color: ColorManager.white,
                            ),
                          ),
                          SizedBox(height: context.verticalSize(10)),
                          Text(
                            " :  ${accProvider.appUser?.note ?? "--"}",
                            style: context.semiBold14(
                              color: ColorManager.white,
                            ),
                          ),

                          // SizedBox(height: context.verticalSize(40)),
                          // Text(
                          //   " :  ${accProvider.appUser?.transferDate ?? "--"}",
                          //   style: context.semiBold14(
                          //     color: ColorManager.white,
                          //   ),
                          // ),
                          // SizedBox(height: context.verticalSize(10)),
                          // Text(
                          //   " :  ${accProvider.appUser?.refNo ?? "--"}",
                          //   style: context.semiBold14(
                          //     color: ColorManager.white,
                          //   ),
                          // ),
                          // SizedBox(height: context.verticalSize(10)),
                          // Text(
                          //   " :  ${accProvider.appUser?.accountNo ?? "--"}",
                          //   style: context.semiBold14(
                          //     color: ColorManager.white,
                          //   ),
                          // ),
                          // SizedBox(height: context.verticalSize(10)),
                          // Text(
                          //   " :  ${accProvider.appUser?.clientName ?? "--"}",
                          //   style: context.semiBold14(
                          //     color: ColorManager.white,
                          //   ),
                          // ),
                          // SizedBox(height: context.verticalSize(10)),
                          // Text(
                          //   " :  ${accProvider.appUser?.amount ?? "--"}",
                          //   style: context.semiBold14(
                          //     color: ColorManager.white,
                          //   ),
                          // ),
                          // SizedBox(height: context.verticalSize(10)),
                          // Text(
                          //   " :  ${accProvider.appUser?.serviceProvider ?? "--"}",
                          //   style: context.semiBold14(
                          //     color: ColorManager.white,
                          //   ),
                          // ),
                          // SizedBox(height: context.verticalSize(10)),
                          // Text(
                          //   " :  ${accProvider.appUser?.isEnable ?? "--"}",
                          //   style: context.semiBold14(
                          //     color: ColorManager.white,
                          //   ),
                          // ),
                          // SizedBox(height: context.verticalSize(10)),
                          // Text(
                          //   " :",
                          //   style: context.semiBold14(
                          //     color: ColorManager.white,
                          //   ),
                          // ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: context.verticalSize(20)),
            SizedBox(height: context.verticalSize(20)),
            _buildListTile(
              context,
              titleStyle: context.semiBold14(color: ColorManager.white),
              title: 'Edit profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditDetailsScreen()),
                );
              },
            ),
            _buildDivider(),
            // _buildListTile(
            //   context,
            //   titleStyle: context.semiBold14(color: ColorManager.white),
            //   title: 'Edit Payment Details',
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => EditPaymentDetailsScreen(),
            //       ),
            //     );
            //   },
            // ),
            _buildDivider(),
            _buildListTile(
              context,
              titleStyle: context.semiBold14(color: ColorManager.white),
              title: 'Change Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordScreen(),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildListTile(
              context,
              titleStyle: context.semiBold14(color: ColorManager.white),
              title: 'Help and Support',
              onTap: () {
                contactWhatsApp(
                  "94713905383",
                  "Hello, I need assistance with my account. #${accountProvider.appUser?.uid}",
                );
              },
            ),
            _buildDivider(),
            _buildListTile(
              context,
              // iconPath: 'assets/images/profile/exit.png',
              title: 'Sign out',
              titleStyle: context.semiBold14(color: ColorManager.white),
              onTap: () async {
                final shouldSave = await _alertDialog(
                  context,
                  'Sign out?',
                  'This will sign you out of the application and reset all your data.',
                  'Sign out',
                );
                if (shouldSave == true) {
                  await authProvider.signOut();
                } else {}
              },
            ),
            _buildDivider(),
            _buildListTile(
              context,
              // iconPath: 'assets/images/profile/exit.png',
              title: 'Delete account',
              titleStyle: context.semiBold14(color: ColorManager.redExtra),
              onTap: () async {
                final shouldSave = await _alertDialog(
                  context,
                  'Delect account?',
                  'This will permanently delete your account and all associated data. This action cannot be undone.',
                  'Delect',
                );
                if (shouldSave == true) {
                  await authProvider.deleteAccount(
                    ContextHelper.navigatorKey.currentContext!,
                  );
                } else {}
              },
            ),
            _buildDivider(),

            SizedBox(height: context.verticalSize(40)),
            Center(
              child: Text(
                'VERSION $_version',
                style: context.semiBold14(color: ColorManager.white),
              ),
            ),
            SizedBox(height: context.verticalSize(150)),

            // ElevatedButton(
            //   onPressed: () {
            //     FirebaseCrashlytics.instance.crash(); // Forces a crash
            //   },
            //   child: const Text('Crash App'),
            // ),
            // ElevatedButton(
            //   onPressed: () {
            //     throw Exception(
            //       'This is a test non-fatal error!',
            //     ); // Throws a non-fatal error
            //   },
            //   child: const Text('Throw Non-Fatal Error'),
            // ),
            // SizedBox(height: context.verticalSize(150)),
          ],
        ),
      ),
      // List Items
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    // required String iconPath,
    required String title,
    TextStyle? titleStyle,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
      // leading: Image.asset(
      //   iconPath,
      //   width: 20,
      //   height: 20,
      // ),
      title: Text(
        title,
        style: titleStyle ?? context.semiBold14(color: ColorManager.black),
      ),
      trailing:
          trailingWidget ??
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xff8F9098),
            size: 12,
          ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(color: dividerColor, thickness: 0.5, height: 0.2);
  }
}
