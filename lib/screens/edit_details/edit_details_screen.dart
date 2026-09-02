import 'dart:io';
import 'dart:ui';

import 'package:app/app/export.dart';
import 'package:app/app/models/filter_model.dart';
import 'package:app/app/models/person_details_model.dart';
import 'package:app/app/utils/context_helper.dart';
import 'package:app/app/utils/custom_toast.dart';
import 'package:app/app/widgets/show_confirmation_alert.dart';
import 'package:app/providers/account_provider.dart';
import 'package:app/providers/filtter_provider.dart';
import 'package:app/providers/service_providers/static_data_service.dart';
import 'package:app/screens/image/custom_camera_nw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/app/utils/translation_service.dart';
import 'package:app/app/widgets/language_selector.dart';

class EditDetailsScreen extends StatefulWidget {
  const EditDetailsScreen({super.key});

  @override
  State<EditDetailsScreen> createState() => _EditDetailsScreenState();
}

class _EditDetailsScreenState extends State<EditDetailsScreen> {
  final informationFormKey = GlobalKey<FormState>();
  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? idCardError;
  String? contactError;
  String? whatsappError;
  String? passwordError;
  String? confirmPasswordError;
  String? schoolError;
  String? subjectError;
  String? gradeError;
  String? subjectMediumError;
  String? choiceError;
  DateTime? _selectedDate;
  String? _dobErrorText;
  File? selectedImage;
  bool _isBottomSheetVisible = false;
  bool isDataLoading = true;

  String? _loadingField;

  late AccountProvider accProvider;
  FilterModel filterDetails = FilterModel();
  late FilterModel _initialFilterDetails;

  @override
  void initState() {
    super.initState();
    accProvider = Provider.of<AccountProvider>(ContextHelper.navigatorKey.currentContext!, listen: false);

    filterDetails = FilterModel(
      job: accProvider.appUser?.job ?? '',
      province: accProvider.appUser?.province ?? '',
      district: accProvider.appUser?.district ?? '',
      kalapa: accProvider.appUser?.kalapa ?? '',
      kottasa: accProvider.appUser?.kottasa ?? '',
      school: accProvider.appUser?.school ?? '',
      kottasaForNationalScl: accProvider.appUser?.kottasaForNationalScl ?? '',
      nationalSchool: accProvider.appUser?.nationalSchool ?? '',
      institutionTypeForNurse: accProvider.appUser?.institutionTypeForNurse ?? '',
      officeForNurse: accProvider.appUser?.officeForNurse ?? '',
      institutionTypeForMA: accProvider.appUser?.institutionTypeForMA ?? '',
      officeForMA: accProvider.appUser?.officeForMA ?? '',
      institutionTypeForPS: accProvider.appUser?.institutionTypeForPS ?? '',
      officeForPS: accProvider.appUser?.officeForPS ?? '',
      policeDivisions: accProvider.appUser?.policeDivisions ?? '',
      policeStations: accProvider.appUser?.policeStations ?? '',
      divisionalSecretariat: accProvider.appUser?.divisionalSecretariat ?? '',
      gramaNiladhariDivision: accProvider.appUser?.gramaNiladhariDivision ?? '',
      scheme: accProvider.appUser?.scheme ?? '',
      subject: accProvider.appUser?.subject ?? '',
      subjectMedium: accProvider.appUser?.subjectMedium ?? '',
      grade: accProvider.appUser?.grade ?? '',
      choice1: accProvider.appUser?.choice1 ?? '',
      choice2: accProvider.appUser?.choice2 ?? '',
      choice3: accProvider.appUser?.choice3 ?? '',
    );
    _initialFilterDetails = filterDetails.copy();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await StaticDataService.loadRootData(filterDetails);

    if (filterDetails.province.isNotEmpty) {
      await StaticDataService.fetchDistricts(filterDetails, filterDetails.province);
    }
    if (filterDetails.district.isNotEmpty) {
      if (filterDetails.job == "Provincial School Teacher" || filterDetails.job == "National School Teacher") {
        await StaticDataService.fetchKalapas(filterDetails, filterDetails.district);
      } else if (filterDetails.job == "Nurse" || filterDetails.job == "Hospital Attendant") {
        await StaticDataService.fetchNurseInstitutions(filterDetails, filterDetails.district);
      } else if (filterDetails.job == "Public Health Inspector" || filterDetails.job == "Public Health Midwife") {
        await StaticDataService.fetchNurseOffices(filterDetails, "MOH Office ${filterDetails.district}");
      } else if (filterDetails.job == "Management Assistant" ||
          filterDetails.job == "Development Officer" ||
          filterDetails.job == "Administrative Officer") {
        await StaticDataService.fetchMAInstitutions(filterDetails, filterDetails.district);
      } else if (filterDetails.job == "MA (Pradesiya Sabha)") {
        filterDetails.institutionTypeForPS = 'Pradesiya Sabha';
        await StaticDataService.fetchPradesiyaSabhas(filterDetails, filterDetails.district);
      } else if (filterDetails.job == "Police Officer") {
        await StaticDataService.fetchPoliceDivisions(filterDetails, filterDetails.district);
      } else if (filterDetails.job == "Grama Niladari") {
        await StaticDataService.fetchDSDivisions(filterDetails, filterDetails.district);
      }
    }
    if (filterDetails.kalapa.isNotEmpty) {
      if (filterDetails.job == "Provincial School Teacher") {
        await StaticDataService.fetchKottasas(filterDetails, filterDetails.kalapa);
      } else if (filterDetails.job == "National School Teacher") {
        await StaticDataService.fetchKottasasNational(filterDetails, filterDetails.kalapa);
      }
    }
    if (filterDetails.institutionTypeForNurse.isNotEmpty) {
      await StaticDataService.fetchNurseOffices(filterDetails, filterDetails.institutionTypeForNurse);
    }
    if (filterDetails.institutionTypeForMA.isNotEmpty) {
      await StaticDataService.fetchMAOffices(filterDetails, filterDetails.institutionTypeForMA);
    }
    if (filterDetails.policeDivisions.isNotEmpty) {
      await StaticDataService.fetchPoliceStations(filterDetails, filterDetails.policeDivisions);
    }
    if (filterDetails.divisionalSecretariat.isNotEmpty) {
      await StaticDataService.fetchGNDivisions(filterDetails, filterDetails.divisionalSecretariat);
    }
    if (filterDetails.kottasa.isNotEmpty) {
      await StaticDataService.fetchSchools(filterDetails, filterDetails.kottasa);
    }
    if (filterDetails.kottasaForNationalScl.isNotEmpty) {
      await StaticDataService.fetchNationalSchools(filterDetails, filterDetails.kottasaForNationalScl);
    }
    if (filterDetails.scheme.isNotEmpty && filterDetails.scheme != "PRIMARY") {
      await StaticDataService.fetchSubjects(filterDetails, filterDetails.scheme);
    }

    _initialFilterDetails = filterDetails.copy();

    if (mounted) {
      setState(() {
        isDataLoading = false;
      });
    }
  }

