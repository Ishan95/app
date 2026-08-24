import 'dart:ui';

import 'package:app/app/widgets/info_button.dart';
import 'package:app/app/models/person_details_model.dart';
import 'package:app/screens/notification/widget/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:app/app/export.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/app/utils/translation_service.dart';

class PersonNotificationCard extends StatefulWidget {
  final PersonDetailsModel personDetails;

  const PersonNotificationCard({super.key, required this.personDetails});

  @override
  State<PersonNotificationCard> createState() => _PersonNotificationCardState();
}

class _PersonNotificationCardState extends State<PersonNotificationCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: ColorManager.white,
        border: Border.all(color: ColorManager.lightGray),
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
                                : "${widget.personDetails.firstName} ${widget.personDetails.lastName}",
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
                                      widget.personDetails.institutionTypeForMA?.toShortInstitutionType(),
                                    )
                                    : TranslationService.translate(context, widget.personDetails.institutionTypeForMA),
                                style: context.regular12(color: ColorManager.blackMedium),
                              ),
                            ),
                          ),
                        ],
                      ),
                      isExpanded
                          ? Text(
                            l10n.transactionRequestingDistrict,
                            style: context.regular12(color: ColorManager.grayText),
                            overflow: TextOverflow.visible,
                          )
                          : const SizedBox.shrink(),
                      isExpanded
                          ? Text(
                            "  1. ${TranslationService.translate(context, widget.personDetails.choice1)}${l10n.firstChoiceIndicator}",
                            style: context.semiBold14(color: ColorManager.blackMedium),
                            overflow: TextOverflow.visible,
                          )
                          : const SizedBox.shrink(),
                      isExpanded
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
                              ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: widget.personDetails.isSchoolHide ? 5 : 0,
                                  sigmaY: widget.personDetails.isSchoolHide ? 5 : 0,
                                ),
                                child: Text(
                                  (widget.personDetails.job == "Provincial School Teacher" ||
                                          widget.personDetails.job == "National School Teacher")
                                      ? (widget.personDetails.school?.length ?? 0) > 25
                                          ? TranslationService.translate(
                                            context,
                                            '${widget.personDetails.school?.substring(0, 25)}...',
                                          )
                                          : "${TranslationService.translate(context, widget.personDetails.school) ?? '*****************'}    "
                                      : widget.personDetails.job == "Nurse"
                                      ? (widget.personDetails.officeForNurse?.length ?? 0) > 25
                                          ? TranslationService.translate(
                                            context,
                                            '${widget.personDetails.officeForNurse?.substring(0, 25)}...',
                                          )
                                          : "${TranslationService.translate(context, widget.personDetails.officeForNurse) ?? '*****************'}    "
                                      : (widget.personDetails.officeForMA?.length ?? 0) > 25
                                      ? TranslationService.translate(
                                        context,
                                        '${widget.personDetails.officeForMA?.substring(0, 25)}...',
                                      )
                                      : "${TranslationService.translate(context, widget.personDetails.officeForMA) ?? '*****************'}    ",
                                  style: context.semiBold14(color: ColorManager.blackMedium),
                                  overflow: TextOverflow.visible,
                                ),
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
                              ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: widget.personDetails.isPhoneHide ? 5 : 0,
                                  sigmaY: widget.personDetails.isPhoneHide ? 5 : 0,
                                ),
                                child: Text(
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
                                  child: Text(
                                    widget.personDetails.whatsapp!,
                                    style: context.semiBold14(color: ColorManager.blackMedium),
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
                    GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.translucent,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(Icons.chat, color: ColorManager.kPrimary),
                      ),
                    ),
                  ],
                )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
