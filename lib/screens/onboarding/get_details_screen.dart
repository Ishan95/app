import 'package:app/app/models/filter_model.dart';
import 'package:app/app/utils/custom_toast.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/service_providers/firebase_service.dart';
import 'package:app/providers/service_providers/static_data_service.dart';
import 'package:app/screens/home/home.dart';
import 'package:app/screens/onboarding/verify_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:app/app/export.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/app/utils/translation_service.dart';

class GetDetailsScreen extends StatefulWidget {
  final bool isSignupEmail;
  const GetDetailsScreen({super.key, required this.isSignupEmail});

  @override
  State<GetDetailsScreen> createState() => _GetDetailsScreenState();
}

class _GetDetailsScreenState extends State<GetDetailsScreen> {
  final informationFormKey = GlobalKey<FormState>();

  final GlobalKey _jobDropdownKey = GlobalKey();

  int currentStep = 0; // Tracks the wizard steps (0, 1, 2)

  bool isSelected = false;
  bool isWhatsappSelected = false;
  bool isSchoolSelected = false;
  bool isEnable = false;
  bool isDataLoading = true;

  bool _showAllJobCategories = false;
  bool _isDistrictLoading = false;
  bool _isKalapaInstLoading = false;
  bool _isKottasaOfficeLoading = false;
  bool _isSchoolLoading = false;
  bool _isSubjectLoading = false;

  String? firstNameError;
  String? lastNameError;
  String? emailError;
  // String? idCardError;
  String? contactError;
  String? whatsappError;
  String? passwordError;
  String? confirmPasswordError;

  String? jobError;
  String? provinceError;
  String? districtError;
  String? kalapaInstitutionError;
  String? kottasaOfficeError;
  String? schoolError;
  String? schemeError;
  String? subjectError;
  String? subjectMediumError;
  // String? gradeError;
  String? choiceError;

  bool _obscureText = true;
  bool _obscureTextConfirmPassword = true;
  // DateTime? _selectedDate;
  // String? _dobErrorText;

  FilterModel filterDetails = FilterModel();

  @override
  void initState() {
    super.initState();
    _initFcm();
    _loadRootStaticData();
  }

  Future<void> _loadRootStaticData() async {
    await StaticDataService.loadRootData(filterDetails);
    if (mounted) {
      setState(() {
        isDataLoading = false;
      });
    }
  }

  Future<void> _initFcm() async {
    String? token = await FirebaseService.getFcmToken();
    print('token');
    print(token);
    print('token');
  }

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate ?? DateTime.now(),
  //     firstDate: DateTime(1950),
  //     lastDate: DateTime.now(),
  //   );
  //   if (pickedDate != null) {
  //     setState(() {
  //       _dobErrorText = null;
  //       _selectedDate = pickedDate;
  //     });
  //   }
  // }

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