  Widget _buildDropdownIcon(bool isLoading) {
    return isLoading
        ? SizedBox(width: 24, height: 24, child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 20))
        : Icon(Icons.arrow_drop_down, color: ColorManager.disabledText);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            hideBottomControls: true,
            lockAspectRatio: true,
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
          ),
          IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: true),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          selectedImage = File(croppedFile.path);
        });
        Navigator.pop(context);
      }
    }
  }

  void _confirmRemoveImage(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.removePhotoTitle),
            content: Text(l10n.removePhotoDesc),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedImage = null;
                  });
                  Navigator.pop(context);
                },
                child: Text(l10n.remove),
              ),
            ],
          ),
    );
  }

  void _confirmAlertDialog(
    BuildContext context,
    String title,
    String content,
    String confirmText,
    VoidCallback onConfirm,
    VoidCallback onCancel,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title, textAlign: TextAlign.start, style: context.bold16(color: ColorManager.black)),
            content: Text(
              content,
              textAlign: TextAlign.start,
              style: context.regular14(color: ColorManager.black.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: onCancel,
                child: Text(l10n.cancel, style: context.semiBold14(color: ColorManager.black)),
              ),
              TextButton(
                onPressed: onConfirm,
                child: Text(confirmText, style: context.semiBold14(color: ColorManager.red)),
              ),
            ],
          ),
    );
  }

  Future<bool?> _saveAlertDialog(BuildContext context, String title, String content, String confirmText) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title, textAlign: TextAlign.start, style: context.bold16(color: ColorManager.black)),
            content: Text(
              content,
              textAlign: TextAlign.start,
              style: context.regular14(color: ColorManager.black.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel, style: context.semiBold14(color: ColorManager.black)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmText, style: context.semiBold14(color: ColorManager.red)),
              ),
            ],
          ),
    );
  }

  String _buildFilterSummary(FilterModel filter) {
    List<String> summary = [];
    if (accProvider.firstNameController.text.isNotEmpty || accProvider.lastNameController.text.isNotEmpty) {
      summary.add('Name: ${accProvider.firstNameController.text} ${accProvider.lastNameController.text}');
    }
    if (filter.job.isNotEmpty) summary.add('Occupation: ${filter.job}');
    if (accProvider.contactController.text.isNotEmpty) {
      summary.add('Contact: ${accProvider.contactController.text}');
    }
    summary.add('Contact Visibility: ${accProvider.isContactVisible ? "Hidden" : "Visible"}');

    if (accProvider.whatsappController.text.isNotEmpty) {
      summary.add('WhatsApp: ${accProvider.whatsappController.text}');
    }
    summary.add('WhatsApp Visibility: ${accProvider.isWhatsappVisible ? "Hidden" : "Visible"}');

    summary.add(
      '${(filterDetails.job == "Provincial School Teacher" || filterDetails.job == "National School Teacher")
          ? "School Visibility"
          : filterDetails.job == "Police Officer"
          ? "Police Station Visibility"
          : "Office Visibility"}: ${accProvider.isSchoolVisible ? "Hidden" : "Visible"}',
    );
    if (filter.province.isNotEmpty) summary.add('Province: ${filter.province}');
    if (filter.district.isNotEmpty) summary.add('District: ${filter.district}');
    if (filter.kalapa.isNotEmpty) summary.add('Kalapa: ${filter.kalapa}');
    if (filter.kottasa.isNotEmpty) summary.add('Kottasa: ${filter.kottasa}');
    if (filter.school.isNotEmpty) summary.add('School: ${filter.school}');
    if (filter.kottasaForNationalScl.isNotEmpty) summary.add('Kottasa: ${filter.kottasaForNationalScl}');
    if (filter.nationalSchool.isNotEmpty) summary.add('School: ${filter.nationalSchool}');
    if (filter.institutionTypeForNurse.isNotEmpty) {
      summary.add('Institution Type: ${filter.institutionTypeForNurse}');
    }
    if (filter.officeForNurse.isNotEmpty) summary.add('Office: ${filter.officeForNurse}');
    if (filter.institutionTypeForMA.isNotEmpty) {
      summary.add('Institution Type: ${filter.institutionTypeForMA}');
    }
    if (filter.officeForMA.isNotEmpty) summary.add('Office: ${filter.officeForMA}');

    if (filter.institutionTypeForPS.isNotEmpty) {
      summary.add('Institution Type: ${filter.institutionTypeForPS}');
    }
    if (filter.officeForPS.isNotEmpty) summary.add('Office: ${filter.officeForPS}');

    if (filter.policeDivisions.isNotEmpty) {
      summary.add('Police Division: ${filter.policeDivisions}');
    }
    if (filter.policeStations.isNotEmpty) summary.add('Police Station: ${filter.policeStations}');
    if (filter.divisionalSecretariat.isNotEmpty) {
      summary.add('Divisional Secretariat: ${filter.divisionalSecretariat}');
    }
    if (filter.gramaNiladhariDivision.isNotEmpty) summary.add('Office: ${filter.gramaNiladhariDivision}');
    if (filter.scheme.isNotEmpty) summary.add('Scheme: ${filter.scheme}');
    if (filter.subject.isNotEmpty) summary.add('Subject: ${filter.subject}');
    if (filter.subjectMedium.isNotEmpty) summary.add('Subject Medium: ${filter.subjectMedium}');
    if (filter.grade.isNotEmpty) summary.add('Grade: ${filter.grade}');
    if (filter.choice1.isNotEmpty) {
      summary.add('First Choise: ${filter.choice1}');
    }
    if (filter.choice2.isNotEmpty) {
      summary.add('Second Choise: ${filter.choice2}');
    }
    if (filter.choice3.isNotEmpty) {
      summary.add('Third Choise: ${filter.choice3}');
    }
    if (accProvider.noteController.text.isNotEmpty) {
      summary.add('Note: ${accProvider.noteController.text}');
    }
    return summary.isNotEmpty ? summary.join('\n') : 'No changes selected.';
  }

  bool get hasUnsavedChanges {
    return !_initialFilterDetails.isEqual(filterDetails);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: ColorManager.kPrimaryBlack,
      appBar: AppBar(
        backgroundColor: ColorManager.kPrimaryBlack,
        title: Text(l10n.editInformation, style: context.semiBold20(color: ColorManager.blackMedium)),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            (hasUnsavedChanges ||
                    accProvider.appUser?.displayName !=
                        "${accProvider.firstNameController.text.trim()} ${accProvider.lastNameController.text.trim()}" ||
                    accProvider.appUser?.phone != accProvider.contactController.text.trim() ||
                    accProvider.appUser?.whatsapp != accProvider.whatsappController.text.trim() ||
                    accProvider.appUser?.note != accProvider.noteController.text.trim() ||
                    accProvider.appUser?.isPhoneHide != accProvider.isContactVisible ||
                    accProvider.appUser?.isWhatsappHide != accProvider.isWhatsappVisible ||
                    accProvider.appUser?.isSchoolHide != accProvider.isSchoolVisible)
                ? _confirmAlertDialog(context, l10n.goBackConfirmTitle, l10n.goBackConfirmDesc, l10n.goBack, () {
                  List<String> parts = (accProvider.appUser?.displayName ?? "").split(' ');
                  accProvider.firstNameController.text = parts[0];
                  accProvider.lastNameController.text = parts.length > 1 ? parts[1] : '';
                  accProvider.contactController.text =
                      accProvider.appUser?.phone != null ? accProvider.appUser!.phone.toString() : '';
                  accProvider.whatsappController.text =
                      accProvider.appUser?.whatsapp != null ? accProvider.appUser!.whatsapp.toString() : '';
                  accProvider.isContactVisible = accProvider.appUser?.isPhoneHide ?? false;
                  accProvider.isWhatsappVisible = accProvider.appUser?.isWhatsappHide ?? false;
                  accProvider.isSchoolVisible = accProvider.appUser?.isSchoolHide ?? false;
                  accProvider.noteController.text = accProvider.appUser?.note ?? '';
                  Navigator.of(context)
                    ..pop()
                    ..pop();
                }, () => Navigator.of(context).pop())
                : Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back, color: ColorManager.blackMedium),
        ),
      ),
      body:
          isDataLoading
              ? Center(child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 40))
              : Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: context.padding(horizontal: 24),
                      child: Consumer<AccountProvider>(
                        builder: (context, acc, child) {
                          if (acc.isLoading) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Center(child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 40)),
                            );
                          }
                          return Form(
                            key: informationFormKey,
                            child: Column(
                              children: [
                                SizedBox(height: context.verticalSize(20)),
                                SizedBox(
                                  height: 90,
                                  width: 90,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(50),
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    onTap: () {},
                                    child: Center(
                                      child: Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              if (selectedImage != null) {
                                                _confirmRemoveImage(l10n);
                                              }
                                            },
                                            child: CircleAvatar(
                                              radius: 75,
                                              backgroundColor: Colors.grey[800],
                                              backgroundImage:
                                                  selectedImage != null
                                                      ? FileImage(selectedImage!) as ImageProvider
                                                      : null,
                                              child:
                                                  selectedImage == null
                                                      ? Text(
                                                        '${acc.firstNameController.text.isNotEmpty ? acc.firstNameController.text.substring(0, 1) : (accProvider.appUser?.firstName ?? '-').substring(0, 1)}${acc.lastNameController.text.isNotEmpty ? acc.lastNameController.text.substring(0, 1) : (accProvider.appUser?.lastName ?? "-").substring(0, 1)}',
                                                        style: context.bold30(color: ColorManager.white),
                                                      )
                                                      : null,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() => _isBottomSheetVisible = true);
                                                ConfirmationAlert.showConfirmationAlert(
                                                  context: context,
                                                  title: l10n.choosePhotoSource,
                                                  message: l10n.camera,
                                                  messageColor: ColorManager.kAleartTextColor,
                                                  onTap2: () {
                                                    setState(() => _isBottomSheetVisible = false);
                                                    Navigator.of(context)
                                                        .push(
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) => CustomCameraNw(
                                                                  onImageSelected: (File image) {
                                                                    setState(() {
                                                                      selectedImage = image;
                                                                    });
                                                                  },
                                                                ),
                                                          ),
                                                        )
                                                        .then((isSuccess) {
                                                          if (isSuccess == true) {
                                                            Navigator.pop(context);
                                                          } else {
                                                            Navigator.pop(context);
                                                          }
                                                        });
                                                  },
                                                  actionText: l10n.selectFromGallery,
                                                  actionColor: ColorManager.kAleartTextColor,
                                                  isCancelVisible: true,
                                                  cancelColor: ColorManager.kAleartCancelTextColor,
                                                  onTap: () {
                                                    setState(() => _isBottomSheetVisible = false);
                                                    _pickImage();
                                                  },
                                                  cancelOnTap: () {
                                                    setState(() => _isBottomSheetVisible = false);
                                                    Navigator.pop(context);
                                                  },
                                                  onDismiss: () {
                                                    setState(() => _isBottomSheetVisible = false);
                                                  },
                                                );
                                              },
                                              child: Icon(Icons.add_circle, size: 28, color: ColorManager.gray),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: context.verticalSize(23)),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    l10n.legalName,
                                    style: context.semiBold14(color: ColorManager.blackMedium),
                                  ),
                                ),
                                SizedBox(height: context.verticalSize(8)),
                                CustomTextField(
                                  radius: 30,
                                  height: context.verticalSize(40),
                                  controller: acc.firstNameController,
                                  inputType: TextInputType.name,
                                  hintText: l10n.firstName,
                                  validator: (value) {
                                    if (acc.firstNameController.text.isEmpty) {
                                      setState(() {
                                        firstNameError = l10n.reqFirstName;
                                      });
                                      return '';
                                    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value!)) {
                                      setState(() {
                                        firstNameError = l10n.reqValidFirstName;
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      firstNameError = null;
                                    });
                                    return null;
                                  },
                                  errorMessage: firstNameError,
                                ),
                                CustomTextField(
                                  radius: 30,
                                  height: context.verticalSize(40),
                                  controller: acc.lastNameController,
                                  inputType: TextInputType.name,
                                  hintText: l10n.lastName,
                                  validator: (value) {
                                    if (acc.lastNameController.text.isEmpty) {
                                      setState(() {
                                        lastNameError = l10n.reqLastName;
                                      });
                                      return '';
                                    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value!)) {
                                      setState(() {
                                        lastNameError = l10n.reqValidLastName;
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      lastNameError = null;
                                    });
                                    return null;
                                  },
                                  errorMessage: lastNameError,
                                ),
                                SizedBox(height: context.verticalSize(20)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          l10n.contactNumber,
                                          style: context.semiBold14(color: ColorManager.blackMedium),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          acc.isContactVisible = !acc.isContactVisible;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            l10n.hide,
                                            style: context.semiBold14(
                                              color:
                                                  acc.isContactVisible
                                                      ? ColorManager.disabledText
                                                      : ColorManager.kPrimary,
                                            ),
                                          ),
                                          SizedBox(width: context.horizontalSize(10)),
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color:
                                                  acc.isContactVisible ? ColorManager.disabledText : Colors.transparent,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: ColorManager.disabledText),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: context.verticalSize(8)),
                                CustomTextField(
                                  radius: 30,
                                  height: context.verticalSize(40),
                                  controller: acc.contactController,
                                  inputType: TextInputType.number,
                                  hintText: l10n.contactNumber,
                                  validator: (value) {
                                    if (acc.contactController.text.isEmpty) {
                                      setState(() {
                                        contactError = l10n.reqContact;
                                      });
                                      return '';
                                    } else if (value!.length < 5 || value.length > 20) {
                                      setState(() {
                                        contactError = l10n.reqValidContact;
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      contactError = null;
                                    });
                                    return null;
                                  },
                                  errorMessage: contactError,
                                ),

                                SizedBox(height: context.verticalSize(10)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.whatsappOptional,
                                      style: context.semiBold14(color: ColorManager.blackMedium),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          acc.isWhatsappVisible = !acc.isWhatsappVisible;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            l10n.hide,
                                            style: context.semiBold14(
                                              color:
                                                  acc.isWhatsappVisible
                                                      ? ColorManager.disabledText
                                                      : ColorManager.kPrimary,
                                            ),
                                          ),
                                          SizedBox(width: context.horizontalSize(10)),
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color:
                                                  acc.isWhatsappVisible
                                                      ? ColorManager.disabledText
                                                      : Colors.transparent,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: ColorManager.disabledText),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: context.verticalSize(8)),
                                CustomTextField(
                                  radius: 30,
                                  height: context.verticalSize(40),
                                  controller: acc.whatsappController,
                                  inputType: TextInputType.number,
                                  hintText: l10n.whatsappNumber,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      if (value.length < 5 || value.length > 20) {
                                        setState(() {
                                          whatsappError = l10n.reqValidWhatsapp;
                                        });
                                        return '';
                                      }
                                    }
                                    setState(() {
                                      whatsappError = null;
                                    });
                                    return null;
                                  },
                                  errorMessage: whatsappError,
                                ),

                                SizedBox(height: context.verticalSize(20)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          (filterDetails.job == "Provincial School Teacher" ||
                                                  filterDetails.job == "National School Teacher")
                                              ? l10n.setupSchoolingDetails
                                              : l10n.setupOfficeDetails,
                                          style: context.semiBold14(color: ColorManager.blackMedium),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          acc.isSchoolVisible = !acc.isSchoolVisible;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            l10n.hide,
                                            style: context.semiBold14(
                                              color:
                                                  acc.isSchoolVisible
                                                      ? ColorManager.disabledText
                                                      : ColorManager.kPrimary,
                                            ),
                                          ),
                                          SizedBox(width: context.horizontalSize(10)),
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color:
                                                  acc.isSchoolVisible ? ColorManager.disabledText : Colors.transparent,
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: ColorManager.disabledText),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: context.verticalSize(8)),
                                Container(
                                  height: context.verticalSize(40),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: ColorManager.white10,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: DropdownButton<String>(
                                    value: filterDetails.province.isNotEmpty ? filterDetails.province : null,
                                    hint: Text(
                                      l10n.selectProvince,
                                      style: context.regular14(color: ColorManager.disabledText),
                                    ),
                                    items:
                                        filterDetails.provinces
                                            .map(
                                              (province) => DropdownMenuItem(
                                                value: province,
                                                child: Text(
                                                  TranslationService.translate(context, province),
                                                  style: context.regular14(color: ColorManager.disabledText),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) async {
                                      setState(() {
                                        filterDetails.province = value ?? '';
                                        filterDetails.district = '';
                                        filterDetails.kalapa = '';
                                        filterDetails.kottasa = '';
                                        filterDetails.school = '';
                                        filterDetails.kottasaForNationalScl = '';
                                        filterDetails.nationalSchool = '';
                                        filterDetails.institutionTypeForNurse = '';
                                        filterDetails.officeForNurse = '';
                                        filterDetails.institutionTypeForMA = '';
                                        filterDetails.officeForMA = '';
                                        filterDetails.institutionTypeForPS = '';
                                        filterDetails.officeForPS = '';
                                        filterDetails.divisionalSecretariat = '';
                                        filterDetails.gramaNiladhariDivision = '';
                                        filterDetails.policeDivisions = '';
                                        filterDetails.policeStations = '';
                                        _loadingField = 'province';
                                      });
                                      if (value != null && value.isNotEmpty) {
                                        await StaticDataService.fetchDistricts(filterDetails, value);
                                      }
                                      if (mounted) {
                                        setState(() {
                                          _loadingField = null;
                                        });
                                      }
                                    },
                                    dropdownColor: ColorManager.kPrimaryBlack,
                                    underline: const SizedBox(),
                                    icon: _buildDropdownIcon(_loadingField == 'province'),
                                    isExpanded: true,
                                  ),
                                ),

                                SizedBox(height: context.verticalSize(filterDetails.province.isNotEmpty ? 20 : 0)),

                                filterDetails.province.isNotEmpty
                                    ? Container(
                                      height: context.verticalSize(40),
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: ColorManager.white10,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: DropdownButton<String>(
                                        value: filterDetails.district.isNotEmpty ? filterDetails.district : null,
                                        hint: Text(
                                          l10n.selectDistrict,
                                          style: context.regular14(color: ColorManager.disabledText),
                                        ),
                                        items:
                                            (filterDetails.province.isNotEmpty
                                                    ? filterDetails.provinceDistricts[filterDetails.province] ?? []
                                                    : <String>[])
                                                .map(
                                                  (district) => DropdownMenuItem(
                                                    value: district,
                                                    child: Text(
                                                      TranslationService.translate(context, district),
                                                      style: context.regular14(color: ColorManager.blackMedium),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (value) async {
                                          setState(() {
                                            filterDetails.district = value ?? '';
                                            filterDetails.kalapa = '';
                                            filterDetails.kottasa = '';
                                            filterDetails.school = '';
                                            filterDetails.kottasaForNationalScl = '';
                                            filterDetails.nationalSchool = '';
                                            filterDetails.institutionTypeForNurse = '';
                                            filterDetails.officeForNurse = '';
                                            filterDetails.institutionTypeForMA = '';
                                            filterDetails.officeForMA = '';
                                            filterDetails.institutionTypeForPS = '';
                                            filterDetails.officeForPS = '';
                                            filterDetails.divisionalSecretariat = '';
                                            filterDetails.gramaNiladhariDivision = '';
                                            filterDetails.policeDivisions = '';
                                            filterDetails.policeStations = '';
                                            _loadingField = 'district';
                                          });
                                          if (value != null && value.isNotEmpty) {
                                            if (filterDetails.job == "Provincial School Teacher" ||
                                                filterDetails.job == "National School Teacher") {
                                              await StaticDataService.fetchKalapas(filterDetails, value);
                                            } else if (filterDetails.job == "Nurse" ||
                                                filterDetails.job == "Hospital Attendant") {
                                              await StaticDataService.fetchNurseInstitutions(filterDetails, value);
                                            } else if (filterDetails.job == "Public Health Inspector" ||
                                                filterDetails.job == "Public Health Midwife") {
                                              filterDetails.institutionTypeForNurse = "MOH Office $value";
                                              await StaticDataService.fetchNurseOffices(
                                                filterDetails,
                                                "MOH Office $value",
                                              );
                                            } else if (filterDetails.job == "Management Assistant" ||
                                                filterDetails.job == "Development Officer" ||
                                                filterDetails.job == "Administrative Officer") {
                                              await StaticDataService.fetchMAInstitutions(filterDetails, value);
                                            } else if (filterDetails.job == "MA (Pradesiya Sabha)") {

                                              filterDetails.institutionTypeForPS = 'Pradesiya Sabha';
                                              await StaticDataService.fetchPradesiyaSabhas(filterDetails, value);
                                            } else if (filterDetails.job == "Police Officer") {
                                              await StaticDataService.fetchPoliceDivisions(filterDetails, value);
                                            } else if (filterDetails.job == "Grama Niladari") {
                                              await StaticDataService.fetchDSDivisions(filterDetails, value);
                                            }
                                          }
                                          if (mounted) {
                                            setState(() {
                                              _loadingField = null;
                                            });
                                          }
                                        },
                                        dropdownColor: ColorManager.kPrimaryBlack,
                                        underline: const SizedBox(),
                                        icon: _buildDropdownIcon(_loadingField == 'district'),
                                        isExpanded: true,
                                      ),
                                    )
                                    : SizedBox.shrink(),
                                SizedBox(height: context.verticalSize(filterDetails.district.isNotEmpty ? 20 : 0)),

                                (filterDetails.district.isNotEmpty &&
                                        filterDetails.job != "Public Health Inspector" &&
                                        filterDetails.job != "Public Health Midwife")
                                    ? Container(
                                      height: context.verticalSize(40),
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: ColorManager.white10,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: DropdownButton<String>(
                                        value:
                                            (filterDetails.job == "Provincial School Teacher" ||
                                                    filterDetails.job == "National School Teacher")
                                                ? filterDetails.kalapa.isNotEmpty
                                                    ? filterDetails.kalapa
                                                    : null
                                                : (filterDetails.job == "Nurse" ||
                                                    filterDetails.job == "Hospital Attendant")
                                                ? filterDetails.institutionTypeForNurse.isNotEmpty
                                                    ? filterDetails.institutionTypeForNurse
                                                    : null
                                                : (filterDetails.job == "Management Assistant" ||
                                                    filterDetails.job == "Development Officer" ||
                                                    filterDetails.job == "Administrative Officer")
                                                ? filterDetails.institutionTypeForMA.isNotEmpty
                                                    ? filterDetails.institutionTypeForMA
                                                    : null
                                                : filterDetails.job ==
                                                    "MA (Pradesiya Sabha)"
                                                ? filterDetails.institutionTypeForPS.isNotEmpty
                                                    ? filterDetails.institutionTypeForPS
                                                    : null
                                                : filterDetails.job == "Police Officer"
                                                ? filterDetails.policeDivisions.isNotEmpty
                                                    ? filterDetails.policeDivisions
                                                    : null
                                                : filterDetails.job == "Grama Niladari"
                                                ? filterDetails.divisionalSecretariat.isNotEmpty
                                                    ? filterDetails.divisionalSecretariat
                                                    : null
                                                : null,
                                        hint: Text(
                                          (filterDetails.job == "Provincial School Teacher" ||
                                                  filterDetails.job == "National School Teacher")
                                              ? l10n.selectKalapa
                                              : l10n.selectInstitutionType,
                                          style: context.regular14(color: ColorManager.disabledText),
                                        ),
                                        items:
                                            ((filterDetails.job == "Provincial School Teacher" ||
                                                        filterDetails.job == "National School Teacher")
                                                    ? (filterDetails.district.isNotEmpty
                                                            ? filterDetails.districtKalapas[filterDetails.district] ??
                                                                []
                                                            : <String>[])
                                                        .map(
                                                          (kalapa) => DropdownMenuItem(
                                                            value: kalapa,
                                                            child: Text(
                                                              TranslationService.translate(context, kalapa),
                                                              style: context.regular14(
                                                                color: ColorManager.disabledText,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                    : (filterDetails.job == "Nurse" ||
                                                        filterDetails.job == "Hospital Attendant")
                                                    ? (filterDetails.district.isNotEmpty
                                                            ? filterDetails
                                                                    .districtInstitutionTypeForNurse[filterDetails
                                                                    .district] ??
                                                                []
                                                            : <String>[])
                                                        .map(
                                                          (institute) => DropdownMenuItem(
                                                            value: institute,
                                                            child: Text(
                                                              TranslationService.translate(context, institute),
                                                              style: context.regular14(
                                                                color: ColorManager.disabledText,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                    : (filterDetails.job == "Management Assistant" ||
                                                        filterDetails.job == "Development Officer" ||
                                                        filterDetails.job == "Administrative Officer")
                                                    ? (filterDetails.district.isNotEmpty
                                                            ? filterDetails.districtInstitutionTypeForMA[filterDetails
                                                                    .district] ??
                                                                []
                                                            : <String>[])
                                                        .map(
                                                          (institute) => DropdownMenuItem(
                                                            value: institute,
                                                            child: Text(
                                                              TranslationService.translate(context, institute),
                                                              style: context.regular14(
                                                                color: ColorManager.disabledText,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                    : filterDetails.job ==
                                                        "MA (Pradesiya Sabha)"
                                                    ? ["Pradesiya Sabha"].map(
                                                      (institute) => DropdownMenuItem(
                                                        value: institute,
                                                        child: Text(
                                                          TranslationService.translate(context, institute),
                                                          style: context.regular14(color: ColorManager.disabledText),
                                                        ),
                                                      ),
                                                    )
                                                    : filterDetails.job == "Police Officer"
                                                    ? (filterDetails.district.isNotEmpty
                                                            ? filterDetails.districtPoliceDivisions[filterDetails
                                                                    .district] ??
                                                                []
                                                            : <String>[])
                                                        .map(
                                                          (policeDivisions) => DropdownMenuItem(
                                                            value: policeDivisions,
                                                            child: Text(
                                                              TranslationService.translate(context, policeDivisions),
                                                              style: context.regular14(
                                                                color: ColorManager.disabledText,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                    : (filterDetails.district.isNotEmpty
                                                            ? filterDetails.districtDsDivisions[filterDetails
                                                                    .district] ??
                                                                []
                                                            : <String>[])
                                                        .map(
                                                          (dsDivisions) => DropdownMenuItem(
                                                            value: dsDivisions,
                                                            child: Text(
                                                              TranslationService.translate(context, dsDivisions),
                                                              style: context.regular14(
                                                                color: ColorManager.disabledText,
                                                              ),
                                                            ),
                                                          ),
                                                        ))
                                                .toList(),
                                        onChanged: (value) async {
                                          setState(() {
                                            (filterDetails.job == "Provincial School Teacher" ||
                                                    filterDetails.job == "National School Teacher")
                                                ? filterDetails.kalapa = value ?? ''
                                                : (filterDetails.job == "Nurse" ||
                                                    filterDetails.job == "Hospital Attendant")
                                                ? filterDetails.institutionTypeForNurse = value ?? ''
                                                : (filterDetails.job == "Management Assistant" ||
                                                    filterDetails.job == "Development Officer" ||
                                                    filterDetails.job == "Administrative Officer")
                                                ? filterDetails.institutionTypeForMA = value ?? ''
                                                : filterDetails.job ==
                                                    "MA (Pradesiya Sabha)"
                                                ? filterDetails.institutionTypeForPS = value ?? ''
                                                : filterDetails.job == "Police Officer"
                                                ? filterDetails.policeDivisions = value ?? ''
                                                : filterDetails.job == "Grama Niladari"
                                                ? filterDetails.divisionalSecretariat = value ?? ''
                                                : '';
                                            filterDetails.kottasa = '';
                                            filterDetails.school = '';
                                            filterDetails.kottasaForNationalScl = '';
                                            filterDetails.nationalSchool = '';
                                            filterDetails.officeForNurse = '';
                                            filterDetails.officeForMA = '';
                                            filterDetails.officeForPS = '';
                                            filterDetails.policeStations = '';
                                            filterDetails.gramaNiladhariDivision = '';
                                            _loadingField = 'kalapa_institute';
                                          });
                                          if (value != null && value.isNotEmpty) {
                                            if (filterDetails.job == "Provincial School Teacher") {
                                              await StaticDataService.fetchKottasas(filterDetails, value);
                                            } else if (filterDetails.job == "National School Teacher") {
                                              await StaticDataService.fetchKottasasNational(filterDetails, value);
                                            } else if (filterDetails.job == "Nurse" ||
                                                filterDetails.job == "Hospital Attendant") {
                                              await StaticDataService.fetchNurseOffices(filterDetails, value);
                                            } else if (filterDetails.job == "Management Assistant" ||
                                                filterDetails.job == "Development Officer" ||
                                                filterDetails.job == "Administrative Officer") {
                                              await StaticDataService.fetchMAOffices(filterDetails, value);
                                            } else if (filterDetails.job == "Police Officer") {
                                              await StaticDataService.fetchPoliceStations(filterDetails, value);
                                            } else if (filterDetails.job == "Grama Niladari") {
                                              await StaticDataService.fetchGNDivisions(filterDetails, value);
                                            }
                                          }
                                          if (mounted) {
                                            setState(() {
                                              _loadingField = null;
                                            });
                                          }
                                        },
                                        dropdownColor: ColorManager.kPrimaryBlack,
                                        underline: const SizedBox(),
                                        icon: _buildDropdownIcon(_loadingField == 'kalapa_institute'),
                                        isExpanded: true,
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                                SizedBox(
                                  height: context.verticalSize(
                                    (filterDetails.kalapa.isNotEmpty ||
                                            filterDetails.institutionTypeForNurse.isNotEmpty ||
                                            filterDetails.institutionTypeForMA.isNotEmpty ||
                                            filterDetails.institutionTypeForPS.isNotEmpty ||
                                            filterDetails.policeDivisions.isNotEmpty ||
                                            filterDetails.divisionalSecretariat.isNotEmpty ||
                                            ((filterDetails.job == "Public Health Inspector" ||
                                                    filterDetails.job == "Public Health Midwife") &&
                                                filterDetails.district.isNotEmpty))
                                        ? 20
                                        : 0,
                                  ),
                                ),

                                (((filterDetails.job == "Provincial School Teacher" ||
                                                filterDetails.job == "National School Teacher") &&
                                            filterDetails.kalapa.isNotEmpty) ||
                                        filterDetails.institutionTypeForNurse.isNotEmpty ||
                                        filterDetails.institutionTypeForMA.isNotEmpty ||
                                        filterDetails.institutionTypeForPS.isNotEmpty ||
                                        filterDetails.policeDivisions.isNotEmpty ||
                                        filterDetails.divisionalSecretariat.isNotEmpty ||
                                        ((filterDetails.job == "Public Health Inspector" ||
                                                filterDetails.job == "Public Health Midwife") &&
                                            filterDetails.district.isNotEmpty))
                                    ? Container(
                                      height: context.verticalSize(40),
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: ColorManager.white10,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: DropdownButton<String>(
                                        value:
                                            filterDetails.job == "Provincial School Teacher"
                                                ? filterDetails.kottasa.isNotEmpty
                                                    ? filterDetails.kottasa
                                                    : null
                                                : filterDetails.job == "National School Teacher"
                                                ? filterDetails.kottasaForNationalScl.isNotEmpty
                                                    ? filterDetails.kottasaForNationalScl
                                                    : null
                                                : (filterDetails.job == "Nurse" ||
                                                    filterDetails.job == "Hospital Attendant" ||
                                                    filterDetails.job == "Public Health Inspector" ||
                                                    filterDetails.job == "Public Health Midwife")
                                                ? filterDetails.officeForNurse.isNotEmpty
                                                    ? filterDetails.officeForNurse
                                                    : null
                                                : (filterDetails.job == "Management Assistant" ||
                                                    filterDetails.job == "Development Officer" ||
                                                    filterDetails.job == "Administrative Officer")
                                                ? filterDetails.officeForMA.isNotEmpty
                                                    ? filterDetails.officeForMA
                                                    : null
                                                : filterDetails.job ==
                                                    "MA (Pradesiya Sabha)"
                                                ? filterDetails.officeForPS.isNotEmpty
                                                    ? filterDetails.officeForPS
                                                    : null
                                                : filterDetails.job == "Police Officer"
                                                ? filterDetails.policeStations.isNotEmpty
                                                    ? filterDetails.policeStations
                                                    : null
                                                : filterDetails.job == "Grama Niladari"
                                                ? filterDetails.gramaNiladhariDivision.isNotEmpty
                                                    ? filterDetails.gramaNiladhariDivision
                                                    : null
                                                : null,
                                        hint: Text(
                                          (filterDetails.job == "Provincial School Teacher" ||
                                                  filterDetails.job == "National School Teacher")
                                              ? l10n.selectKottasa
                                              : l10n.selectOffice,
                                          style: context.regular14(color: ColorManager.disabledText),
                                        ),
                                        items:
                                            (filterDetails.job == "Provincial School Teacher"
                                                    ? (filterDetails.kalapa.isNotEmpty
                                                            ? filterDetails.kalapaKottasa[filterDetails.kalapa] ?? []
                                                            : <String>[])
                                                        .map(
                                                          (kottasa) => DropdownMenuItem(
                                                            value: kottasa,
                                                            child: Text(
                                                              TranslationService.translate(context, kottasa),
                                                              style: context.regular14(color: ColorManager.blackMedium),
                                                            ),
                                                          ),
                                                        )
                                                    : filterDetails.job == "National School Teacher"
                                                    ? (filterDetails.kalapa.isNotEmpty
                                                            ? filterDetails.kalapaKottasaForNationalScl[filterDetails
                                                                    .kalapa] ??
                                                                []
                                                            : <String>[])
                                                        .map(
                                                          (kottasa) => DropdownMenuItem(
                                                            value: kottasa,
                                                            child: Text(
                                                              TranslationService.translate(context, kottasa),
                                                              style: context.regular14(color: ColorManager.blackMedium),
                                                            ),
                                                          ),
                                                        )
                                                    : (filterDetails.job == "Nurse" ||
                                                        filterDetails.job == "Hospital Attendant" ||
                                                        filterDetails.job == "Public Health Inspector" ||
                                                        filterDetails.job == "Public Health Midwife")
                                                    ? (filterDetails.institutionTypeForNurse.isNotEmpty
                                                            ? filterDetails.institutionTypeOfficesForNurse[filterDetails
                                                                    .institutionTypeForNurse] ??
                                                                []
                                                            : <String>[])
                                                        .map(
                                                          (office) => DropdownMenuItem(
                                                            value: office,
                                                            child: Text(
                                                              TranslationService.translate(context, office),
                                                              style: context.regular14(color: ColorManager.blackMedium),
                                                            ),
                                                          ),
                                                        )
                                                    : (filterDetails.job == "Management Assistant" ||
                                                        filterDetails.job == "Development Officer" ||
                                                        filterDetails.job == "Administrative Officer")
                                                    ? (filterDetails.institutionTypeForMA.isNotEmpty
                                                            ? filterDetails.institutionTypeOfficesForMA[filterDetails
                                                                    .institutionTypeForMA] ??
                                                                []
                                                            : <String>[])
                                                        .map(
                                                          (office) => DropdownMenuItem(
                                                            value: office,
                                                            child: Text(
                                                              TranslationService.translate(context, office),
                                                              style: context.regular14(color: ColorManager.blackMedium),
                                                            ),
                                                          ),
                                                        )
                                                    : filterDetails.job ==
                                                        "MA (Pradesiya Sabha)"
                                                    ? (filterDetails.institutionTypeForPS.isNotEmpty
                                                            ? filterDetails.districtPradesiyaSabhas[filterDetails
                                                                    .district] ??
                                                                []
                                                            : <String>[])
                                                        .map(
                                                          (office) => DropdownMenuItem(
                                                            value: office,
                                                            child: Text(
                                                              TranslationService.translate(context, office),
                                                              style: context.regular14(color: ColorManager.blackMedium),
                                                            ),
                                                          ),
                                                        )
                                                    : filterDetails.job == "Police Officer"
                                                    ? (filterDetails.policeDivisions.isNotEmpty
                                                            ? filterDetails.policeDivisionStations[filterDetails
                                                                    .policeDivisions] ??
                                                                []
                                                            : <String>[])
                                                        .map(
                                                          (office) => DropdownMenuItem(
                                                            value: office,
                                                            child: Text(
                                                              TranslationService.translate(context, office),
                                                              style: context.regular14(color: ColorManager.blackMedium),
                                                            ),
                                                          ),
                                                        )
                                                    : (filterDetails.divisionalSecretariat.isNotEmpty
                                                            ? filterDetails.dsDivisionGnDivisions[filterDetails
                                                                    .divisionalSecretariat] ??
                                                                []
                                                            : <String>[])
                                                        .map(
                                                          (office) => DropdownMenuItem(
                                                            value: office,
                                                            child: Text(
                                                              TranslationService.translate(context, office),
                                                              style: context.regular14(color: ColorManager.blackMedium),
                                                            ),
                                                          ),
                                                        ))
                                                .toList(),
                                        onChanged: (value) async {
                                          setState(() {
                                            filterDetails.job == "Provincial School Teacher"
                                                ? filterDetails.kottasa = value ?? ''
                                                : filterDetails.job == "National School Teacher"
                                                ? filterDetails.kottasaForNationalScl = value ?? ''
                                                : (filterDetails.job == "Nurse" ||
                                                    filterDetails.job == "Hospital Attendant" ||
                                                    filterDetails.job == "Public Health Inspector" ||
                                                    filterDetails.job == "Public Health Midwife")
                                                ? filterDetails.officeForNurse = value ?? ''
                                                : (filterDetails.job == "Management Assistant" ||
                                                    filterDetails.job == "Development Officer" ||
                                                    filterDetails.job == "Administrative Officer")
                                                ? filterDetails.officeForMA = value ?? ''
                                                : filterDetails.job ==
                                                    "MA (Pradesiya Sabha)"
                                                ? filterDetails.officeForPS = value ?? ''
                                                : filterDetails.job == "Police Officer"
                                                ? filterDetails.policeStations = value ?? ''
                                                : filterDetails.job == "Grama Niladari"
                                                ? filterDetails.gramaNiladhariDivision = value ?? ''
                                                : '';
                                            filterDetails.school = '';
                                            filterDetails.nationalSchool = '';
                                            _loadingField = 'kottasa_office';
                                          });
                                          if (value != null && value.isNotEmpty) {
                                            if (filterDetails.job == "Provincial School Teacher") {
                                              await StaticDataService.fetchSchools(filterDetails, value);
                                            } else if (filterDetails.job == "National School Teacher") {
                                              await StaticDataService.fetchNationalSchools(filterDetails, value);
                                            }
                                          }
                                          if (mounted) {
                                            setState(() {
                                              _loadingField = null;
                                            });
                                          }
                                        },
                                        dropdownColor: ColorManager.kPrimaryBlack,
                                        underline: const SizedBox(),
                                        icon: _buildDropdownIcon(_loadingField == 'kottasa_office'),
                                        isExpanded: true,
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                                SizedBox(
                                  height: context.verticalSize(
                                    filterDetails.kottasa.isNotEmpty || filterDetails.kottasaForNationalScl.isNotEmpty
                                        ? 20
                                        : 0,
                                  ),
                                ),
                                ((filterDetails.job == "Provincial School Teacher" &&
                                            filterDetails.kottasa.isNotEmpty) ||
                                        (filterDetails.job == "National School Teacher" &&
                                            filterDetails.kottasaForNationalScl.isNotEmpty))
                                    ? Container(
                                      height: context.verticalSize(40),
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: ColorManager.white10,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: DropdownButton<String>(
                                        value:
                                            filterDetails.job == "Provincial School Teacher"
                                                ? filterDetails.school.isNotEmpty
                                                    ? filterDetails.school
                                                    : null
                                                : filterDetails.nationalSchool.isNotEmpty
                                                ? filterDetails.nationalSchool
                                                : null,
                                        hint: Text(
                                          l10n.selectSchool,
                                          style: context.regular14(color: ColorManager.disabledText),
                                        ),
                                        items:
                                            (filterDetails.job == "Provincial School Teacher"
                                                    ? filterDetails.kottasa.isNotEmpty
                                                        ? filterDetails.kottasaSchools[filterDetails.kottasa] ?? []
                                                        : <String>[]
                                                    : filterDetails.kottasaForNationalScl.isNotEmpty
                                                    ? filterDetails.kottasaNationalSchools[filterDetails
                                                            .kottasaForNationalScl] ??
                                                        []
                                                    : <String>[])
                                                .map(
                                                  (school) => DropdownMenuItem(
                                                    value: school,
                                                    child: Text(
                                                      TranslationService.translate(context, school),
                                                      style: context.regular14(color: ColorManager.blackMedium),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            filterDetails.job == "Provincial School Teacher"
                                                ? filterDetails.school = value ?? ''
                                                : filterDetails.nationalSchool = value ?? '';
                                            schoolError = null;
                                          });
                                        },
                                        dropdownColor: ColorManager.kPrimaryBlack,
                                        underline: const SizedBox(),
                                        icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                        isExpanded: true,
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: schoolError != null ? 4.0 : 4.0, left: 5.0),
                                    child: Text(
                                      schoolError != null ? schoolError! : '',
                                      style: const TextStyle(color: Colors.red, fontSize: 12.0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: context.verticalSize(30)),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    (filterDetails.job == "Provincial School Teacher" ||
                                            filterDetails.job == "National School Teacher")
                                        ? l10n.setupSubjectDetails
                                        : l10n.setupGradeDetails,
                                    style: context.semiBold14(color: ColorManager.blackMedium),
                                  ),
                                ),
                                SizedBox(height: context.verticalSize(8)),
                                Container(
                                  height: context.verticalSize(40),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: ColorManager.white10,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: DropdownButton<String>(
                                    value:
                                        (filterDetails.job == "Provincial School Teacher" ||
                                                filterDetails.job == "National School Teacher")
                                            ? filterDetails.scheme.isNotEmpty
                                                ? filterDetails.scheme
                                                : null
                                            : filterDetails.grade.isNotEmpty
                                            ? filterDetails.grade
                                            : null,
                                    hint: Text(
                                      (filterDetails.job == "Provincial School Teacher" ||
                                              filterDetails.job == "National School Teacher")
                                          ? l10n.selectScheme
                                          : l10n.selectGrade,
                                      style: context.regular14(color: ColorManager.disabledText),
                                    ),
                                    items:
                                        ((filterDetails.job == "Provincial School Teacher" ||
                                                    filterDetails.job == "National School Teacher")
                                                ? filterDetails.schemes
                                                : filterDetails.gradeList)
                                            .map(
                                              (value) => DropdownMenuItem(
                                                value: value,
                                                child: Text(
                                                  TranslationService.translate(context, value),
                                                  style: context.regular14(color: ColorManager.disabledText),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) async {
                                      setState(() {
                                        if (filterDetails.job == "Provincial School Teacher" ||
                                            filterDetails.job == "National School Teacher") {
                                          filterDetails.scheme = value ?? '';
                                          filterDetails.subject = ''; // reset subject
                                          if (filterDetails.scheme != "PRIMARY") {
                                            subjectError = "Subject also required";
                                          } else {
                                            subjectError = null;
                                          }
                                        } else {
                                          filterDetails.grade = value ?? '';
                                        }
                                        _loadingField = 'scheme_grade';
                                      });
                                      if ((filterDetails.job == "Provincial School Teacher" ||
                                              filterDetails.job == "National School Teacher") &&
                                          value != null) {
                                        await StaticDataService.fetchSubjects(filterDetails, value);
                                      }
                                      if (mounted) {
                                        setState(() {
                                          _loadingField = null;
                                        });
                                      }
                                    },
                                    dropdownColor: ColorManager.kPrimaryBlack,
                                    underline: const SizedBox(),
                                    icon: _buildDropdownIcon(_loadingField == 'scheme_grade'),
                                    isExpanded: true,
                                  ),
                                ),

                                SizedBox(
                                  height: context.verticalSize(
                                    (filterDetails.scheme != "PRIMARY" && filterDetails.scheme.isNotEmpty) ||
                                            filterDetails.grade.isNotEmpty
                                        ? 20
                                        : 0,
                                  ),
                                ),

                                // Subject Dropdown
                                ((filterDetails.scheme != "PRIMARY" && filterDetails.scheme.isNotEmpty) &&
                                        (filterDetails.job == "Provincial School Teacher" ||
                                            filterDetails.job == "National School Teacher"))
                                    ? Container(
                                      height: context.verticalSize(40),
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: ColorManager.white10,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: DropdownButton<String>(
                                        value: filterDetails.subject.isNotEmpty ? filterDetails.subject : null,
                                        hint: Text(
                                          l10n.selectSubject,
                                          style: context.regular14(color: ColorManager.disabledText),
                                        ),
                                        items:
                                            (filterDetails.scheme.isNotEmpty
                                                    ? filterDetails.schemeSubjects[filterDetails.scheme] ?? []
                                                    : <String>[])
                                                .map(
                                                  (subject) => DropdownMenuItem(
                                                    value: subject,
                                                    child: Text(
                                                      TranslationService.translate(context, subject),
                                                      style: context.regular14(color: ColorManager.blackMedium),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            filterDetails.subject = value ?? '';
                                            subjectError = null;
                                          });
                                        },
                                        dropdownColor: ColorManager.kPrimaryBlack,
                                        underline: const SizedBox(),
                                        icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                        isExpanded: true,
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top:
                                          (filterDetails.job == "Provincial School Teacher" ||
                                                  filterDetails.job == "National School Teacher")
                                              ? subjectError != null
                                                  ? 4.0
                                                  : 4.0
                                              : gradeError != null
                                              ? 4.0
                                              : 4.0,
                                      left: 5.0,
                                    ),
                                    child: Text(
                                      (filterDetails.job == "Provincial School Teacher" ||
                                              filterDetails.job == "National School Teacher")
                                          ? subjectError != null
                                              ? subjectError!
                                              : ''
                                          : gradeError != null
                                          ? gradeError!
                                          : '',
                                      style: const TextStyle(color: Colors.red, fontSize: 12.0),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: context.verticalSize(
                                    (filterDetails.scheme != "PRIMARY" && filterDetails.scheme.isNotEmpty) ||
                                            filterDetails.grade.isNotEmpty
                                        ? subjectError != null
                                            ? 12
                                            : 2
                                        : 0,
                                  ),
                                ),
                                (filterDetails.job == "Provincial School Teacher" ||
                                        filterDetails.job == "National School Teacher")
                                    ? Column(
                                      children: [
                                        Container(
                                          height: context.verticalSize(40),
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: ColorManager.white10,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: DropdownButton<String>(
                                            value:
                                                filterDetails.subjectMedium.isNotEmpty
                                                    ? filterDetails.subjectMedium
                                                    : null,
                                            hint: Text(
                                              l10n.selectSubjectMedium,
                                              style: context.regular14(color: ColorManager.disabledText),
                                            ),
                                            items:
                                                ["Sinhala", "English", "Tamil"]
                                                    .map(
                                                      (medium) => DropdownMenuItem(
                                                        value: medium,
                                                        child: Text(
                                                          TranslationService.translate(context, medium),
                                                          style: context.regular14(color: ColorManager.blackMedium),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                filterDetails.subjectMedium = value ?? '';
                                                subjectMediumError = null;
                                              });
                                            },
                                            dropdownColor: ColorManager.kPrimaryBlack,
                                            underline: const SizedBox(),
                                            icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                            isExpanded: true,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              top: subjectMediumError != null ? 4.0 : 4.0,
                                              left: 5.0,
                                            ),
                                            child: Text(
                                              subjectMediumError != null ? subjectMediumError! : '',
                                              style: const TextStyle(color: Colors.red, fontSize: 12.0),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    : const SizedBox.shrink(),

                                SizedBox(height: context.verticalSize(20)),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    l10n.selectYourChoice,
                                    style: context.semiBold14(color: ColorManager.blackMedium),
                                  ),
                                ),
                                SizedBox(height: context.verticalSize(10)),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    l10n.transferChoice1,
                                    style: context.semiBold14(color: ColorManager.grayText),
                                  ),
                                ),
                                SizedBox(height: context.verticalSize(8)),
                                Container(
                                  height: context.verticalSize(40),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: ColorManager.white10,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: DropdownButton<String>(
                                    value: filterDetails.choice1.isNotEmpty ? filterDetails.choice1 : null,
                                    hint: Text(
                                      l10n.selectChoice1,
                                      style: context.regular14(color: ColorManager.disabledText),
                                    ),
                                    items:
                                        filterDetails.allDistricts
                                            .map(
                                              (district) => DropdownMenuItem(
                                                value: district,
                                                child: Text(
                                                  TranslationService.translate(context, district),
                                                  style: context.regular14(color: ColorManager.blackMedium),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        filterDetails.choice1 = value ?? '';
                                        filterDetails.choice2 = '';
                                        filterDetails.choice3 = '';
                                        choiceError = null;
                                      });
                                    },
                                    dropdownColor: ColorManager.kPrimaryBlack,
                                    underline: const SizedBox(),
                                    icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                    isExpanded: true,
                                  ),
                                ),
                                SizedBox(height: context.verticalSize(filterDetails.choice1.isNotEmpty ? 10 : 0)),
                                filterDetails.choice1.isNotEmpty
                                    ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        l10n.transferChoice2,
                                        style: context.semiBold14(color: ColorManager.grayText),
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                                SizedBox(height: context.verticalSize(filterDetails.choice1.isNotEmpty ? 8 : 0)),

                                filterDetails.choice1.isNotEmpty
                                    ? Container(
                                      height: context.verticalSize(40),
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: ColorManager.white10,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: DropdownButton<String>(
                                        value: filterDetails.choice2.isNotEmpty ? filterDetails.choice2 : null,
                                        hint: Text(
                                          l10n.selectChoice2,
                                          style: context.regular14(color: ColorManager.disabledText),
                                        ),
                                        items:
                                            filterDetails.allDistricts
                                                .map(
                                                  (district) => DropdownMenuItem(
                                                    value: district,
                                                    child: Text(
                                                      TranslationService.translate(context, district),
                                                      style: context.regular14(color: ColorManager.blackMedium),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            filterDetails.choice2 = value ?? '';
                                            filterDetails.choice3 = '';
                                          });
                                        },
                                        dropdownColor: ColorManager.kPrimaryBlack,
                                        underline: const SizedBox(),
                                        icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                        isExpanded: true,
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                                SizedBox(height: context.verticalSize(filterDetails.choice2.isNotEmpty ? 10 : 0)),
                                filterDetails.choice2.isNotEmpty
                                    ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        l10n.transferChoice3,
                                        style: context.semiBold14(color: ColorManager.grayText),
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                                SizedBox(height: context.verticalSize(filterDetails.choice2.isNotEmpty ? 20 : 0)),

                                filterDetails.choice2.isNotEmpty
                                    ? Container(
                                      height: context.verticalSize(40),
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: ColorManager.white10,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: DropdownButton<String>(
                                        value: filterDetails.choice3.isNotEmpty ? filterDetails.choice3 : null,
                                        hint: Text(
                                          l10n.selectChoice3,
                                          style: context.regular14(color: ColorManager.disabledText),
                                        ),
                                        items:
                                            filterDetails.allDistricts
                                                .map(
                                                  (district) => DropdownMenuItem(
                                                    value: district,
                                                    child: Text(
                                                      TranslationService.translate(context, district),
                                                      style: context.regular14(color: ColorManager.blackMedium),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            filterDetails.choice3 = value ?? '';
                                          });
                                        },
                                        dropdownColor: ColorManager.kPrimaryBlack,
                                        underline: const SizedBox(),
                                        icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                        isExpanded: true,
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: choiceError != null ? 4.0 : 4.0, left: 5.0),
                                    child: Text(
                                      choiceError != null ? choiceError! : '',
                                      style: const TextStyle(color: Colors.red, fontSize: 12.0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: context.verticalSize(30)),
                                CenterTextIconButton(
                                  onPress: () async {
                                    if (informationFormKey.currentState!.validate() &&
                                        (accProvider.contactController.text.isNotEmpty ||
                                            accProvider.contactController.text.length > 10 ||
                                            accProvider.contactController.text.length < 12) &&
                                        (filterDetails.job == "Provincial School Teacher"
                                            ? filterDetails.school != ''
                                            : filterDetails.job == "National School Teacher"
                                            ? filterDetails.nationalSchool != ''
                                            : (filterDetails.job == "Nurse" ||
                                                filterDetails.job == "Hospital Attendant" ||
                                                filterDetails.job == "Public Health Inspector" ||
                                                filterDetails.job == "Public Health Midwife")
                                            ? filterDetails.officeForNurse != ''
                                            : (filterDetails.job == "Management Assistant" ||
                                                filterDetails.job == "Development Officer" ||
                                                filterDetails.job == "Administrative Officer")
                                            ? filterDetails.officeForMA != ''
                                            : filterDetails.job ==
                                                "MA (Pradesiya Sabha)"
                                            ? filterDetails.officeForPS != ''
                                            : filterDetails.job == "Police Officer"
                                            ? filterDetails.policeStations != ''
                                            : filterDetails.gramaNiladhariDivision != '') &&
                                        ((filterDetails.job == "Provincial School Teacher" ||
                                                filterDetails.job == "National School Teacher")
                                            ? (filterDetails.scheme != "PRIMARY"
                                                ? filterDetails.subject != ''
                                                : filterDetails.scheme != '')
                                            : filterDetails.grade != "") &&
                                        ((filterDetails.job == "Provincial School Teacher" ||
                                                filterDetails.job == "National School Teacher")
                                            ? filterDetails.subjectMedium != ''
                                            : true) &&
                                        filterDetails.choice1 != '') {
                                      if (hasUnsavedChanges ||
                                          accProvider.appUser?.displayName !=
                                              "${accProvider.firstNameController.text.trim()} ${accProvider.lastNameController.text.trim()}" ||
                                          accProvider.appUser?.phone != accProvider.contactController.text.trim() ||
                                          accProvider.appUser?.whatsapp != accProvider.whatsappController.text.trim() ||
                                          accProvider.appUser?.note != accProvider.noteController.text.trim() ||
                                          accProvider.appUser?.isPhoneHide != accProvider.isContactVisible ||
                                          accProvider.appUser?.isWhatsappHide != accProvider.isWhatsappVisible ||
                                          accProvider.appUser?.isSchoolHide != accProvider.isSchoolVisible ||
                                          selectedImage != null) {
                                        print(accProvider.firstNameController.text.isNotEmpty);
                                        final summary = _buildFilterSummary(filterDetails);

                                        if (summary == 'No changes selected.') {
                                          toastErrorMessage("Please select at least one changes before saving.");
                                          return;
                                        }

                                        final shouldSave = await _saveAlertDialog(
                                          context,
                                          'Confirm Changes',
                                          summary,
                                          l10n.save,
                                        );

                                        if (shouldSave == true) {
                                          await acc.updateAccount(filterDetails);
                                        } else {
                                          print('Save action canceled by user.');
                                        }
                                      } else {
                                        print('No changes to save.');
                                        toastErrorMessage("Please select at least one changes before saving.");
                                      }
                                    }
                                    if (acc.contactController.text.isEmpty ||
                                        acc.contactController.text.length < 10 ||
                                        acc.contactController.text.length > 12) {
                                      setState(() {
                                        contactError = 'Incorrect contact number';
                                      });
                                    } else if ((filterDetails.job == "Provincial School Teacher" &&
                                            filterDetails.school == '') ||
                                        (filterDetails.job == "National School Teacher" &&
                                            filterDetails.nationalSchool == '')) {
                                      setState(() {
                                        schoolError = l10n.reqSelectSchool;
                                      });
                                    } else {
                                      setState(() {
                                        schoolError = '';
                                      });
                                    }
                                    if (filterDetails.job != "Provincial School Teacher" &&
                                        filterDetails.job != "National School Teacher" &&
                                        filterDetails.officeForNurse == '' &&
                                        filterDetails.officeForMA == '' &&
                                        filterDetails.officeForPS == '' &&
                                        filterDetails.policeStations == '' &&
                                        filterDetails.gramaNiladhariDivision == '') {
                                      setState(() {
                                        schoolError = l10n.reqSelectOffice;
                                      });
                                    }
                                    if (filterDetails.scheme != "PRIMARY" &&
                                        filterDetails.subject == '' &&
                                        filterDetails.grade == "") {
                                      setState(() {
                                        subjectError = l10n.reqSelectSubject;
                                      });
                                    } else {
                                      setState(() {
                                        subjectError = '';
                                      });
                                    }
                                    if ((filterDetails.job == "Provincial School Teacher" ||
                                            filterDetails.job == "National School Teacher") &&
                                        filterDetails.subjectMedium == '') {
                                      setState(() {
                                        subjectMediumError = l10n.reqSelectMedium;
                                      });
                                    } else {
                                      setState(() {
                                        subjectMediumError = null;
                                      });
                                    }
                                    if (filterDetails.choice1 == '') {
                                      setState(() {
                                        choiceError = l10n.reqSelectChoice;
                                      });
                                    } else {
                                      setState(() {
                                        choiceError = '';
                                      });
                                    }
                                  },
                                  buttonText: l10n.saveChanges,
                                  gradientColors:
                                      hasUnsavedChanges ? ColorManager.gradientButtons2 : ColorManager.gradientGray,
                                ),
                                SizedBox(height: context.verticalSize(40)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (_isBottomSheetVisible)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(color: Colors.black.withOpacity(0.5)),
                      ),
                    ),
                ],
              ),
    );
  }
}
