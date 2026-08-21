import 'dart:ui';

import 'package:app/app/widgets/info_button.dart';
import 'package:app/app/models/person_details_model.dart';
import 'package:app/screens/notification/widget/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:app/app/export.dart';

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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorManager.white),
        borderRadius: BorderRadius.circular(15.0),
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
                    child: Icon(
                      Icons.person,
                      size: context.horizontalSize(60),
                      color: ColorManager.white,
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
                            (widget.personDetails.firstName?.length ?? 0) > 20 ? '${widget.personDetails.firstName?.substring(0, 20)}...' : "${widget.personDetails.firstName} ${widget.personDetails.lastName}",
                            style: context.bold16(color: ColorManager.white),
                          ),
                          Text(
                            "${widget.personDetails.district}",
                            style: context.regular12(color: ColorManager.white),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: ColorManager.white10,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                (widget.personDetails.job == "Provincial School Teacher" || widget.personDetails.job == "National School Teacher") ? (widget.personDetails.scheme == "PRIMARY")
                                        ? "Primary"
                                        : (widget.personDetails.subject?.length ?? 0) > 35 ? '${widget.personDetails.subject?.substring(0, 35)}...' : widget.personDetails.subject ?? "" : "${widget.personDetails.grade}",
                                style: context.regular12(
                                  color: ColorManager.white,
                                ),
                              ),
                            ),
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: ColorManager.white10,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                (widget.personDetails.job == "Provincial School Teacher" || widget.personDetails.job == "National School Teacher") ? "${widget.personDetails.scheme}" : widget.personDetails.job == "Nurse" ? "${widget.personDetails.institutionTypeForNurse?.toShortInstitutionType()}" : widget.personDetails.job == "Management Assistant" ? "${widget.personDetails.institutionTypeForMA?.toShortInstitutionType()}" : "${widget.personDetails.institutionTypeForMA}",
                                style: context.regular12(
                                  color: ColorManager.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      isExpanded ? Text(
                        "Transaction Requesting for(District) -",
                        style: context.regular12(color: ColorManager.white),
                        overflow: TextOverflow.visible,
                      ) : SizedBox.shrink(),
                      isExpanded ?
                      Text(
                        "  1. ${widget.personDetails.choice1} (1st Choice)",
                        style: context.semiBold14(color: ColorManager.white),
                        overflow: TextOverflow.visible,
                      ) : SizedBox.shrink(),
                      isExpanded ?
                      Text(
                        "  2. ${widget.personDetails.choice2},  ${widget.personDetails.choice3} (2nd & 3rd Choice)",
                        style: context.regular12(color: ColorManager.white),
                        overflow: TextOverflow.visible,
                      ) : SizedBox.shrink(),
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
                  backgroundColor: ColorManager.greenPrimary.withOpacity(0.8),
                  // radius: 20,
                  radius: 12,
                  child: Icon(
                    // Icons.filter_list,
                    isExpanded
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down_circle,
                    color: ColorManager.kPrimaryBlack,
                    size: 22,
                  ),
                ),
              ),
            ),
            SizedBox(height: context.verticalSize(isExpanded ? 14 : 0)),
            isExpanded
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                               "   ${(widget.personDetails.job == "Provincial School Teacher" || widget.personDetails.job == "National School Teacher") ? "School" : "Office"} :  ",
                                style: context.semiBold14(
                                  color: ColorManager.white,
                                ),
                              ),
                              ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX:
                                      widget.personDetails.isSchoolHide ? 5 : 0,
                                  sigmaY:
                                      widget.personDetails.isSchoolHide ? 5 : 0,
                                ),
                                child: Text(
                                  (widget.personDetails.job == "Provincial School Teacher" || widget.personDetails.job == "National School Teacher") ? (widget.personDetails.school?.length ?? 0) > 25 ? '${widget.personDetails.school?.substring(0, 25)}...' : "${widget.personDetails.school ?? '*****************'}    " : widget.personDetails.job == "Nurse" ? (widget.personDetails.officeForNurse?.length ?? 0) > 25 ? '${widget.personDetails.officeForNurse?.substring(0, 25)}...' : "${widget.personDetails.officeForNurse ?? '*****************'}    " : (widget.personDetails.officeForMA?.length ?? 0) > 25 ? '${widget.personDetails.officeForMA?.substring(0, 25)}...' : "${widget.personDetails.officeForMA ?? '*****************'}    ",
                                  style: context.semiBold14(
                                    color: ColorManager.white,
                                  ),
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              widget.personDetails.isSchoolHide
                                  ? Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    // child: Tooltip(
                                    //   message:
                                    //       "Content hidden. Tap chat icon to request details.",
                                    //   child: Icon(
                                    //     Icons.visibility_off,
                                    //     color: ColorManager.white,
                                    //     size: 16,
                                    //   ),
                                    // ),
                                    child: InfoButtonWithTooltip(
                                      tooltipText:
                                          'This content is hidden. Tap the chat icon to request your details.',
                                      child: Icon(
                                        Icons.visibility_off,
                                        color: ColorManager.white,
                                        size: 16,
                                      ),
                                    ),
                                  )
                                  : SizedBox.shrink(),
                            ],
                          ),
                          SizedBox(height: context.verticalSize(5)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "   Contact :  ",
                                style: context.semiBold14(
                                  color: ColorManager.white,
                                ),
                              ),
                               ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX:
                                        widget.personDetails.isPhoneHide
                                            ? 5
                                            : 0,
                                    sigmaY:
                                        widget.personDetails.isPhoneHide
                                            ? 5
                                            : 0,
                                  ),
                                  child: Text(
                                    "${widget.personDetails.phone ?? '07********'}    ",
                                    style: context.semiBold14(
                                      color: ColorManager.white,
                                    ),
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              widget.personDetails.isPhoneHide
                                  ? Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    // child: Tooltip(
                                    //   message:
                                    //       "Content hidden. Tap chat icon to request details.",
                                    //   child: Icon(
                                    //     Icons.visibility_off,
                                    //     color: ColorManager.white,
                                    //     size: 16,
                                    //   ),
                                    // ),
                                    child: InfoButtonWithTooltip(
                                      tooltipText:
                                          'This content is hidden. Tap the chat icon to request your details.',
                                      child: Icon(
                                        Icons.visibility_off,
                                        color: ColorManager.white,
                                        size: 16,
                                      ),
                                    ),
                                  )
                                  : SizedBox.shrink(),
                            ],
                          ),
                          SizedBox(height: context.verticalSize(5)),
                          Text(
                            " * ${widget.personDetails.note}",
                            style: context.regular12(color: ColorManager.white),
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.translucent,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(Icons.chat, color: ColorManager.white),
                      ),
                    ),
                  ],
                )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
