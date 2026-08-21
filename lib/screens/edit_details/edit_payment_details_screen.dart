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

class EditPaymentDetailsScreen extends StatefulWidget {
  const EditPaymentDetailsScreen({super.key});

  @override
  State<EditPaymentDetailsScreen> createState() =>
      _EditPaymentDetailsScreenState();
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
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
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

      print('1212121212121212');
      if (croppedFile != null) {
        setState(() {
          selectedImage = File(croppedFile.path);
        });
        Navigator.pop(context);
      }
    }
  }

  void _confirmRemoveImage() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove photo?'),
            content: const Text(
              'Are you sure you want to remove the uploaded photo?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedImage = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Remove'),
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
    return Scaffold(
      backgroundColor: ColorManager.kPrimaryBlack,
      appBar: AppBar(
        backgroundColor: ColorManager.kPrimaryBlack,
        title: Text(
          "Edit Payment Information",
          style: context.semiBold20(color: ColorManager.white),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back, color: ColorManager.white),
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
                      child: Center(
                        child: SpinKitFadingCircle(
                          color: ColorManager.kPrimary,
                          size: 40,
                        ),
                      ),
                    );
                  }
                  return Form(
                    key: informationFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.verticalSize(20)),
                        Text(
                          "Transfer Date",
                          style: context.semiBold14(color: ColorManager.white),
                        ),
                        SizedBox(height: context.verticalSize(8)),
                        InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          width: double.infinity,
                          height: context.verticalSize(40),
                          decoration: BoxDecoration(
                            color: ColorManager.white101,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _selectedDate != null
                                ? '${_selectedDate!.toLocal()}'.split(' ')[0]
                                : 'Transfer Date',
                            style: TextStyle(
                              color: ColorManager.disabledText,
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
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: context.fontSize(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: context.verticalSize(20)),
                        Text(
                          "Ref No",
                          style: context.semiBold14(color: ColorManager.white),
                        ),
                        SizedBox(height: context.verticalSize(8)),
                        CustomTextField(
                          radius: 30,
                          height: context.verticalSize(40),
                          controller: acc.refNoController,
                          inputType: TextInputType.name,
                          hintText: 'Ref No',
                          validator: (value) {
                            if (acc.refNoController.text.isEmpty) {
                              setState(() {
                                refNoError = "Ref Number is required";
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
                        Text(
                          "Account Number",
                          style: context.semiBold14(color: ColorManager.white),
                        ),
                        SizedBox(height: context.verticalSize(8)),
                        CustomTextField(
                          radius: 30,
                          height: context.verticalSize(40),
                          controller: acc.accountNumberController,
                          inputType: TextInputType.name,
                          hintText: 'Account Number',
                          validator: (value) {
                            if (acc.accountNumberController.text.isEmpty) {
                              setState(() {
                                accountNumberError = "Account Number is required";
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
                        Text(
                          "Sender Name",
                          style: context.semiBold14(color: ColorManager.white),
                        ),
                        SizedBox(height: context.verticalSize(8)),
                        CustomTextField(
                          radius: 30,
                          height: context.verticalSize(40),
                          controller: acc.senderNameController,
                          inputType: TextInputType.name,
                          hintText: 'Name',
                          validator: (value) {
                            if (acc.senderNameController.text.isEmpty) {
                              setState(() {
                                nameError = "Name is required";
                              });
                              return '';
                            } else if ((value?.length ?? 0) > 100) {
                              setState(() {
                                nameError = "Must be 1–100 characters";
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
                        Text(
                          "Amount",
                          style: context.semiBold14(color: ColorManager.white),
                        ),
                        SizedBox(height: context.verticalSize(8)),
                        CustomTextField(
                          radius: 30,
                          height: context.verticalSize(40),
                          controller: acc.amountController,
                          inputType: TextInputType.number,
                          hintText: 'Amount',
                          validator: (value) {
                            if (acc.amountController.text.isEmpty) {
                              setState(() {
                                amountError = "Input valid amount";
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

                        Text(
                          "Service Provider",
                          style: context.semiBold14(color: ColorManager.white),
                        ),
                        SizedBox(height: context.verticalSize(8)),
                        CustomTextField(
                          radius: 30,
                          height: context.verticalSize(40),
                          controller: acc.serviceProviderController,
                          inputType: TextInputType.name,
                          hintText: 'Service Provider',
                          validator: (value) {
                            if (acc.serviceProviderController.text.isEmpty) {
                              setState(() {
                                serviceProviderError = "Service Provider is required";
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
                                  _confirmRemoveImage();
                                }
                              },
                              child: Container(
                                width: context.screenWidth,
                                height: context.verticalSize(200),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  image:
                                      selectedImage != null
                                          ? DecorationImage(
                                            image: FileImage(selectedImage!),
                                            fit: BoxFit.cover,
                                          )
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
                                      setState(
                                        () => _isBottomSheetVisible = true,
                                      );
                                      ConfirmationAlert.showConfirmationAlert(
                                        context: context,
                                        title: 'Choose photo source',
                                        message: "Camera",
                                        messageColor:
                                            ColorManager.kAleartTextColor,
                                        onTap2: () {
                                          setState(
                                            () => _isBottomSheetVisible = false,
                                          );
                                          Navigator.of(context)
                                              .push(
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => CustomCameraNw(
                                                        onImageSelected: (
                                                          File image,
                                                        ) {
                                                          setState(() {
                                                            selectedImage =
                                                                image; // Update parent state
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
                                        actionText: "Select from gallery",
                                        actionColor:
                                            ColorManager.kAleartTextColor,
                                        isCancelVisible: true,
                                        cancelColor:
                                            ColorManager.kAleartCancelTextColor,
                                        onTap: () {
                                          setState(
                                            () => _isBottomSheetVisible = false,
                                          );
                                          print(
                                            '&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&77777778899999',
                                          );
                                          _pickImage();
                                        },
                                        cancelOnTap: () {
                                          setState(
                                            () => _isBottomSheetVisible = false,
                                          );
                                          Navigator.pop(context);
                                        },
                                        onDismiss: () {
                                          setState(
                                            () => _isBottomSheetVisible = false,
                                          );
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.add_circle,
                                      size: 28,
                                      color: ColorManager.gray,
                                    ),
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
                            print('###########################');
                              await acc.addPaymentDetails(_selectedDate!.toLocal(), selectedImage);
                            }
                          },
                          isGradientColor: true,
                          gradientColors: ColorManager.gradientButtons2,
                          // isLoading: auth.getisCreatingUser,
                          buttonText: 'Continue',
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
                filter: ImageFilter.blur(
                  sigmaX: 5.0,
                  sigmaY: 5.0,
                ), // Set blur amount here
                child: Container(
                  color: Colors.black.withOpacity(0.5), // Optional overlay
                ),
              ),
            ),
        ],
      ),
    );
  }
}
