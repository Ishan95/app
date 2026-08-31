import 'package:app/app/export.dart';
import 'package:app/app/utils/context_helper.dart';
import 'package:app/providers/account_provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/screens/edit_details/change_password_screen.dart';
import 'package:app/screens/edit_details/edit_details_screen.dart';
import 'package:app/screens/edit_details/edit_payment_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/app/widgets/language_selector.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color dividerColor = const Color(0xffD4D6DD);
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountProvider = Provider.of<AccountProvider>(context, listen: false);
      accountProvider.refreshCurrentUser();
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
    AppLocalizations l10n,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title, textAlign: TextAlign.start, style: context.bold16(color: ColorManager.blackMedium)),
            content: Text(
              content,
              textAlign: TextAlign.start,
              style: context.regular14(color: ColorManager.blackMedium.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel, style: context.semiBold14(color: ColorManager.blackMedium)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmText, style: context.semiBold14(color: ColorManager.red)),
              ),
            ],
          ),
    );
  }

  Future<void> contactWhatsApp(String phone, String message) async {
    if (!phone.startsWith('+')) {
      phone = '+$phone';
    }
    final encodedMessage = Uri.encodeComponent(message);
    final uriApp = Uri.parse("https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage");
    final uriWeb = Uri.parse("https://wa.me/$phone?text=$encodedMessage");

    try {
      if (await canLaunchUrl(uriApp)) {
        print('$uriApp');
        await launchUrl(uriApp, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(uriWeb)) {
        print('$uriWeb');
        await launchUrl(uriWeb, mode: LaunchMode.platformDefault);
        return;
      }
      print("WhatsApp not available");
    } catch (e) {
      print("Error launching WhatsApp: $e");
    }
  }

  Widget _buildProfileRow(String label, Widget valueWidget, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.verticalSize(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: Text(label, style: context.semiBold14(color: ColorManager.grayText))),
          Text(" :  ", style: context.semiBold14(color: ColorManager.blackMedium)),
          Expanded(flex: 6, child: valueWidget),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final accountProvider = Provider.of<AccountProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        SizedBox(
          width: context.screenWidth,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.verticalSize(40)),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Consumer<AccountProvider>(
                          builder: (context, accProvider, child) {
                            final isActive = accProvider.appUser?.isActive ?? true;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isActive ? "Active" : "Inactive",
                                  style: context.semiBold14(
                                    color: isActive ? ColorManager.kPrimary : ColorManager.grayText,
                                  ),
                                ),
                                Switch(
                                  value: isActive,
                                  onChanged: (val) async {
                                    if (accProvider.appUser?.uid != null) {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(accProvider.appUser!.uid)
                                            .update({'isActive': val});
                                        accProvider.refreshCurrentUser();
                                      } catch (e) {
                                        print("Error updating profile status: $e");
                                      }
                                    }
                                  },
                                  activeColor: ColorManager.kPrimary,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(l10n.myProfile, style: context.semiBold20(color: ColorManager.blackMedium)),
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(padding: EdgeInsets.only(right: 15.0), child: LanguageSelector()),
                    ),
                  ],
                ),
                SizedBox(height: context.verticalSize(20)),
                Center(
                  child: ClipOval(
                    child: Icon(Icons.person, size: context.horizontalSize(60), color: ColorManager.kPrimary),
                  ),
                ),
                SizedBox(height: context.verticalSize(20)),
                Padding(
                  padding: context.padding(horizontal: 15),
                  child: Consumer<AccountProvider>(
                    builder: (context, accProvider, child) {
                      if (accProvider.isLoading) {
                        return Center(child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 40));
                      }

                      final user = accProvider.appUser;
                      if (user == null) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileRow(
                            l10n.occupation,
                            Text(user.job ?? "--", style: context.semiBold14(color: ColorManager.blackMedium)),
                            context,
                          ),
                          _buildProfileRow(
                            l10n.name,
                            Text(user.displayName ?? "--", style: context.semiBold14(color: ColorManager.blackMedium)),
                            context,
                          ),
                          _buildProfileRow(
                            l10n.email,
                            Text(user.authEmail ?? "--", style: context.semiBold14(color: ColorManager.blackMedium)),
                            context,
                          ),
                          _buildProfileRow(
                            l10n.phoneLabel,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    user.phone ?? '--',
                                    style: context.semiBold14(color: ColorManager.blackMedium),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (user.isPhoneHide == true && user.phone != null)
                                  Text(l10n.hidden, style: context.semiBold14(color: ColorManager.grayText)),
                              ],
                            ),
                            context,
                          ),
                          _buildProfileRow(
                            l10n.whatsappLabel,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    (user.whatsapp != null && user.whatsapp!.isNotEmpty) ? user.whatsapp! : '--',
                                    style: context.semiBold14(color: ColorManager.blackMedium),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (user.isWhatsappHide == true && user.whatsapp != null && user.whatsapp!.isNotEmpty)
                                  Text(l10n.hidden, style: context.semiBold14(color: ColorManager.grayText)),
                              ],
                            ),
                            context,
                          ),
                          _buildProfileRow(
                            l10n.provinceLabel,
                            Text(user.province ?? "--", style: context.semiBold14(color: ColorManager.blackMedium)),
                            context,
                          ),
                          _buildProfileRow(
                            l10n.districtLabel,
                            Text(user.district ?? "--", style: context.semiBold14(color: ColorManager.blackMedium)),
                            context,
                          ),
                          _buildProfileRow(
                            (user.job == "Provincial School Teacher" || user.job == "National School Teacher")
                                ? l10n.kalapaLabel
                                : user.job == "Police Officer"
                                ? l10n.policeDivisionLabel
                                : user.job == "Grama Niladari"
                                ? l10n.divisionalSecretariatLabel
                                : l10n.institutionLabel,
                            Text(
                              (user.job == "Provincial School Teacher" || user.job == "National School Teacher")
                                  ? user.kalapa ?? "--"
                                  : user.job == "Nurse"
                                  ? user.institutionTypeForNurse ?? "--"
                                  : user.job == "Management Assistant"
                                  ? user.institutionTypeForMA ?? "--"
                                  : user.job == "Police Officer"
                                  ? user.policeDivisions ?? "--"
                                  : user.divisionalSecretariat ?? "--",
                              style: context.semiBold14(color: ColorManager.blackMedium),
                            ),
                            context,
                          ),
                          _buildProfileRow(
                            (user.job == "Provincial School Teacher" || user.job == "National School Teacher")
                                ? l10n.schoolLabel
                                : user.job == "Police Officer"
                                ? l10n.policeStationLabel
                                : l10n.officeLabel,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    user.job == "Provincial School Teacher"
                                        ? user.school ?? '--'
                                        : user.job == "National School Teacher"
                                        ? user.nationalSchool ?? '--'
                                        : user.job == "Nurse"
                                        ? user.officeForNurse ?? '--'
                                        : user.job == "Management Assistant"
                                        ? user.officeForMA ?? '--'
                                        : user.job == "Police Officer"
                                        ? user.policeStations ?? "--"
                                        : (user.gramaNiladhariDivision?.length ?? 0) > 20
                                        ? '${user.gramaNiladhariDivision?.substring(0, 20)}...'
                                        : user.gramaNiladhariDivision ?? "--",
                                    style: context.semiBold14(color: ColorManager.blackMedium),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (user.isSchoolHide == true && user.school != null)
                                  Text(l10n.hidden, style: context.semiBold14(color: ColorManager.grayText)),
                              ],
                            ),
                            context,
                          ),
                          _buildProfileRow(
                            (user.job == "Provincial School Teacher" || user.job == "National School Teacher")
                                ? l10n.schemeLabel
                                : l10n.gradeLabel,
                            Text(
                              (user.job == "Provincial School Teacher" || user.job == "National School Teacher")
                                  ? user.scheme ?? "--"
                                  : user.grade ?? "--",
                              style: context.semiBold14(color: ColorManager.blackMedium),
                            ),
                            context,
                          ),
                          if (user.job == "Provincial School Teacher" || user.job == "National School Teacher")
                            _buildProfileRow(
                              l10n.subjectLabel,
                              Text(
                                (user.subject != null && user.scheme != "PRIMARY") ? user.subject! : "--",
                                style: context.semiBold14(color: ColorManager.blackMedium),
                              ),
                              context,
                            ),
                          if (user.job == "Provincial School Teacher" || user.job == "National School Teacher")
                            _buildProfileRow(
                              l10n.mediumLabel,
                              Text(
                                (user.subjectMedium != null && user.subjectMedium != "") ? user.subjectMedium! : "--",
                                style: context.semiBold14(color: ColorManager.blackMedium),
                              ),
                              context,
                            ),
                          _buildProfileRow(
                            l10n.choice1Label,
                            Text(user.choice1 ?? "--", style: context.semiBold14(color: ColorManager.blackMedium)),
                            context,
                          ),
                          _buildProfileRow(
                            l10n.choice2Label,
                            Text(
                              (user.choice2 != null && user.choice2 != "") ? user.choice2! : "--",
                              style: context.semiBold14(color: ColorManager.blackMedium),
                            ),
                            context,
                          ),
                          _buildProfileRow(
                            l10n.choice3Label,
                            Text(
                              (user.choice3 != null && user.choice3 != "") ? user.choice3! : "--",
                              style: context.semiBold14(color: ColorManager.blackMedium),
                            ),
                            context,
                          ),
                          _buildProfileRow(
                            l10n.noteLabel,
                            Text(
                              (user.note != null && user.note != "") ? user.note! : "--",
                              style: context.semiBold14(color: ColorManager.blackMedium),
                            ),
                            context,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: context.verticalSize(20)),
                _buildListTile(
                  context,
                  titleStyle: context.semiBold14(color: ColorManager.blackMedium),
                  title: l10n.editProfile,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditDetailsScreen()));
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  context,
                  titleStyle: context.semiBold14(color: ColorManager.blackMedium),
                  title: l10n.changePassword,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  context,
                  titleStyle: context.semiBold14(color: ColorManager.blackMedium),
                  title: l10n.helpAndSupport,
                  onTap: () {
                    contactWhatsApp("94713905383", "${l10n.whatsappSupportMessage} #${accountProvider.appUser?.uid}");
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  context,
                  title: l10n.signOut,
                  titleStyle: context.semiBold14(color: ColorManager.blackMedium),
                  onTap: () async {
                    final shouldSave = await _alertDialog(
                      context,
                      l10n.signOutConfirmTitle,
                      l10n.signOutConfirmDesc,
                      l10n.signOut,
                      l10n,
                    );
                    if (shouldSave == true) {
                      await authProvider.signOut();
                    }
                  },
                ),
                _buildDivider(),
                _buildListTile(
                  context,
                  title: l10n.deleteAccount,
                  titleStyle: context.semiBold14(color: ColorManager.redExtra),
                  onTap: () async {
                    final shouldSave = await _alertDialog(
                      context,
                      l10n.deleteAccountConfirmTitle,
                      l10n.deleteAccountConfirmDesc,
                      l10n.delete,
                      l10n,
                    );
                    if (shouldSave == true) {
                      await authProvider.deleteAccount(ContextHelper.navigatorKey.currentContext!);
                    }
                  },
                ),
                _buildDivider(),

                SizedBox(height: context.verticalSize(40)),
                Center(
                  child: Text('${l10n.version} $_version', style: context.semiBold14(color: ColorManager.grayText)),
                ),
                SizedBox(height: context.verticalSize(150)),
              ],
            ),
          ),
        ),

        if (authProvider.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 50.0)),
            ),
          ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    TextStyle? titleStyle,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 16),
      title: Text(title, style: titleStyle ?? context.semiBold14(color: ColorManager.blackMedium)),
      trailing: trailingWidget ?? const Icon(Icons.arrow_forward_ios, color: Color(0xff8F9098), size: 12),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(color: dividerColor, thickness: 2, height: 0.2);
  }
}
