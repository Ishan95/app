import 'package:app/app/export.dart';
import 'package:app/app/models/mutual_transfer_match_model.dart';
import 'package:app/providers/filtter_provider.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/app/utils/translation_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupMembersScreen extends StatelessWidget {
  final MutualTransferMatch match;

  const GroupMembersScreen({super.key, required this.match});

  Future<void> contactWhatsApp(String phone, String message) async {
    if (!phone.startsWith('+')) {
      phone = '+$phone';
    }
    final encodedMessage = Uri.encodeComponent(message);
    final uriApp = Uri.parse("https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage");
    final uriWeb = Uri.parse("https://wa.me/$phone?text=$encodedMessage");

    try {
      if (await canLaunchUrl(uriApp)) {
        await launchUrl(uriApp, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(uriWeb)) {
        await launchUrl(uriWeb, mode: LaunchMode.platformDefault);
        return;
      }
      print("WhatsApp not available");
    } catch (e) {
      print("Error launching WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = Provider.of<FiltterProvider>(context, listen: false).firebaseUser?.uid;
    final l10n = AppLocalizations.of(context)!;

    var displayCycle = match.cycle.toList();
    if (currentUserId != null) {
      final myIndex = displayCycle.indexWhere((p) => p.uid == currentUserId);
      if (myIndex > 0) {
        displayCycle = [...displayCycle.sublist(myIndex), ...displayCycle.sublist(0, myIndex)];
      }
    }

    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBar(
        title: Text(l10n.groupMembers, style: context.semiBold20(color: ColorManager.blackMedium)),
        backgroundColor: ColorManager.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: ColorManager.blackMedium),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: displayCycle.length,
        itemBuilder: (context, index) {
          final currentPerson = displayCycle[index];
          final nextPerson = displayCycle[(index + 1) % displayCycle.length];

          final isMe = currentPerson.uid == currentUserId;
          final displayName =
              isMe ? "${currentPerson.firstName ?? l10n.unknown} (you)" : (currentPerson.firstName ?? l10n.unknown);

          bool isProvincialTeacher = currentPerson.job == "Provincial School Teacher";
          bool isNationalTeacher = currentPerson.job == "National School Teacher";
          bool isTeacher = isProvincialTeacher || isNationalTeacher;

          String schoolName = "";
          if (isProvincialTeacher) {
            schoolName = currentPerson.school ?? l10n.unknown;
          } else if (isNationalTeacher) {
            schoolName = currentPerson.nationalSchool ?? l10n.unknown;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: isMe ? ColorManager.kPrimary : ColorManager.gray ?? Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: context.bold16(color: ColorManager.blackMedium)),
                  const SizedBox(height: 6),
                  Text(
                    "${l10n.currentPost} ${TranslationService.translate(context, currentPerson.district)}",
                    style: context.regular14(color: ColorManager.grayText ?? Colors.grey.shade700),
                  ),
                  if (isTeacher && schoolName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      "${l10n.schoolLabel}: ${TranslationService.translate(context, schoolName)}",
                      style: context.regular14(color: ColorManager.grayText ?? Colors.grey.shade700),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 18, color: ColorManager.blackMedium),
                      const SizedBox(width: 8),
                      Text(
                        currentPerson.phone ?? l10n.unknown,
                        style: context.semiBold14(color: ColorManager.blackMedium),
                      ),
                    ],
                  ),
                  if (currentPerson.whatsapp != null && currentPerson.whatsapp!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat, size: 18, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child:
                              isMe
                                  ? Text(
                                    currentPerson.whatsapp!,
                                    style: context.semiBold14(color: ColorManager.blackMedium),
                                  )
                                  : InkWell(
                                    onTap: () {
                                      contactWhatsApp(
                                        currentPerson.whatsapp!,
                                        "Hi ${currentPerson.firstName}, I found your profile in a transfer cycle on the app!",
                                      );
                                    },
                                    child: Text(
                                      l10n.chatWithWhatsapp,
                                      style: context
                                          .semiBold14(color: Colors.green)
                                          .copyWith(decoration: TextDecoration.underline),
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 24, thickness: 1),
                  Text(
                    "${l10n.transfersTo} ${TranslationService.translate(context, nextPerson.district)}",
                    style: context.semiBold14(color: ColorManager.kPrimary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
