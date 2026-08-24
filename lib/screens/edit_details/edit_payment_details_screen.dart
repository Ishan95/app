import 'dart:io';
import 'dart:ui';

import 'package:app/app/export.dart';
import 'package:app/app/utils/context_helper.dart';
import 'package:app/app/widgets/show_confirmation_alert.dart';
import 'package:app/providers/account_provider.dart';
import 'package:app/screens/image/custom_camera_nw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:app/l10n/app_localizations.dart';

class EditPaymentDetailsScreen extends StatefulWidget {
  const EditPaymentDetailsScreen({super.key});

  @override
  State<EditPaymentDetailsScreen> createState() => _EditPaymentDetailsScreenState();
}

class _EditPaymentDetailsScreenState extends State<EditPaymentDetailsScreen> {
  final informationFormKey = GlobalKey<FormState>();
  String? refNoError;
  String? accountNumberError;
  String? nameError;
  String? amountError;
  String? serviceProviderError;
  File? selectedImage;
  bool _isBottomSheetVisible = false;
  DateTime? _selectedDate;
  String? _dateErrorText;

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dateErrorText = null;
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorManager.kPrimaryBlack,
      appBar: AppBar(
        backgroundColor: ColorManager.white,
        elevation: 0.5,
        title: Text(l10n.editPaymentInfo, style: context.semiBold20(color: ColorManager.blackMedium)),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back, color: ColorManager.blackMedium),
        ),
      ),
      body: Stack(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.verticalSize(20)),
                        Text(l10n.transferDate, style: context.semiBold14(color: ColorManager.blackMedium)),
                        SizedBox(height: context.verticalSize(8)),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            width: double.infinity,
                            height: context.verticalSize(40),
                            decoration: BoxDecoration(
                              color: ColorManager.whiteddd,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              _selectedDate != null ? '${_selectedDate!.toLocal()}'.split(' ')[0] : l10n.transferDate,
                              style: TextStyle(
                                color: _selectedDate != null ? ColorManager.blackMedium : ColorManager.grayText,
                                fontSize: context.fontSize(14),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        if (_dateErrorText != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4, left: 8),
                              child: Text(
                                _dateErrorText!,
                                style: TextStyle(color: Colors.red, fontSize: context.fontSize(12)),
                              ),
                            ),
                          ),
                        SizedBox(height: context.verticalSize(20)),
                        Text(l10n.refNo, style: context.semiBold14(color: ColorManager.blackMedium)),
                        SizedBox(height: context.verticalSize(8)),
                        CustomTextField(
                          radius: 30,
                          height: context.verticalSize(40),
                          controller: acc.refNoController,
                          inputType: TextInputType.name,
                          hintText: l10n.refNo,
                          validator: (value) {
                            if (acc.refNoController.text.isEmpty) {
                              setState(() {
                                refNoError = l10n.reqRefNo;
                              });
                              return '';
                            }
                            setState(() {
                              refNoError = null;
                            });
                            return null;
                          },
                          errorMessage: refNoError,
                        ),
                        Text(l10n.accountNumber, style: context.semiBold14(color: ColorManager.blackMedium)),
                        SizedBox(height: context.verticalSize(8)),
                        CustomTextField(
                          radius: 30,
                          height: context.verticalSize(40),
                          controller: acc.accountNumberController,
                          inputType: TextInputType.name,
                          hintText: l10n.accountNumber,
                          validator: (value) {
                            if (acc.accountNumberController.text.isEmpty) {
                              setState(() {
                                accountNumberError = l10n.reqAccountNumber;
                              });
                              return '';
                            }
                            setState(() {
                              accountNumberError = null;
                            });
                            return null;
                          },
                          errorMessage: accountNumberError,
                        ),
                        Text(l10n.senderName, style: context.semiBold14(color: ColorManager.blackMedium)),
                        SizedBox(height: context.verticalSize(8)),
                        CustomTextField(
                          radius: 30,
                          height: context.verticalSize(40),
                          controller: acc.senderNameController,
                          inputType: TextInputType.name,
                          hintText: l10n.name,
                          validator: (value) {
                            if (acc.senderNameController.text.isEmpty) {
                              setState(() {
                                nameError = l10n.reqName;
                              });
                              return '';
                            } else if ((value?.length ?? 0) > 100) {
                              setState(() {
                                nameError = l10n.reqNameLength;
                              });
                              return '';
                            }
                            setState(() {
                              nameError = null;
                            });
                            return null;
                          },
                          errorMessage: nameError,
                        ),
                        Text(l10n.amount, style: context.semiBold14(color: ColorManager.blackMedium)),
                        SizedBox(height: context.verticalSize(8)),
                        CustomTextField(
                          radius: 30,
                          height: context.verticalSize(40),
                          controller: acc.amountController,
                          inputType: TextInputType.number,
                          hintText: l10n.amount,
                          validator: (value) {
                            if (acc.amountController.text.isEmpty) {
                              setState(() {
                                amountError = l10n.reqValidAmount;
                              });
                              return '';
                            }
                            setState(() {
                              amountError = null;
                            });
                            return null;
                          },
                          errorMessage: amountError,
                        ),

                        Text(l10n.serviceProvider, style: context.semiBold14(color: ColorManager.blackMedium)),
                        SizedBox(height: context.verticalSize(8)),
                        CustomTextField(
                          radius: 30,
                          height: context.verticalSize(40),
                          controller: acc.serviceProviderController,
                          inputType: TextInputType.name,
                          hintText: l10n.serviceProvider,
                          validator: (value) {
                            if (acc.serviceProviderController.text.isEmpty) {
                              setState(() {
                                serviceProviderError = l10n.reqServiceProvider;
                              });
                              return '';
                            }
                            setState(() {
                              serviceProviderError = null;
                            });
                            return null;
                          },
                          errorMessage: serviceProviderError,
                        ),
                        SizedBox(height: context.verticalSize(8)),
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (selectedImage != null) {
                                  _confirmRemoveImage(l10n);
                                }
                              },
                              child: Container(
                                width: context.screenWidth,
                                height: context.verticalSize(200),
                                decoration: BoxDecoration(
                                  color: ColorManager.whiteddd,
                                  image:
                                      selectedImage != null
                                          ? DecorationImage(image: FileImage(selectedImage!), fit: BoxFit.cover)
                                          : null,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            selectedImage == null
                                ? Positioned(
                                  bottom: context.verticalSize(90),
                                  left: context.screenWidth * 0.4,
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
                                                Navigator.pop(context);
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
                                    child: Icon(Icons.add_circle, size: 28, color: ColorManager.kPrimary),
                                    // SvgPicture.asset(
                                    //   Assets.editProfileAddSVG,
                                    // ),
                                  ),
                                )
                                : SizedBox.shrink(),
                          ],
                        ),
                        SizedBox(height: context.verticalSize(50)),
                        CenterTextIconButton(
                          onPress: () async {
                            if (informationFormKey.currentState!.validate()) {
                              if (_selectedDate == null) {
                                setState(() {
                                  _dateErrorText = l10n.reqSelectDate;
                                });
                                return;
                              }
                              await acc.addPaymentDetails(_selectedDate!.toLocal(), selectedImage);
                            }
                          },
                          isGradientColor: true,
                          gradientColors: ColorManager.gradientButtons2,
                          buttonText: l10n.continueText,
                        ),
                        SizedBox(height: context.verticalSize(50)),
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
