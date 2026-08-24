import 'dart:ui';

import 'package:app/app/models/chat/contact.dart';
import 'package:app/app/widgets/info_button.dart';
import 'package:app/app/models/person_details_model.dart';
import 'package:app/providers/filtter_provider.dart';
import 'package:app/screens/chat/message_screen.dart';
import 'package:app/screens/notification/widget/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:app/app/export.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/app/utils/translation_service.dart';

class PersonCard extends StatefulWidget {
  final PersonDetailsModel personDetails;
  final String page;

  const PersonCard({super.key, required this.personDetails, this.page = 'home'});

  @override
  State<PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {
  bool isExpanded = false;

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
    final FiltterProvider filterProvider = Provider.of<FiltterProvider>(context, listen: false);
    final String? currentUserId = filterProvider.firebaseUser?.uid;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: ColorManager.white,
        border: Border.all(
          color: widget.personDetails.uid != currentUserId ? ColorManager.lightGray : ColorManager.kPrimary,
          width: 2.0,
        ), // Updated borders
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: context.horizontalSize(60),
                  height: context.horizontalSize(60),
                  child: ClipOval(
                    child: Container(
                      color: ColorManager.whiteddd,
                      child: Icon(Icons.person, size: context.horizontalSize(40), color: ColorManager.grayText),
                    ),
                  ),
                ),
                SizedBox(width: context.horizontalSize(8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            (widget.personDetails.firstName?.length ?? 0) > 20
                                ? '${widget.personDetails.firstName?.substring(0, 20)}...'
                                : "${widget.personDetails.firstName} ${widget.personDetails.lastName ?? ""}",
                            style: context.bold16(color: ColorManager.blackMedium),
                          ),
                          Text(
                            TranslationService.translate(context, widget.personDetails.district),
                            style: context.regular12(color: ColorManager.grayText),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            color: ColorManager.whiteddd,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                (widget.personDetails.job == "Provincial School Teacher" ||
                                        widget.personDetails.job == "National School Teacher")
                                    ? (widget.personDetails.scheme == "PRIMARY")
                                        ? l10n.primary
                                        : (widget.personDetails.subject?.length ?? 0) > 35
                                        ? TranslationService.translate(
                                          context,
                                          '${widget.personDetails.subject?.substring(0, 35)}...',
                                        )
                                        : TranslationService.translate(context, widget.personDetails.subject)
                                    : TranslationService.translate(context, widget.personDetails.grade),
                                style: context.regular12(color: ColorManager.blackMedium),
                              ),
                            ),
                          ),
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            color: ColorManager.whiteddd,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                (widget.personDetails.job == "Provincial School Teacher" ||
                                        widget.personDetails.job == "National School Teacher")
                                    ? TranslationService.translate(context, widget.personDetails.scheme)
                                    : widget.personDetails.job == "Nurse"
                                    ? TranslationService.translate(
                                      context,
                                      widget.personDetails.institutionTypeForNurse?.toShortInstitutionType(),
                                    )
                                    : widget.personDetails.job == "Management Assistant"
                                    ? TranslationService.translate(
                                      context,
                                      widget.personDetails.institutionTypeForMA?.toShortInstitutionTypeForMA(),
                                    )
                                    : widget.personDetails.job == "Police Officer"
                                    ? TranslationService.translate(context, widget.personDetails.policeDivisions)
                                    : TranslationService.translate(context, widget.personDetails.divisionalSecretariat),
                                style: context.regular12(color: ColorManager.blackMedium),
                              ),
                            ),
                          ),
                        ],
                      ),
                      (widget.page == 'home' || isExpanded)
                          ? Text(
                            l10n.transactionRequestingDistrict,
                            style: context.regular12(color: ColorManager.grayText),
                            overflow: TextOverflow.visible,
                          )
                          : const SizedBox.shrink(),
                      (widget.page == 'home' || isExpanded)
                          ? Text(
                            "  1. ${TranslationService.translate(context, widget.personDetails.choice1)}${l10n.firstChoiceIndicator}",
                            style: context.semiBold14(color: ColorManager.blackMedium),
                            overflow: TextOverflow.visible,
                          )
                          : const SizedBox.shrink(),
                      ((widget.page == 'home' || isExpanded) && widget.personDetails.choice2 != "")
                          ? Text(
                            "  2. ${TranslationService.translate(context, widget.personDetails.choice2)},  ${TranslationService.translate(context, widget.personDetails.choice3)}${l10n.secondThirdChoiceIndicator}",
                            style: context.regular12(color: ColorManager.blackMedium),
                            overflow: TextOverflow.visible,
                          )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: context.verticalSize(14)),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: CircleAvatar(
                  backgroundColor: ColorManager.whiteddd,
                  radius: 12,
                  child: Icon(
                    isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down_circle,
                    color: ColorManager.kPrimary,
                    size: 22,
                  ),
                ),
              ),
            ),
            SizedBox(height: context.verticalSize(isExpanded ? 14 : 0)),
            isExpanded
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "   ${(widget.personDetails.job == "Provincial School Teacher" || widget.personDetails.job == "National School Teacher") ? l10n.schoolLabel : l10n.officeLabel} :  ",
                                style: context.semiBold14(color: ColorManager.grayText),
                              ),
                              widget.personDetails.uid != currentUserId
                                  ? ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                      sigmaX: widget.personDetails.isSchoolHide ? 5 : 0,
                                      sigmaY: widget.personDetails.isSchoolHide ? 5 : 0,
                                    ),
                                    child: Text(
                                      widget.personDetails.job == "Provincial School Teacher"
                                          ? (widget.personDetails.school?.length ?? 0) > 28
                                              ? TranslationService.translate(
                                                context,
                                                '${widget.personDetails.school?.substring(0, 28)}...',
                                              )
                                              : "${TranslationService.translate(context, widget.personDetails.school) ?? '*****************'}    "
                                          : widget.personDetails.job == "National School Teacher"
                                          ? (widget.personDetails.nationalSchool?.length ?? 0) > 28
                                              ? TranslationService.translate(
                                                context,
                                                '${widget.personDetails.nationalSchool?.substring(0, 28)}...',
                                              )
                                              : "${TranslationService.translate(context, widget.personDetails.nationalSchool) ?? '*****************'}    "
                                          : widget.personDetails.job == "Nurse"
                                          ? (widget.personDetails.officeForNurse?.length ?? 0) > 28
                                              ? TranslationService.translate(
                                                context,
                                                '${widget.personDetails.officeForNurse?.substring(0, 28)}...',
                                              )
                                              : "${TranslationService.translate(context, widget.personDetails.officeForNurse) ?? '*****************'}    "
                                          : widget.personDetails.job == "Management Assistant"
                                          ? (widget.personDetails.officeForMA?.length ?? 0) > 28
                                              ? TranslationService.translate(
                                                context,
                                                '${widget.personDetails.officeForMA?.substring(0, 28)}...',
                                              )
                                              : "${TranslationService.translate(context, widget.personDetails.officeForMA) ?? '*****************'}    "
                                          : widget.personDetails.job == "Police Officer"
                                          ? (widget.personDetails.policeStations?.length ?? 0) > 28
                                              ? TranslationService.translate(
                                                context,
                                                '${widget.personDetails.policeStations?.substring(0, 28)}...',
                                              )
                                              : "${TranslationService.translate(context, widget.personDetails.policeStations) ?? '*****************'}    "
                                          : (widget.personDetails.gramaNiladhariDivision?.length ?? 0) > 28
                                          ? TranslationService.translate(
                                            context,
                                            '${widget.personDetails.gramaNiladhariDivision?.substring(0, 28)}...',
                                          )
                                          : "${TranslationService.translate(context, widget.personDetails.gramaNiladhariDivision) ?? '*****************'}    ",
                                      style: context.semiBold14(color: ColorManager.blackMedium),
                                      overflow: TextOverflow.visible,
                                    ),
                                  )
                                  : Text(
                                    widget.personDetails.job == "Provincial School Teacher"
                                        ? (widget.personDetails.school?.length ?? 0) > 30
                                            ? TranslationService.translate(
                                              context,
                                              '${widget.personDetails.school?.substring(0, 30)}...',
                                            )
                                            : "${TranslationService.translate(context, widget.personDetails.school) ?? '*****************'}    "
                                        : widget.personDetails.job == "National School Teacher"
                                        ? (widget.personDetails.nationalSchool?.length ?? 0) > 30
                                            ? TranslationService.translate(
                                              context,
                                              '${widget.personDetails.nationalSchool?.substring(0, 30)}...',
                                            )
                                            : "${TranslationService.translate(context, widget.personDetails.nationalSchool) ?? '*****************'}    "
                                        : widget.personDetails.job == "Nurse"
                                        ? (widget.personDetails.officeForNurse?.length ?? 0) > 30
                                            ? TranslationService.translate(
                                              context,
                                              '${widget.personDetails.officeForNurse?.substring(0, 30)}...',
                                            )
                                            : "${TranslationService.translate(context, widget.personDetails.officeForNurse) ?? '*****************'}    "
                                        : widget.personDetails.job == "Management Assistant"
                                        ? (widget.personDetails.officeForMA?.length ?? 0) > 30
                                            ? TranslationService.translate(
                                              context,
                                              '${widget.personDetails.officeForMA?.substring(0, 30)}...',
                                            )
                                            : "${TranslationService.translate(context, widget.personDetails.officeForMA) ?? '*****************'}    "
                                        : widget.personDetails.job == "Police Officer"
                                        ? (widget.personDetails.policeStations?.length ?? 0) > 30
                                            ? TranslationService.translate(
                                              context,
                                              '${widget.personDetails.policeStations?.substring(0, 30)}...',
                                            )
                                            : "${TranslationService.translate(context, widget.personDetails.policeStations) ?? '*****************'}    "
                                        : (widget.personDetails.gramaNiladhariDivision?.length ?? 0) > 30
                                        ? TranslationService.translate(
                                          context,
                                          '${widget.personDetails.gramaNiladhariDivision?.substring(0, 30)}...',
                                        )
                                        : "${TranslationService.translate(context, widget.personDetails.gramaNiladhariDivision) ?? '*****************'}    ",
                                    style: context.semiBold14(color: ColorManager.blackMedium),
                                    overflow: TextOverflow.visible,
                                  ),
                              widget.personDetails.isSchoolHide
                                  ? Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    child: InfoButtonWithTooltip(
                                      tooltipText: l10n.contentHiddenTooltip,
                                      child: Icon(Icons.visibility_off, color: ColorManager.grayText, size: 16),
                                    ),
                                  )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                          SizedBox(height: context.verticalSize(5)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.contactIndicator, style: context.semiBold14(color: ColorManager.grayText)),
                              Expanded(
                                child:
                                    widget.personDetails.uid != currentUserId
                                        ? ImageFiltered(
                                          imageFilter: ImageFilter.blur(
                                            sigmaX: widget.personDetails.isPhoneHide ? 5 : 0,
                                            sigmaY: widget.personDetails.isPhoneHide ? 5 : 0,
                                          ),
                                          child: Text(
                                            "${widget.personDetails.phone ?? '07********'}    ",
                                            style: context.semiBold14(color: ColorManager.blackMedium),
                                            overflow: TextOverflow.visible,
                                          ),
                                        )
                                        : Text(
                                          "${widget.personDetails.phone ?? '07********'}    ",
                                          style: context.semiBold14(color: ColorManager.blackMedium),
                                          overflow: TextOverflow.visible,
                                        ),
                              ),
                              widget.personDetails.isPhoneHide
                                  ? Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    child: InfoButtonWithTooltip(
                                      tooltipText: l10n.contentHiddenTooltip,
                                      child: Icon(Icons.visibility_off, color: ColorManager.grayText, size: 16),
                                    ),
                                  )
                                  : const SizedBox.shrink(),
                            ],
                          ),

                          // SEPARATED WHATSAPP ROW
                          if (widget.personDetails.whatsapp != null && widget.personDetails.whatsapp!.isNotEmpty)
                            SizedBox(height: context.verticalSize(5)),
                          if (widget.personDetails.whatsapp != null && widget.personDetails.whatsapp!.isNotEmpty)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "   ${l10n.whatsappIndicator}",
                                  style: context.semiBold14(color: ColorManager.grayText),
                                ),
                                Expanded(
                                  child:
                                      widget.personDetails.uid == currentUserId
                                          ? Text(
                                            widget.personDetails.whatsapp!,
                                            style: context.semiBold14(color: ColorManager.blackMedium),
                                          )
                                          : InkWell(
                                            onTap: () {
                                              contactWhatsApp(
                                                widget.personDetails.whatsapp!,
                                                "Hi ${widget.personDetails.firstName}, I found your profile on the transfer app!",
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

                          SizedBox(height: context.verticalSize(5)),
                          widget.personDetails.note != ""
                              ? Text(
                                " * ${widget.personDetails.note}",
                                style: context.regular12(color: ColorManager.grayText),
                                overflow: TextOverflow.visible,
                              )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    (widget.personDetails.uid != currentUserId && widget.personDetails.uid != "")
                        ? GestureDetector(
                          onTap: () {
                            print("user Uid: ${widget.personDetails.uid}");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MessageScreen(
                                      contact: Contact(
                                        id: widget.personDetails.uid,
                                        name: '${widget.personDetails.firstName}',
                                        role: 'Friend',
                                        status: 'online',
                                      ),
                                    ),
                              ),
                            );
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Icon(Icons.chat, color: ColorManager.kPrimary),
                          ),
                        )
                        : const SizedBox(),
                  ],
                )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