  void _openJobDropdown() {
    final BuildContext? context = _jobDropdownKey.currentContext;
    if (context != null) {
      GestureDetector? detector;
      InkWell? inkWell;

      void searchForTap(BuildContext ctx) {
        ctx.visitChildElements((Element element) {
          if (element.widget is GestureDetector) {
            detector = element.widget as GestureDetector;
          } else if (element.widget is InkWell) {
            inkWell = element.widget as InkWell;
          } else {
            searchForTap(element);
          }
        });
      }

      searchForTap(context);

      if (detector != null && detector!.onTap != null) {
        detector!.onTap!();
      } else if (inkWell != null && inkWell!.onTap != null) {
        inkWell!.onTap!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorManager.kPrimaryBlack,
      body: SafeArea(
        child:
            isDataLoading
                ? Center(child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 40))
                : SingleChildScrollView(
                  child: Padding(
                    padding: context.padding(horizontal: 24, top: 14, bottom: 44),
                    child: Consumer<AuthenticationProvider>(
                      builder: (context, auth, child) {
                        return Form(
                          key: informationFormKey,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (currentStep > 0) {
                                        setState(() {
                                          currentStep--;
                                        });
                                      } else {
                                        auth.clearData();
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    icon: Icon(Icons.arrow_back, color: ColorManager.blackMedium),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          l10n.addBasicInfo,
                                          style: context.boldNunito30(color: ColorManager.blackMedium),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: context.verticalSize(10)),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  l10n.welcomeText,
                                  style: context.regular16(color: ColorManager.grayText),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: context.verticalSize(23)),

                              // STEP 0: NAME, EMAIL, CONTACT, WHATSAPP
                              if (currentStep == 0) ...[
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
                                  controller: auth.firstNameController,
                                  inputType: TextInputType.name,
                                  hintText: l10n.firstName,
                                  validator: (value) {
                                    if (auth.firstNameController.text.isEmpty) {
                                      setState(() {
                                        firstNameError = l10n.reqFirstName;
                                      });
                                      return '';
                                    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value!)) {
                                      setState(() {
                                        firstNameError = l10n.reqValidFirstName;
                                      });
                                      return '';
                                    } else if (value.length > 30) {
                                      setState(() {
                                        firstNameError = "Must be 1–30 characters";
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
                                  controller: auth.lastNameController,
                                  inputType: TextInputType.name,
                                  hintText: l10n.lastName,
                                  validator: (value) {
                                    if (auth.lastNameController.text.isEmpty) {
                                      setState(() {
                                        lastNameError = l10n.reqLastName;
                                      });
                                      return '';
                                    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value!)) {
                                      setState(() {
                                        lastNameError = l10n.reqValidLastName;
                                      });
                                      return '';
                                    } else if (value.length > 30) {
                                      setState(() {
                                        lastNameError = "Must be 1–30 characters";
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
                                SizedBox(height: context.verticalSize(8)),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(l10n.email, style: context.semiBold14(color: ColorManager.blackMedium)),
                                ),
                                SizedBox(height: context.verticalSize(8)),
                                CustomTextField(
                                  radius: 30,
                                  height: context.verticalSize(40),
                                  controller: auth.emailController,
                                  inputType: TextInputType.emailAddress,
                                  hintText: l10n.emailAddress,
                                  readOnly: auth.isGoogleAuth,
                                  validator: (value) {
                                    if (auth.emailController.text.isEmpty) {
                                      setState(() {
                                        emailError = l10n.reqEmail;
                                      });
                                      return '';
                                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                                      setState(() {
                                        emailError = l10n.reqValidEmail;
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      emailError = null;
                                    });
                                    return null;
                                  },
                                  errorMessage: emailError,
                                ),

                                // DOB COMMENTED OUT
                                // SizedBox(height: context.verticalSize(30)),
                                // Align(
                                //   alignment: Alignment.centerLeft,
                                //   child: Text(l10n.dob, style: context.semiBold14(color: ColorManager.blackMedium)),
                                // ),
                                // SizedBox(height: context.verticalSize(8)),
                                // InkWell(
                                //   onTap: () => _selectDate(context),
                                //   child: Container(
                                //     width: double.infinity,
                                //     height: context.verticalSize(40),
                                //     decoration: BoxDecoration(
                                //       color: ColorManager.white101,
                                //       borderRadius: BorderRadius.circular(20),
                                //     ),
                                //     alignment: Alignment.centerLeft,
                                //     padding: const EdgeInsets.symmetric(horizontal: 16),
                                //     child: Text(
                                //       _selectedDate != null
                                //           ? '${_selectedDate!.toLocal()}'.split(' ')[0]
                                //           : l10n.birthdate,
                                //       style: TextStyle(color: ColorManager.blackMedium, fontSize: context.fontSize(14)),
                                //     ),
                                //   ),
                                // ),
                                // if (_dobErrorText != null)
                                //   Align(
                                //     alignment: Alignment.centerLeft,
                                //     child: Padding(
                                //       padding: const EdgeInsets.only(top: 4, left: 8),
                                //       child: Text(
                                //         _dobErrorText!,
                                //         style: TextStyle(color: Colors.red, fontSize: context.fontSize(12)),
                                //       ),
                                //     ),
                                //   ),

                                // ID CARD COMMENTED OUT
                                // SizedBox(height: context.verticalSize(30)),
                                // Align(
                                //   alignment: Alignment.centerLeft,
                                //   child: Text(
                                //     l10n.idCardNumber,
                                //     style: context.semiBold14(color: ColorManager.blackMedium),
                                //   ),
                                // ),
                                // SizedBox(height: context.verticalSize(8)),
                                // CustomTextField(
                                //   radius: 30,
                                //   height: context.verticalSize(40),
                                //   controller: auth.idCardController,
                                //   inputType: TextInputType.emailAddress,
                                //   hintText: l10n.idCardNumber,
                                //   validator: (value) {
                                //     if (auth.idCardController.text.isEmpty) {
                                //       setState(() {
                                //         idCardError = l10n.reqId;
                                //       });
                                //       return '';
                                //     } else if (value!.length < 5 || value.length > 20) {
                                //       setState(() {
                                //         idCardError = l10n.reqValidId;
                                //       });
                                //       return '';
                                //     }
                                //     setState(() {
                                //       idCardError = null;
                                //     });
                                //     return null;
                                //   },
                                //   errorMessage: idCardError,
                                // ),
                                SizedBox(height: context.verticalSize(8)),
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
                                          isSelected = !isSelected;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              l10n.hide,
                                              style: context.semiBold14(
                                                color: isSelected ? ColorManager.disabledText : ColorManager.kPrimary,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: context.horizontalSize(10)),
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color: isSelected ? ColorManager.disabledText : Colors.transparent,
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
                                  controller: auth.contactController,
                                  inputType: TextInputType.number,
                                  hintText: l10n.contactNumber,
                                  validator: (value) {
                                    if (auth.contactController.text.isEmpty) {
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
                                SizedBox(height: context.verticalSize(8)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          l10n.whatsappOptional,
                                          style: context.semiBold14(color: ColorManager.blackMedium),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isWhatsappSelected = !isWhatsappSelected;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              l10n.hide,
                                              style: context.semiBold14(
                                                color:
                                                    isWhatsappSelected
                                                        ? ColorManager.disabledText
                                                        : ColorManager.kPrimary,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: context.horizontalSize(10)),
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color:
                                                  isWhatsappSelected ? ColorManager.disabledText : Colors.transparent,
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
                                  controller: auth.whatsappController,
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

                                // if (!auth.isGoogleAuth) ...[
                                //   SizedBox(height: context.verticalSize(30)),
                                //   Align(
                                //     alignment: Alignment.centerLeft,
                                //     child: Text(l10n.password, style: context.semiBold14(color: ColorManager.grayText)),
                                //   ),
                                //   SizedBox(height: context.verticalSize(4)),
                                //   CustomTextField(
                                //     radius: 30,
                                //     controller: auth.passwordController,
                                //     inputType: TextInputType.visiblePassword,
                                //     obscure: _obscureText,
                                //     hintText: '*******',
                                //     validator: (value) {
                                //       if (value == null || value.isEmpty) {
                                //         setState(() {
                                //           passwordError = l10n.reqPassword;
                                //         });
                                //         return '';
                                //       } else if (value.length < 8) {
                                //         setState(() {
                                //           passwordError = l10n.reqPasswordLength;
                                //         });
                                //         return '';
                                //       } else if (value.length > 64) {
                                //         setState(() {
                                //           passwordError = "Password must be 8–64 characters long";
                                //         });
                                //         return '';
                                //       } else if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                                //         setState(() {
                                //           passwordError = "Must include at least one uppercase letter";
                                //         });
                                //         return '';
                                //       } else if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
                                //         setState(() {
                                //           passwordError = "Must include at least one number";
                                //         });
                                //         return '';
                                //       } else if (!RegExp(r'^(?=.*[!@#\$&*~%^()_\-+=<>?])').hasMatch(value)) {
                                //         setState(() {
                                //           passwordError = "Must include at least one special character";
                                //         });
                                //         return '';
                                //       }
                                //       setState(() {
                                //         passwordError = null;
                                //       });
                                //       return null;
                                //     },
                                //     errorMessage: passwordError,
                                //     suffixIcon: IconButton(
                                //       icon: Icon(
                                //         _obscureText ? Icons.visibility_off : Icons.visibility,
                                //         color: Colors.grey,
                                //       ),
                                //       onPressed: () {
                                //         setState(() {
                                //           _obscureText = !_obscureText;
                                //         });
                                //       },
                                //     ),
                                //   ),
                                //   SizedBox(height: context.verticalSize(4)),
                                //   Align(
                                //     alignment: Alignment.centerLeft,
                                //     child: Text(
                                //       l10n.reEnterPassword,
                                //       style: context.semiBold14(color: ColorManager.grayText),
                                //     ),
                                //   ),
                                //   SizedBox(height: context.verticalSize(4)),
                                //   CustomTextField(
                                //     radius: 30,
                                //     controller: auth.confirmPasswordController,
                                //     inputType: TextInputType.visiblePassword,
                                //     hintText: '*******',
                                //     obscure: _obscureTextConfirmPassword,
                                //     validator: (value) {
                                //       if (auth.confirmPasswordController.text.isEmpty) {
                                //         setState(() {
                                //           confirmPasswordError = l10n.reqPassword;
                                //         });
                                //         return '';
                                //       } else if (value != auth.passwordController.text) {
                                //         setState(() {
                                //           confirmPasswordError = l10n.reqPasswordMatch;
                                //         });
                                //         return '';
                                //       }
                                //       setState(() {
                                //         confirmPasswordError = null;
                                //       });
                                //       return null;
                                //     },
                                //     errorMessage: confirmPasswordError,
                                //     suffixIcon: IconButton(
                                //       icon: Icon(
                                //         _obscureTextConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                //         color: Colors.grey,
                                //       ),
                                //       onPressed: () {
                                //         setState(() {
                                //           _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
                                //         });
                                //       },
                                //     ),
                                //   ),
                                // ],
                              ],

                              // STEP 1: JOB, SCHOOL/OFFICE, SUBJECTS
                              if (currentStep == 1) ...[
                                SizedBox(height: context.verticalSize(20)),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      l10n.selectJobCategory,
                                      style: context.semiBold14(color: ColorManager.blackMedium),
                                    ),
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
                                    key: _jobDropdownKey,
                                    value: filterDetails.job.isNotEmpty ? filterDetails.job : null,
                                    hint: Text(
                                      l10n.selectJobCategory,
                                      style: context.regular14(color: ColorManager.disabledText),
                                    ),
                                    items:
                                        (_showAllJobCategories
                                                ? filterDetails.category
                                                : [
                                                  "Provincial School Teacher",
                                                  "National School Teacher",
                                                  "Nurse",
                                                  "Management Assistant",
                                                  "Police Officer",
                                                  "Grama Niladari",
                                                  "Other",
                                                ])
                                            .map(
                                              (jobCategory) => DropdownMenuItem<String>(
                                                value: jobCategory,
                                                child: Text(
                                                  TranslationService.translate(context, jobCategory),
                                                  style: context.regular14(color: ColorManager.blackMedium),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      if (value == 'Other') {
                                        setState(() {
                                          _showAllJobCategories = true;
                                          filterDetails.job = '';
                                        });

                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          Future.delayed(const Duration(milliseconds: 150), () {
                                            _openJobDropdown();
                                          });
                                        });
                                      } else {
                                        setState(() {
                                          filterDetails.job = value ?? '';
                                          jobError = null;
                                          provinceError = null;
                                          districtError = null;
                                          kalapaInstitutionError = null;
                                          kottasaOfficeError = null;
                                          schoolError = null;
                                          schemeError = null;
                                          subjectError = null;
                                          subjectMediumError = null;

                                          filterDetails.province = '';
                                          filterDetails.district = '';
                                          filterDetails.kalapa = '';
                                          filterDetails.kottasa = '';
                                          filterDetails.school = '';
                                          filterDetails.kottasaForNationalScl = '';
                                          filterDetails.nationalSchool = '';
                                          filterDetails.pirivenaInstitute = '';
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
                                          filterDetails.subjectMedium = '';
                                          // filterDetails.grade = '';
                                        });
                                      }
                                    },
                                    dropdownColor: ColorManager.kPrimaryBlack,
                                    underline: const SizedBox(),
                                    icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                    isExpanded: true,
                                  ),
                                ),
                                if (jobError != null)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0, left: 5.0),
                                      child: Text(jobError!, style: const TextStyle(color: Colors.red, fontSize: 12.0)),
                                    ),
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
                                                  filterDetails.job == "National School Teacher" ||
                                                  filterDetails.job == "Pirivena Teacher")
                                              ? l10n.setupSchoolingDetails
                                              : l10n.setupOfficeDetails,
                                          style: context.semiBold14(color: ColorManager.blackMedium),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isSchoolSelected = !isSchoolSelected;
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              l10n.hide,
                                              style: context.semiBold14(
                                                color:
                                                    isSchoolSelected
                                                        ? ColorManager.disabledText
                                                        : ColorManager.kPrimary,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: context.horizontalSize(10)),
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color: isSchoolSelected ? ColorManager.disabledText : Colors.transparent,
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
                                                  style: context.regular14(color: ColorManager.blackMedium),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) async {
                                      setState(() {
                                        filterDetails.province = value ?? '';
                                        provinceError = null;
                                        districtError = null;
                                        kalapaInstitutionError = null;
                                        kottasaOfficeError = null;
                                        schoolError = null;

                                        filterDetails.district = '';
                                        filterDetails.kalapa = '';
                                        filterDetails.kottasa = '';
                                        filterDetails.school = '';
                                        filterDetails.kottasaForNationalScl = '';
                                        filterDetails.nationalSchool = '';
                                        filterDetails.pirivenaInstitute = '';
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
                                      });
                                      if (value != null && value.isNotEmpty) {
                                        setState(() => _isDistrictLoading = true);
                                        await StaticDataService.fetchDistricts(filterDetails, value);
                                        if (mounted) setState(() => _isDistrictLoading = false);
                                      }
                                    },
                                    dropdownColor: ColorManager.kPrimaryBlack,
                                    underline: const SizedBox(),
                                    icon:
                                        _isDistrictLoading
                                            ? SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 20),
                                            )
                                            : Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                    isExpanded: true,
                                  ),
                                ),
                                if (provinceError != null)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0, left: 5.0),
                                      child: Text(
                                        provinceError!,
                                        style: const TextStyle(color: Colors.red, fontSize: 12.0),
                                      ),
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
                                            districtError = null;
                                            kalapaInstitutionError = null;
                                            kottasaOfficeError = null;
                                            schoolError = null;

                                            filterDetails.kalapa = '';
                                            filterDetails.kottasa = '';
                                            filterDetails.school = '';
                                            filterDetails.kottasaForNationalScl = '';
                                            filterDetails.nationalSchool = '';
                                            filterDetails.pirivenaInstitute = '';
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
                                          });
                                          if (value != null && value.isNotEmpty) {
                                            setState(() => _isKalapaInstLoading = true);
                                            if (filterDetails.job == "Provincial School Teacher" ||
                                                filterDetails.job == "National School Teacher") {
                                              await StaticDataService.fetchKalapas(filterDetails, value);
                                            } else if (filterDetails.job == "Pirivena Teacher") {
                                              await StaticDataService.fetchPirivenas(filterDetails, value);
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
                                            if (mounted) setState(() => _isKalapaInstLoading = false);
                                          }
                                        },
                                        dropdownColor: ColorManager.kPrimaryBlack,
                                        underline: const SizedBox(),
                                        icon:
                                            _isKalapaInstLoading
                                                ? SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 20),
                                                )
                                                : Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                        isExpanded: true,
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                                if (districtError != null)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0, left: 5.0),
                                      child: Text(
                                        districtError!,
                                        style: const TextStyle(color: Colors.red, fontSize: 12.0),
                                      ),
                                    ),
                                  ),

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
                                                : filterDetails.job == "Pirivena Teacher"
                                                ? filterDetails.pirivenaInstitute.isNotEmpty
                                                    ? filterDetails.pirivenaInstitute
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
                                                : filterDetails.job == "MA (Pradesiya Sabha)"
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
                                              : filterDetails.job == "Pirivena Teacher"
                                              ? TranslationService.translate(context, "Select Pirivena Institute")
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
                                                              style: context.regular14(color: ColorManager.blackMedium),
                                                            ),
                                                          ),
                                                        )
                                                    : filterDetails.job == "Pirivena Teacher"
                                                    ? (filterDetails.district.isNotEmpty
                                                            ? filterDetails.districtPirivenas[filterDetails.district] ??
                                                                []
                                                            : <String>[])
                                                        .map(
                                                          (institute) => DropdownMenuItem(
                                                            value: institute,
                                                            child: Text(
                                                              TranslationService.translate(context, institute),
                                                              style: context.regular14(color: ColorManager.blackMedium),
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
                                                              style: context.regular14(color: ColorManager.blackMedium),
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
                                                              style: context.regular14(color: ColorManager.blackMedium),
                                                            ),
                                                          ),
                                                        )
                                                    : filterDetails.job == "MA (Pradesiya Sabha)"
                                                    ? ["Pradesiya Sabha"].map(
                                                      (institute) => DropdownMenuItem(
                                                        value: institute,
                                                        child: Text(
                                                          TranslationService.translate(context, institute),
                                                          style: context.regular14(color: ColorManager.blackMedium),
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
                                                              style: context.regular14(color: ColorManager.blackMedium),
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
                                                              style: context.regular14(color: ColorManager.blackMedium),
                                                            ),
                                                          ),
                                                        ))
                                                .toList(),
                                        onChanged: (value) async {
                                          setState(() {
                                            (filterDetails.job == "Provincial School Teacher" ||
                                                    filterDetails.job == "National School Teacher")
                                                ? filterDetails.kalapa = value ?? ''
                                                : filterDetails.job == "Pirivena Teacher"
                                                ? filterDetails.pirivenaInstitute = value ?? ''
                                                : (filterDetails.job == "Nurse" ||
                                                    filterDetails.job == "Hospital Attendant")
                                                ? filterDetails.institutionTypeForNurse = value ?? ''
                                                : (filterDetails.job == "Management Assistant" ||
                                                    filterDetails.job == "Development Officer" ||
                                                    filterDetails.job == "Administrative Officer")
                                                ? filterDetails.institutionTypeForMA = value ?? ''
                                                : filterDetails.job == "MA (Pradesiya Sabha)"
                                                ? filterDetails.institutionTypeForPS = value ?? ''
                                                : filterDetails.job == "Police Officer"
                                                ? filterDetails.policeDivisions = value ?? ''
                                                : filterDetails.job == "Grama Niladari"
                                                ? filterDetails.divisionalSecretariat = value ?? ''
                                                : '';

                                            kalapaInstitutionError = null;
                                            kottasaOfficeError = null;
                                            schoolError = null;

                                            filterDetails.kottasa = '';
                                            filterDetails.school = '';
                                            filterDetails.kottasaForNationalScl = '';
                                            filterDetails.nationalSchool = '';
                                            filterDetails.officeForNurse = '';
                                            filterDetails.officeForMA = '';
                                            filterDetails.officeForPS = '';
                                            filterDetails.policeStations = '';
                                            filterDetails.gramaNiladhariDivision = '';
                                          });

                                          if (value != null &&
                                              value.isNotEmpty &&
                                              filterDetails.job != "Pirivena Teacher") {
                                            setState(() => _isKottasaOfficeLoading = true);
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
                                            if (mounted) setState(() => _isKottasaOfficeLoading = false);
                                          }
                                        },
                                        dropdownColor: ColorManager.kPrimaryBlack,
                                        underline: const SizedBox(),
                                        icon:
                                            _isKalapaInstLoading
                                                ? SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 20),
                                                )
                                                : Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                        isExpanded: true,
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                                if (kalapaInstitutionError != null)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0, left: 5.0),
                                      child: Text(
                                        kalapaInstitutionError!,
                                        style: const TextStyle(color: Colors.red, fontSize: 12.0),
                                      ),
                                    ),
                                  ),

                                SizedBox(
                                  height: context.verticalSize(
                                    ((filterDetails.job != "Public Health Inspector" &&
                                                filterDetails.job != "Public Health Midwife" &&
                                                filterDetails.job != "Pirivena Teacher") &&
                                            (filterDetails.kalapa.isNotEmpty ||
                                                filterDetails.institutionTypeForNurse.isNotEmpty ||
                                                filterDetails.institutionTypeForMA.isNotEmpty ||
                                                filterDetails.institutionTypeForPS.isNotEmpty ||
                                                filterDetails.policeDivisions.isNotEmpty ||
                                                filterDetails.divisionalSecretariat.isNotEmpty))
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
                                                : filterDetails.job == "MA (Pradesiya Sabha)"
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
                                                    : filterDetails.job == "MA (Pradesiya Sabha)"
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
                                                : filterDetails.job == "MA (Pradesiya Sabha)"
                                                ? filterDetails.officeForPS = value ?? ''
                                                : filterDetails.job == "Police Officer"
                                                ? filterDetails.policeStations = value ?? ''
                                                : filterDetails.job == "Grama Niladari"
                                                ? filterDetails.gramaNiladhariDivision = value ?? ''
                                                : '';

                                            kottasaOfficeError = null;
                                            schoolError = null;

                                            filterDetails.school = '';
                                            filterDetails.nationalSchool = '';
                                            _isKottasaOfficeLoading = false;
                                          });

                                          if (value != null && value.isNotEmpty) {
                                            setState(() => _isSchoolLoading = true);
                                            if (filterDetails.job == "Provincial School Teacher") {
                                              await StaticDataService.fetchSchools(filterDetails, value);
                                            } else if (filterDetails.job == "National School Teacher") {
                                              await StaticDataService.fetchNationalSchools(filterDetails, value);
                                            }
                                            if (mounted) setState(() => _isSchoolLoading = false);
                                          }
                                        },
                                        dropdownColor: ColorManager.kPrimaryBlack,
                                        underline: const SizedBox(),
                                        icon:
                                            _isKottasaOfficeLoading
                                                ? SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 20),
                                                )
                                                : Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                        isExpanded: true,
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                                if (kottasaOfficeError != null)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0, left: 5.0),
                                      child: Text(
                                        kottasaOfficeError!,
                                        style: const TextStyle(color: Colors.red, fontSize: 12.0),
                                      ),
                                    ),
                                  ),

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
                                if (schoolError != null && schoolError!.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0, left: 5.0),
                                      child: Text(
                                        schoolError!,
                                        style: const TextStyle(color: Colors.red, fontSize: 12.0),
                                      ),
                                    ),
                                  ),

                                if (filterDetails.job == "Provincial School Teacher" ||
                                    filterDetails.job == "National School Teacher") ...[
                                  SizedBox(height: context.verticalSize(30)),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      l10n.setupSubjectDetails,
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
                                      value: filterDetails.scheme.isNotEmpty ? filterDetails.scheme : null,
                                      hint: Text(
                                        l10n.selectScheme,
                                        style: context.regular14(color: ColorManager.disabledText),
                                      ),
                                      items:
                                          filterDetails.schemes
                                              .map(
                                                (scheme) => DropdownMenuItem(
                                                  value: scheme,
                                                  child: Text(
                                                    TranslationService.translate(context, scheme),
                                                    style: context.regular14(color: ColorManager.blackMedium),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (value) async {
                                        setState(() {
                                          filterDetails.scheme = value ?? '';
                                          filterDetails.subject = ''; // reset subject
                                          schemeError = null;
                                          if (filterDetails.scheme != "PRIMARY") {
                                            subjectError = "Subject also required";
                                          } else {
                                            subjectError = null;
                                          }
                                        });
                                        if (value != null) {
                                          setState(() => _isSubjectLoading = true);
                                          await StaticDataService.fetchSubjects(filterDetails, value);
                                          if (mounted) setState(() => _isSubjectLoading = false);
                                        }
                                      },
                                      dropdownColor: ColorManager.kPrimaryBlack,
                                      underline: const SizedBox(),
                                      icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                      isExpanded: true,
                                    ),
                                  ),
                                  if (schemeError != null)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 4.0, left: 5.0),
                                        child: Text(
                                          schemeError!,
                                          style: const TextStyle(color: Colors.red, fontSize: 12.0),
                                        ),
                                      ),
                                    ),

                                  SizedBox(
                                    height: context.verticalSize(
                                      (filterDetails.scheme != "PRIMARY" && filterDetails.scheme.isNotEmpty) ? 20 : 0,
                                    ),
                                  ),

                                  // Subject Dropdown
                                  if (filterDetails.scheme != "PRIMARY" && filterDetails.scheme.isNotEmpty) ...[
                                    Container(
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
                                        icon:
                                            _isSubjectLoading
                                                ? SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: SpinKitFadingCircle(color: ColorManager.kPrimary, size: 20),
                                                )
                                                : Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                        isExpanded: true,
                                      ),
                                    ),
                                  ],
                                  if (subjectError != null && subjectError!.isNotEmpty)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 4.0, left: 5.0),
                                        child: Text(
                                          subjectError!,
                                          style: const TextStyle(color: Colors.red, fontSize: 12.0),
                                        ),
                                      ),
                                    ),

                                  SizedBox(height: context.verticalSize(20)),

                                  Column(
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
                                      if (subjectMediumError != null)
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 4.0, left: 5.0),
                                            child: Text(
                                              subjectMediumError!,
                                              style: const TextStyle(color: Colors.red, fontSize: 12.0),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ],

                              // STEP 2: CHOICES & SUBMIT
                              if (currentStep == 2) ...[
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
                                if (choiceError != null && choiceError!.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0, left: 5.0),
                                      child: Text(
                                        choiceError!,
                                        style: const TextStyle(color: Colors.red, fontSize: 12.0),
                                      ),
                                    ),
                                  ),

                                // NOTE SECTION COMMENTED OUT
                                // SizedBox(height: context.verticalSize(30)),
                                // Align(
                                //   alignment: Alignment.centerLeft,
                                //   child: Text(
                                //     l10n.addSpecialNote,
                                //     style: context.semiBold14(color: ColorManager.blackMedium),
                                //   ),
                                // ),
                                // SizedBox(height: context.verticalSize(8)),
                                // CustomTextField(
                                //   radius: 30,
                                //   height: context.verticalSize(40),
                                //   controller: auth.noteController,
                                //   inputType: TextInputType.emailAddress,
                                //   hintText: l10n.note,
                                //   validator: (value) {},
                                // ),
                                // SizedBox(height: context.verticalSize(8)),
                              ],
                              SizedBox(height: context.verticalSize(20)),
                              CenterTextIconButton(
                                onPress: () async {
                                  // STEP 0 VALIDATION
                                  if (currentStep == 0) {
                                    bool isValid = informationFormKey.currentState?.validate() ?? false;

                                    if (auth.contactController.text.isEmpty) {
                                      setState(() {
                                        contactError = l10n.reqContact;
                                      });
                                      isValid = false;
                                    } else if (auth.contactController.text.length < 10 ||
                                        auth.contactController.text.length > 12) {
                                      setState(() {
                                        contactError = l10n.reqValidContact;
                                      });
                                      isValid = false;
                                    } else {
                                      setState(() {
                                        contactError = null;
                                      });
                                    }

                                    final email = auth.emailController.text.trim();
                                    final isGmail = RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
                                      caseSensitive: false,
                                    ).hasMatch(email);

                                    if (email.isNotEmpty && !isGmail && !auth.isGoogleAuth) {
                                      final shouldSave = await _saveAlertDialog(
                                        context,
                                        "Can't create your Account",
                                        "Please connect with us via WhatsApp to create your account.",
                                        'Need Help?',
                                      );

                                      if (shouldSave == true) {
                                        contactWhatsApp("94713905383", "Hello, I need assistance with my account.");
                                      }
                                      isValid = false;
                                    }

                                    if (isValid) {
                                      setState(() {
                                        currentStep = 1;
                                      });
                                    }
                                  }
                                  // STEP 1 VALIDATION
                                  else if (currentStep == 1) {
                                    bool isValid = true;

                                    setState(() {
                                      jobError = null;
                                      provinceError = null;
                                      districtError = null;
                                      kalapaInstitutionError = null;
                                      kottasaOfficeError = null;
                                      schoolError = null;
                                      schemeError = null;
                                      subjectError = null;
                                      subjectMediumError = null;
                                    });

                                    if (filterDetails.job.isEmpty) {
                                      setState(() => jobError = l10n.reqJob);
                                      isValid = false;
                                    } else {
                                      if (filterDetails.province.isEmpty) {
                                        setState(() => provinceError = l10n.reqProvince);
                                        isValid = false;
                                      }
                                      if (filterDetails.district.isEmpty) {
                                        setState(() => districtError = l10n.reqDistrict);
                                        isValid = false;
                                      }

                                      if (filterDetails.job == "Provincial School Teacher" ||
                                          filterDetails.job == "National School Teacher") {
                                        if (filterDetails.kalapa.isEmpty) {
                                          setState(() => kalapaInstitutionError = l10n.reqKalapa);
                                          isValid = false;
                                        }

                                        if (filterDetails.job == "Provincial School Teacher" &&
                                            filterDetails.kottasa.isEmpty) {
                                          setState(() => kottasaOfficeError = l10n.reqKottasa);
                                          isValid = false;
                                        } else if (filterDetails.job == "National School Teacher" &&
                                            filterDetails.kottasaForNationalScl.isEmpty) {
                                          setState(() => kottasaOfficeError = l10n.reqKottasa);
                                          isValid = false;
                                        }

                                        if (filterDetails.job == "Provincial School Teacher" &&
                                            filterDetails.school.isEmpty) {
                                          setState(() => schoolError = l10n.reqSelectSchool);
                                          isValid = false;
                                        } else if (filterDetails.job == "National School Teacher" &&
                                            filterDetails.nationalSchool.isEmpty) {
                                          setState(() => schoolError = l10n.reqSelectSchool);
                                          isValid = false;
                                        }
                                      } else if (filterDetails.job == "Nurse" ||
                                          filterDetails.job == "Hospital Attendant" ||
                                          filterDetails.job == "Public Health Inspector" ||
                                          filterDetails.job == "Public Health Midwife") {
                                        if ((filterDetails.job == "Nurse" ||
                                                filterDetails.job == "Hospital Attendant") &&
                                            filterDetails.institutionTypeForNurse.isEmpty) {
                                          setState(() => kalapaInstitutionError = l10n.reqKalapa);
                                          isValid = false;
                                        }
                                        if (filterDetails.officeForNurse.isEmpty) {
                                          setState(() => kottasaOfficeError = l10n.reqSelectOffice);
                                          isValid = false;
                                        }
                                      } else if (filterDetails.job == "Management Assistant" ||
                                          filterDetails.job == "Development Officer" ||
                                          filterDetails.job == "Administrative Officer") {
                                        if (filterDetails.institutionTypeForMA.isEmpty) {
                                          setState(() => kalapaInstitutionError = l10n.reqKalapa);
                                          isValid = false;
                                        }
                                        if (filterDetails.officeForMA.isEmpty) {
                                          setState(() => kottasaOfficeError = l10n.reqSelectOffice);
                                          isValid = false;
                                        }
                                      } else if (filterDetails.job == "MA (Pradesiya Sabha)") {
                                        if (filterDetails.institutionTypeForPS.isEmpty) {
                                          setState(() => kalapaInstitutionError = "Institution Type Required");
                                          isValid = false;
                                        }
                                        if (filterDetails.officeForPS.isEmpty) {
                                          setState(() => kottasaOfficeError = l10n.reqSelectOffice);
                                          isValid = false;
                                        }
                                      } else if (filterDetails.job == "Police Officer") {
                                        if (filterDetails.policeDivisions.isEmpty) {
                                          setState(() => kalapaInstitutionError = l10n.reqKalapa);
                                          isValid = false;
                                        }
                                        if (filterDetails.policeStations.isEmpty) {
                                          setState(() => kottasaOfficeError = l10n.reqSelectOffice);
                                          isValid = false;
                                        }
                                      } else if (filterDetails.job == "Grama Niladari") {
                                        if (filterDetails.divisionalSecretariat.isEmpty) {
                                          setState(() => kalapaInstitutionError = l10n.reqKalapa);
                                          isValid = false;
                                        }
                                        if (filterDetails.gramaNiladhariDivision.isEmpty) {
                                          setState(() => kottasaOfficeError = l10n.reqSelectOffice);
                                          isValid = false;
                                        }
                                      } else if (filterDetails.job == "Pirivena Teacher") {
                                        if (filterDetails.pirivenaInstitute.isEmpty) {
                                          setState(
                                            () =>
                                                kalapaInstitutionError = TranslationService.translate(
                                                  context,
                                                  "Pirivena Institute is required",
                                                ),
                                          );
                                          isValid = false;
                                        }
                                      }

                                      if (filterDetails.job == "Provincial School Teacher" ||
                                          filterDetails.job == "National School Teacher") {
                                        if (filterDetails.scheme.isEmpty) {
                                          setState(() => schemeError = l10n.reqScheme);
                                          isValid = false;
                                        } else if (filterDetails.scheme != "PRIMARY" && filterDetails.subject.isEmpty) {
                                          setState(() => subjectError = l10n.reqSelectSubject);
                                          isValid = false;
                                        }

                                        if (filterDetails.subjectMedium.isEmpty) {
                                          setState(() => subjectMediumError = l10n.reqSelectMedium);
                                          isValid = false;
                                        }
                                      }
                                    }

                                    if (isValid) {
                                      setState(() {
                                        currentStep = 2;
                                      });
                                    }
                                  }
                                  // STEP 2 VALIDATION & SUBMIT
                                  else if (currentStep == 2) {
                                    bool isValid = true;

                                    if (filterDetails.choice1 == '') {
                                      setState(() {
                                        choiceError = l10n.reqSelectChoice;
                                      });
                                      isValid = false;
                                    } else {
                                      setState(() {
                                        choiceError = '';
                                      });
                                    }

                                    if (isValid) {
                                      auth.filterDetails = filterDetails;

                                      if (auth.isGoogleAuth) {
                                        final success = await auth.createAccount(
                                          isPhoneHide: isSelected,
                                          isWhatsappHide: isWhatsappSelected,
                                          isSchoolHide: isSchoolSelected,
                                          isEnable: isEnable,
                                        );
                                        if (success) {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (_) => const Home(index: 0)),
                                            (route) => false,
                                          );
                                        } else {
                                          toastErrorMessage(auth.errorMessage ?? 'Failed to complete setup.');
                                        }
                                      } else {
                                        // Standard Email & Password registration
                                        try {
                                          final user = await auth.registerEmail(
                                            auth.emailController.text,
                                            auth.passwordController.text,
                                          );

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => VerifyEmailScreen(
                                                    user: user!,
                                                    isSelected: isSelected,
                                                    isWhatsappSelected: isWhatsappSelected,
                                                    isSchoolSelected: isSchoolSelected,
                                                    isEnable: isEnable,
                                                  ),
                                            ),
                                          );
                                        } catch (e) {
                                          toastErrorMessage('Email is already verified or in use.');
                                        }
                                      }
                                    }
                                  }
                                },
                                isGradientColor: true,
                                gradientColors: ColorManager.gradientButtons2,
                                isLoading: auth.isLoading,
                                buttonText: l10n.continueText,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
      ),
    );
  }
}
