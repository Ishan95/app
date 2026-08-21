import 'package:app/app/models/filter_model.dart';
import 'package:app/app/utils/custom_toast.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/service_providers/firebase_service.dart';
import 'package:app/screens/onboarding/verify_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/app/export.dart';
import 'package:url_launcher/url_launcher.dart';

class GetDetailsScreen extends StatefulWidget {
  final bool isSignupEmail;
  const GetDetailsScreen({super.key, required this.isSignupEmail});

  @override
  State<GetDetailsScreen> createState() => _GetDetailsScreenState();
}

class _GetDetailsScreenState extends State<GetDetailsScreen> {
  final informationFormKey = GlobalKey<FormState>();
  bool isSelected = false;
  bool isSchoolSelected = false;
  bool isEnable = false;
  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? idCardError;
  String? contactError;
  String? passwordError;
  String? confirmPasswordError;
  String? schoolError;
  String? subjectError;
  String? gradeError;
  String? choiceError;
  bool _obscureText = true;
  bool _obscureTextConfirmPassword = true;
  DateTime? _selectedDate;
  String? _dobErrorText;

  FilterModel filterDetails = FilterModel();

  @override
  void initState() {
    super.initState();
    _initFcm();
  }

  Future<void> _initFcm() async {
    String? token = await FirebaseService.getFcmToken();
    print('token');
    print(token);
    print('token');
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dobErrorText = null;
        _selectedDate = pickedDate;
      });
    }
  }

  Future<bool?> _saveAlertDialog(BuildContext context, String title, String content, String confirmText) {
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
                child: Text('Cancel', style: context.semiBold14(color: ColorManager.black)),
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
    return Scaffold(
      backgroundColor: ColorManager.kPrimaryBlack,
      body: SafeArea(
        child: SingleChildScrollView(
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
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.arrow_back, color: ColorManager.blackMedium),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Add Basic Information",
                              style: context.boldNunito30(color: ColorManager.blackMedium),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.verticalSize(10)),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Welcome! To get started, we need a few basic details to finish setting up your account.",
                          style: context.regularMulish14(color: ColorManager.grayText),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: context.verticalSize(23)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Legal Name", style: context.semiBold14(color: ColorManager.blackMedium)),
                      ),
                      SizedBox(height: context.verticalSize(8)),
                      CustomTextField(
                        radius: 30,
                        height: context.verticalSize(40),
                        controller: auth.firstNameController,
                        inputType: TextInputType.name,
                        hintText: 'First Name',
                        validator: (value) {
                          if (auth.firstNameController.text.isEmpty) {
                            setState(() {
                              firstNameError = "First Name is required";
                            });
                            return '';
                          } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value!)) {
                            setState(() {
                              firstNameError = "Please enter a valid First Name";
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
                        hintText: 'Last Name',
                        validator: (value) {
                          if (auth.lastNameController.text.isEmpty) {
                            setState(() {
                              lastNameError = "Last Name is required";
                            });
                            return '';
                          } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value!)) {
                            setState(() {
                              lastNameError = "Please enter a valid Last Name";
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
                      SizedBox(height: context.verticalSize(2)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Enter your full name as it appears on official documents.",
                          style: context.semiBold14(color: ColorManager.disabledText, fontSize: 13),
                        ),
                      ),
                      SizedBox(height: context.verticalSize(30)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Email", style: context.semiBold14(color: ColorManager.blackMedium)),
                      ),
                      SizedBox(height: context.verticalSize(8)),
                      CustomTextField(
                        radius: 30,
                        height: context.verticalSize(40),
                        controller: auth.emailController,
                        inputType: TextInputType.emailAddress,
                        hintText: 'Email Address',
                        // enabled: false,
                        validator: (value) {
                          if (auth.emailController.text.isEmpty) {
                            setState(() {
                              emailError = "Email is required";
                            });
                            return '';
                          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                            setState(() {
                              emailError = "Enter a valid email address";
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
                      SizedBox(height: context.verticalSize(1)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Please add a fresh email address and remember it carefully. This email will be used for all communication",
                          style: context.semiBold14(color: ColorManager.disabledText),
                        ),
                      ),
                      SizedBox(height: context.verticalSize(30)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Date of Birth", style: context.semiBold14(color: ColorManager.blackMedium)),
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
                            _selectedDate != null ? '${_selectedDate!.toLocal()}'.split(' ')[0] : 'Birthdate',
                            style: TextStyle(
                              color: ColorManager.blackMedium,
                              fontSize: context.fontSize(14),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (_dobErrorText != null)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4, left: 8),
                            child: Text(
                              _dobErrorText!,
                              style: TextStyle(color: Colors.red, fontSize: context.fontSize(12)),
                            ),
                          ),
                        ),
                      SizedBox(height: context.verticalSize(30)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Identity Card Number", style: context.semiBold14(color: ColorManager.blackMedium)),
                      ),
                      SizedBox(height: context.verticalSize(8)),
                      CustomTextField(
                        radius: 30,
                        height: context.verticalSize(40),
                        controller: auth.idCardController,
                        inputType: TextInputType.emailAddress,
                        hintText: 'Identity Card Number',
                        // enabled: false,
                        validator: (value) {
                          if (auth.idCardController.text.isEmpty) {
                            setState(() {
                              idCardError = "ID number is required";
                            });
                            return '';
                          } else if (value!.length < 5 || value.length > 20) {
                            setState(() {
                              idCardError = "Enter Valid ID number";
                            });
                            return '';
                          }
                          setState(() {
                            idCardError = null;
                          });
                          return null;
                        },
                        errorMessage: idCardError,
                      ),
                      SizedBox(height: context.verticalSize(10)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Contact Number", style: context.semiBold14(color: ColorManager.blackMedium)),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isSelected = !isSelected;
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                  "Hide",
                                  style: context.semiBold14(
                                    color: isSelected ? ColorManager.disabledText : ColorManager.kPrimary,
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
                        hintText: 'Contact Number',
                        // enabled: false,
                        validator: (value) {
                          if (auth.contactController.text.isEmpty) {
                            setState(() {
                              contactError = "Contact number is required";
                            });
                            return '';
                          } else if (value!.length < 5 || value.length > 20) {
                            setState(() {
                              contactError = "Enter Valid Contact number";
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
                      SizedBox(height: context.verticalSize(20)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select Your Job Category",
                          style: context.semiBold14(color: ColorManager.blackMedium),
                        ),
                      ),
                      SizedBox(height: context.verticalSize(8)),
                      Container(
                        height: context.verticalSize(40),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: ColorManager.white10, borderRadius: BorderRadius.circular(20)),
                        child: DropdownButton<String>(
                          value: filterDetails.job.isNotEmpty ? filterDetails.job : null,
                          hint: Text("Select Job Category", style: context.regular14(color: ColorManager.disabledText)),
                          items:
                              filterDetails.category
                                  .map(
                                    (jobCategory) => DropdownMenuItem<String>(
                                      value: jobCategory,
                                      child: Text(
                                        jobCategory,
                                        style: context.regular14(color: ColorManager.blackMedium),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              filterDetails.job = value ?? '';
                              filterDetails.province = '';
                              filterDetails.district = ''; // reset district
                              filterDetails.kalapa = ''; // reset kalapa
                              filterDetails.kottasa = ''; // reset kottasa
                              filterDetails.school = ''; // reset School
                              filterDetails.kottasaForNationalScl = '';
                              filterDetails.nationalSchool = '';
                              filterDetails.institutionTypeForNurse = '';
                              filterDetails.officeForNurse = '';
                              filterDetails.institutionTypeForMA = '';
                              filterDetails.officeForMA = '';
                              filterDetails.divisionalSecretariat = '';
                              filterDetails.gramaNiladhariDivision = '';
                              filterDetails.policeDivisions = '';
                              filterDetails.policeStations = '';
                            });
                          },
                          dropdownColor: ColorManager.kPrimaryBlack,
                          underline: const SizedBox(),
                          icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                          isExpanded: true,
                        ),
                      ),
                      SizedBox(height: context.verticalSize(20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Setup your ${(filterDetails.job == "Provincial School Teacher" || filterDetails.job == "National School Teacher") ? "Schooling" : "Office"} Details",
                            style: context.semiBold14(color: ColorManager.blackMedium),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isSchoolSelected = !isSchoolSelected;
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                  "Hide",
                                  style: context.semiBold14(
                                    color: isSchoolSelected ? ColorManager.disabledText : ColorManager.kPrimary,
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
                        decoration: BoxDecoration(color: ColorManager.white10, borderRadius: BorderRadius.circular(20)),
                        child:
                            filterDetails.job != ""
                                ? DropdownButton<String>(
                                  value: filterDetails.province.isNotEmpty ? filterDetails.province : null,
                                  hint: Text(
                                    "Select Province",
                                    style: context.regular14(color: ColorManager.disabledText),
                                  ),
                                  items:
                                      filterDetails.provinceDistricts.keys
                                          .map(
                                            (province) => DropdownMenuItem(
                                              value: province,
                                              child: Text(
                                                province,
                                                style: context.regular14(color: ColorManager.blackMedium),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      filterDetails.province = value ?? '';
                                      filterDetails.district = ''; // reset district
                                      filterDetails.kalapa = ''; // reset kalapa
                                      filterDetails.kottasa = ''; // reset kottasa
                                      filterDetails.school = ''; // reset School
                                      filterDetails.kottasaForNationalScl = '';
                                      filterDetails.nationalSchool = '';
                                      filterDetails.institutionTypeForNurse = '';
                                      filterDetails.officeForNurse = '';
                                      filterDetails.institutionTypeForMA = '';
                                      filterDetails.officeForMA = '';
                                      filterDetails.divisionalSecretariat = '';
                                      filterDetails.gramaNiladhariDivision = '';
                                      filterDetails.policeDivisions = '';
                                      filterDetails.policeStations = '';
                                    });
                                  },
                                  dropdownColor: ColorManager.kPrimaryBlack,
                                  underline: const SizedBox(),
                                  icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                                  isExpanded: true,
                                )
                                : Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Select Province",
                                    style: context.regular14(color: ColorManager.disabledText),
                                  ),
                                ),
                      ),

                      SizedBox(height: context.verticalSize(filterDetails.province.isNotEmpty ? 20 : 0)),

                      // District Dropdown
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
                              hint: Text("Select District", style: context.regular14(color: ColorManager.disabledText)),
                              items:
                                  (filterDetails.province.isNotEmpty
                                          ? filterDetails.provinceDistricts[filterDetails.province] ?? []
                                          : <String>[])
                                      .map(
                                        (district) => DropdownMenuItem(
                                          value: district,
                                          child: Text(
                                            district,
                                            style: context.regular14(color: ColorManager.blackMedium),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  filterDetails.district = value ?? '';
                                  filterDetails.kalapa = ''; // reset kalapa
                                  filterDetails.kottasa = ''; // reset kottasa
                                  filterDetails.school = ''; // reset School
                                  filterDetails.kottasaForNationalScl = '';
                                  filterDetails.nationalSchool = '';
                                  filterDetails.institutionTypeForNurse = '';
                                  filterDetails.officeForNurse = '';
                                  filterDetails.institutionTypeForMA = '';
                                  filterDetails.officeForMA = '';
                                  filterDetails.divisionalSecretariat = '';
                                  filterDetails.gramaNiladhariDivision = '';
                                  filterDetails.policeDivisions = '';
                                  filterDetails.policeStations = '';
                                });
                              },
                              dropdownColor: ColorManager.kPrimaryBlack,
                              underline: const SizedBox(),
                              icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                              isExpanded: true,
                            ),
                          )
                          : SizedBox.shrink(),
                      SizedBox(height: context.verticalSize(filterDetails.district.isNotEmpty ? 20 : 0)),
                      // Kalapa Dropdown
                      filterDetails.district.isNotEmpty
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
                                      : filterDetails.job == "Nurse"
                                      ? filterDetails.institutionTypeForNurse.isNotEmpty
                                          ? filterDetails.institutionTypeForNurse
                                          : null
                                      : filterDetails.job == "Management Assistant"
                                      ? filterDetails.institutionTypeForMA.isNotEmpty
                                          ? filterDetails.institutionTypeForMA
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
                                "Select ${(filterDetails.job == "Provincial School Teacher" || filterDetails.job == "National School Teacher") ? "Kalapa" : "Institution Type"}",
                                style: context.regular14(color: ColorManager.disabledText),
                              ),
                              items:
                                  ((filterDetails.job == "Provincial School Teacher" ||
                                              filterDetails.job == "National School Teacher")
                                          ? (filterDetails.district.isNotEmpty
                                                  ? filterDetails.districtKalapas[filterDetails.district] ?? []
                                                  : <String>[])
                                              .map(
                                                (kalapa) => DropdownMenuItem(
                                                  value: kalapa,
                                                  child: Text(
                                                    kalapa,
                                                    style: context.regular14(color: ColorManager.blackMedium),
                                                  ),
                                                ),
                                              )
                                          : filterDetails.job == "Nurse"
                                          ? (filterDetails.district.isNotEmpty
                                                  ? filterDetails.districtInstitutionTypeForNurse[filterDetails
                                                          .district] ??
                                                      []
                                                  : <String>[])
                                              .map(
                                                (institute) => DropdownMenuItem(
                                                  value: institute,
                                                  child: Text(
                                                    institute,
                                                    style: context.regular14(color: ColorManager.blackMedium),
                                                  ),
                                                ),
                                              )
                                          : filterDetails.job == "Management Assistant"
                                          ? (filterDetails.district.isNotEmpty
                                                  ? filterDetails.districtInstitutionTypeForMA[filterDetails
                                                          .district] ??
                                                      []
                                                  : <String>[])
                                              .map(
                                                (institute) => DropdownMenuItem(
                                                  value: institute,
                                                  child: Text(
                                                    institute,
                                                    style: context.regular14(color: ColorManager.blackMedium),
                                                  ),
                                                ),
                                              )
                                          : filterDetails.job == "Police Officer"
                                          ? (filterDetails.district.isNotEmpty
                                                  ? filterDetails.districtPoliceDivisions[filterDetails.district] ?? []
                                                  : <String>[])
                                              .map(
                                                (policeDivisions) => DropdownMenuItem(
                                                  value: policeDivisions,
                                                  child: Text(
                                                    policeDivisions,
                                                    style: context.regular14(color: ColorManager.blackMedium),
                                                  ),
                                                ),
                                              )
                                          : (filterDetails.district.isNotEmpty
                                                  ? filterDetails.districtDsDivisions[filterDetails.district] ?? []
                                                  : <String>[])
                                              .map(
                                                (dsDivisions) => DropdownMenuItem(
                                                  value: dsDivisions,
                                                  child: Text(
                                                    dsDivisions,
                                                    style: context.regular14(color: ColorManager.blackMedium),
                                                  ),
                                                ),
                                              ))
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  (filterDetails.job == "Provincial School Teacher" ||
                                          filterDetails.job == "National School Teacher")
                                      ? filterDetails.kalapa = value ?? ''
                                      : filterDetails.job == "Nurse"
                                      ? filterDetails.institutionTypeForNurse = value ?? ''
                                      : filterDetails.job == "Management Assistant"
                                      ? filterDetails.institutionTypeForMA = value ?? ''
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
                                  filterDetails.policeStations = '';
                                  filterDetails.gramaNiladhariDivision = '';
                                });
                              },
                              dropdownColor: ColorManager.kPrimaryBlack,
                              underline: const SizedBox(),
                              icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                              isExpanded: true,
                            ),
                          )
                          : SizedBox.shrink(),
                      SizedBox(
                        height: context.verticalSize(
                          (filterDetails.kalapa.isNotEmpty ||
                                  filterDetails.institutionTypeForNurse.isNotEmpty ||
                                  filterDetails.institutionTypeForMA.isNotEmpty ||
                                  filterDetails.policeDivisions.isNotEmpty ||
                                  filterDetails.divisionalSecretariat.isNotEmpty)
                              ? 20
                              : 0,
                        ),
                      ),

                      // kottasa Dropdown
                      (((filterDetails.job == "Provincial School Teacher" ||
                                      filterDetails.job == "National School Teacher") &&
                                  filterDetails.kalapa.isNotEmpty) ||
                              filterDetails.institutionTypeForNurse.isNotEmpty ||
                              filterDetails.institutionTypeForMA.isNotEmpty ||
                              filterDetails.policeDivisions.isNotEmpty ||
                              filterDetails.divisionalSecretariat.isNotEmpty)
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
                                      : filterDetails.job == "Nurse"
                                      ? filterDetails.officeForNurse.isNotEmpty
                                          ? filterDetails.officeForNurse
                                          : null
                                      : filterDetails.job == "Management Assistant"
                                      ? filterDetails.officeForMA.isNotEmpty
                                          ? filterDetails.officeForMA
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
                                "Select ${(filterDetails.job == "Provincial School Teacher" || filterDetails.job == "National School Teacher") ? "kottasa" : "Office"}",
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
                                                    kottasa,
                                                    style: context.regular14(color: ColorManager.blackMedium),
                                                  ),
                                                ),
                                              )
                                          : filterDetails.job == "National School Teacher"
                                          ? (filterDetails.kalapa.isNotEmpty
                                                  ? filterDetails.kalapaKottasaForNationalScl[filterDetails.kalapa] ??
                                                      []
                                                  : <String>[])
                                              .map(
                                                (kottasa) => DropdownMenuItem(
                                                  value: kottasa,
                                                  child: Text(
                                                    kottasa,
                                                    style: context.regular14(color: ColorManager.blackMedium),
                                                  ),
                                                ),
                                              )
                                          : filterDetails.job == "Nurse"
                                          ? (filterDetails.institutionTypeForNurse.isNotEmpty
                                                  ? filterDetails.institutionTypeOfficesForNurse[filterDetails
                                                          .institutionTypeForNurse] ??
                                                      []
                                                  : <String>[])
                                              .map(
                                                (office) => DropdownMenuItem(
                                                  value: office,
                                                  child: Text(
                                                    office,
                                                    style: context.regular14(color: ColorManager.blackMedium),
                                                  ),
                                                ),
                                              )
                                          : filterDetails.job == "Management Assistant"
                                          ? (filterDetails.institutionTypeForMA.isNotEmpty
                                                  ? filterDetails.institutionTypeOfficesForMA[filterDetails
                                                          .institutionTypeForMA] ??
                                                      []
                                                  : <String>[])
                                              .map(
                                                (office) => DropdownMenuItem(
                                                  value: office,
                                                  child: Text(
                                                    office,
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
                                                    office,
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
                                                    office,
                                                    style: context.regular14(color: ColorManager.blackMedium),
                                                  ),
                                                ),
                                              ))
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  filterDetails.job == "Provincial School Teacher"
                                      ? filterDetails.kottasa = value ?? ''
                                      : filterDetails.job == "National School Teacher"
                                      ? filterDetails.kottasaForNationalScl = value ?? ''
                                      : filterDetails.job == "Nurse"
                                      ? filterDetails.officeForNurse = value ?? ''
                                      : filterDetails.job == "Management Assistant"
                                      ? filterDetails.officeForMA = value ?? ''
                                      : filterDetails.job == "Police Officer"
                                      ? filterDetails.policeStations = value ?? ''
                                      : filterDetails.gramaNiladhariDivision = value ?? '';
                                  filterDetails.school = '';
                                  filterDetails.nationalSchool = '';
                                });
                              },
                              dropdownColor: ColorManager.kPrimaryBlack,
                              underline: const SizedBox(),
                              icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                              isExpanded: true,
                            ),
                          )
                          : SizedBox.shrink(),
                      SizedBox(
                        height: context.verticalSize(
                          filterDetails.kottasa.isNotEmpty || filterDetails.kottasaForNationalScl.isNotEmpty ? 20 : 0,
                        ),
                      ),
                      ((filterDetails.job == "Provincial School Teacher" && filterDetails.kottasa.isNotEmpty) ||
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
                              hint: Text("Select School", style: context.regular14(color: ColorManager.disabledText)),
                              items:
                                  (filterDetails.job == "Provincial School Teacher"
                                          ? filterDetails.kottasa.isNotEmpty
                                              ? filterDetails.kottasaSchools[filterDetails
                                                      // .kalapaSchool[filterDetails
                                                      .kottasa] ??
                                                  []
                                              : <String>[]
                                          : filterDetails.kottasaForNationalScl.isNotEmpty
                                          ? filterDetails.kottasaNationalSchools[filterDetails
                                                  // .kalapaSchool[filterDetails
                                                  .kottasaForNationalScl] ??
                                              []
                                          : <String>[])
                                      .map(
                                        (school) => DropdownMenuItem(
                                          value: school,
                                          child: Text(
                                            school,
                                            style: context.regular14(color: ColorManager.blackMedium),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  filterDetails.job == "Provincial School Teacher"
                                      ? filterDetails.school = value ?? ''
                                      : filterDetails.nationalSchool = value ?? ''; // reset School
                                  schoolError = null;
                                });
                              },
                              dropdownColor: ColorManager.kPrimaryBlack,
                              underline: const SizedBox(),
                              icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
                              isExpanded: true,
                            ),
                          )
                          : SizedBox.shrink(),
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
                          "Setup your ${(filterDetails.job == "Provincial School Teacher" || filterDetails.job == "National School Teacher") ? "Subject" : "Grade"} Details",
                          style: context.semiBold14(color: ColorManager.blackMedium),
                        ),
                      ),
                      SizedBox(height: context.verticalSize(8)),
                      Container(
                        height: context.verticalSize(40),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: ColorManager.white10, borderRadius: BorderRadius.circular(20)),
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
                            "Select ${(filterDetails.job == "Provincial School Teacher" || filterDetails.job == "National School Teacher") ? "Scheme" : "Grade"}",
                            style: context.regular14(color: ColorManager.disabledText),
                          ),
                          items:
                              ((filterDetails.job == "Provincial School Teacher" ||
                                          filterDetails.job == "National School Teacher")
                                      ? filterDetails.schemeSubjects.keys
                                      : filterDetails.gradeList)
                                  .map(
                                    (scheme) => DropdownMenuItem(
                                      value: scheme,
                                      child: Text(scheme, style: context.regular14(color: ColorManager.blackMedium)),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              if ((filterDetails.job == "Provincial School Teacher" ||
                                  filterDetails.job == "National School Teacher")) {
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
                            });
                          },
                          dropdownColor: ColorManager.kPrimaryBlack,
                          underline: const SizedBox(),
                          icon: Icon(Icons.arrow_drop_down, color: ColorManager.disabledText),
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

                      // District Dropdown
                      (filterDetails.scheme != "PRIMARY" &&
                              filterDetails.scheme.isNotEmpty &&
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
                              hint: Text("Select Subject", style: context.regular14(color: ColorManager.disabledText)),
                              items:
                                  (filterDetails.scheme.isNotEmpty
                                          ? filterDetails.schemeSubjects[filterDetails.scheme] ?? []
                                          : <String>[])
                                      .map(
                                        (subject) => DropdownMenuItem(
                                          value: subject,
                                          child: Text(
                                            subject,
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
                          : SizedBox.shrink(),
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
                      SizedBox(height: context.verticalSize(20)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Select your choice", style: context.semiBold14(color: ColorManager.blackMedium)),
                      ),
                      SizedBox(height: context.verticalSize(10)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Your Transfer first choice District",
                          style: context.semiBold14(color: ColorManager.grayText),
                        ),
                      ),
                      SizedBox(height: context.verticalSize(8)),
                      Container(
                        height: context.verticalSize(40),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: ColorManager.white10, borderRadius: BorderRadius.circular(20)),
                        child: DropdownButton<String>(
                          value: filterDetails.choice1.isNotEmpty ? filterDetails.choice1 : null,
                          hint: Text("Select 1st choice", style: context.regular14(color: ColorManager.disabledText)),
                          items:
                              filterDetails.provinceDistricts.values
                                  .expand((districtList) => districtList) // flatten all districts
                                  .map(
                                    (district) => DropdownMenuItem(
                                      value: district,
                                      child: Text(district, style: context.regular14(color: ColorManager.blackMedium)),
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
                              "Your Transfer Second choice District",
                              style: context.semiBold14(color: ColorManager.grayText),
                            ),
                          )
                          : SizedBox.shrink(),
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
                                "Select 2nd choice",
                                style: context.regular14(color: ColorManager.disabledText),
                              ),
                              items:
                                  filterDetails.provinceDistricts.values
                                      .expand((districtList) => districtList) // flatten all districts
                                      .map(
                                        (district) => DropdownMenuItem(
                                          value: district,
                                          child: Text(
                                            district,
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
                          : SizedBox.shrink(),
                      SizedBox(height: context.verticalSize(filterDetails.choice2.isNotEmpty ? 10 : 0)),
                      filterDetails.choice2.isNotEmpty
                          ? Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Your Transfer third choice District",
                              style: context.semiBold14(color: ColorManager.grayText),
                            ),
                          )
                          : SizedBox.shrink(),
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
                                "Select 3rd choice",
                                style: context.regular14(color: ColorManager.disabledText),
                              ),
                              items:
                                  filterDetails.provinceDistricts.values
                                      .expand((districtList) => districtList) // flatten all districts
                                      .map(
                                        (district) => DropdownMenuItem(
                                          value: district,
                                          child: Text(
                                            district,
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
                          : SizedBox.shrink(),
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Add any Special note", style: context.semiBold14(color: ColorManager.blackMedium)),
                      ),
                      SizedBox(height: context.verticalSize(8)),
                      CustomTextField(
                        radius: 30,
                        height: context.verticalSize(40),
                        controller: auth.noteController,
                        inputType: TextInputType.emailAddress,
                        hintText: 'note',
                        // enabled: false,
                        validator: (value) {},
                      ),
                      SizedBox(height: context.verticalSize(8)),
                      SizedBox(height: context.verticalSize(30)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Password", style: context.semiBold14(color: ColorManager.grayText)),
                      ),
                      SizedBox(height: context.verticalSize(4)),
                      CustomTextField(
                        radius: 30,
                        controller: auth.passwordController,
                        inputType: TextInputType.visiblePassword,
                        obscure: _obscureText,
                        hintText: '*******',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            setState(() {
                              passwordError = "Password is required";
                            });
                            return '';
                          } else if (value.length < 8) {
                            setState(() {
                              passwordError =
                                  "Password must be 8+ characters and include a number, uppercase letter, and special character";
                            });
                            return '';
                          } else if (value.length > 64) {
                            setState(() {
                              passwordError = "Password must be 8–64 characters long";
                            });
                            return '';
                          } else if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                            setState(() {
                              passwordError = "Must include at least one uppercase letter";
                            });
                            return '';
                          } else if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
                            setState(() {
                              passwordError = "Must include at least one number";
                            });
                            return '';
                          } else if (!RegExp(r'^(?=.*[!@#\$&*~%^()_\-+=<>?])').hasMatch(value)) {
                            setState(() {
                              passwordError = "Must include at least one special character";
                            });
                            return '';
                          }
                          setState(() {
                            passwordError = null;
                          });
                          return null;
                        },
                        errorMessage: passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: context.verticalSize(4)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Re Enter Passward", style: context.semiBold14(color: ColorManager.grayText)),
                      ),
                      SizedBox(height: context.verticalSize(4)),
                      CustomTextField(
                        radius: 30,
                        controller: auth.confirmPasswordController,
                        inputType: TextInputType.visiblePassword,
                        hintText: '*******',
                        obscure: _obscureTextConfirmPassword,
                        validator: (value) {
                          if (auth.confirmPasswordController.text.isEmpty) {
                            setState(() {
                              confirmPasswordError = "Re-enter Password is required";
                            });
                            return '';
                          } else if (value != auth.passwordController.text) {
                            setState(() {
                              confirmPasswordError = "Passwords do not match!";
                            });
                            return '';
                          }
                          setState(() {
                            confirmPasswordError = null;
                          });
                          return null;
                        },
                        errorMessage: confirmPasswordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureTextConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: context.verticalSize(36)),
                      CenterTextIconButton(
                        onPress: () async {
                          final email = auth.emailController.text.trim();
                          final isGmail = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
                            caseSensitive: false,
                          ).hasMatch(email);

                          // Trigger popup if email is empty OR if it is NOT a @gmail.com address
                          if (email.isNotEmpty && !isGmail) {
                            final shouldSave = await _saveAlertDialog(
                              context,
                              "Can't create your Account",
                              "Please connect with us via WhatsApp to create your account.",
                              'Need Help?',
                            );

                            if (shouldSave == true) {
                              contactWhatsApp("94713905383", "Hello, I need assistance with my account.");
                            }
                          } else if (informationFormKey.currentState!.validate() &&
                              _selectedDate != null &&
                              _dobErrorText == null &&
                              (auth.contactController.text.isNotEmpty ||
                                  auth.contactController.text.length > 10 ||
                                  auth.contactController.text.length < 12) &&
                              (auth.idCardController.text.isNotEmpty ||
                                  auth.idCardController.text.length > 9 ||
                                  auth.idCardController.text.length < 15) &&
                              (filterDetails.job == "Provincial School Teacher"
                                  ? filterDetails.school != ''
                                  : filterDetails.job == "National School Teacher"
                                  ? filterDetails.nationalSchool != ''
                                  : filterDetails.job == "Nurse"
                                  ? filterDetails.officeForNurse != ''
                                  : filterDetails.job == "Management Assistant"
                                  ? filterDetails.officeForMA != ''
                                  : filterDetails.job == "Police Officer"
                                  ? filterDetails.policeStations != ''
                                  : filterDetails.gramaNiladhariDivision != '') &&
                              ((filterDetails.job == "Provincial School Teacher" ||
                                      filterDetails.job == "National School Teacher")
                                  ? (filterDetails.scheme != "PRIMARY"
                                      ? filterDetails.subject != ''
                                      : filterDetails.scheme != '')
                                  : filterDetails.grade != "") &&
                              filterDetails.choice1 != '') {
                            auth.filterDetails = filterDetails;
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
                                        isSchoolSelected: isSchoolSelected,
                                        isEnable: isEnable,
                                      ),
                                ),
                              );
                            } catch (e) {
                              toastErrorMessage('Email is already verified.');
                            }
                          } else if (_selectedDate == null) {
                            setState(() {
                              _dobErrorText = 'Select a Date';
                            });
                          }
                          if (auth.contactController.text.isEmpty ||
                              auth.contactController.text.length < 10 ||
                              auth.contactController.text.length > 12) {
                            setState(() {
                              contactError = 'Incorrect contact number';
                            });
                          }
                          if (auth.idCardController.text.isEmpty ||
                              auth.idCardController.text.length < 9 ||
                              auth.idCardController.text.length > 15) {
                            setState(() {
                              idCardError = 'Incorrect ID card number';
                            });
                          }
                          if ((filterDetails.job == "Provincial School Teacher" && filterDetails.school == '') ||
                              (filterDetails.job == "National School Teacher" && filterDetails.nationalSchool == '')) {
                            setState(() {
                              schoolError = 'Select your school';
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
                              filterDetails.policeStations == '' &&
                              filterDetails.gramaNiladhariDivision == '') {
                            setState(() {
                              schoolError = 'Select your office';
                            });
                          }
                          if (filterDetails.scheme != "PRIMARY" && filterDetails.subject == '') {
                            setState(() {
                              subjectError = 'Select your subject';
                            });
                          } else {
                            setState(() {
                              subjectError = '';
                            });
                          }
                          if (filterDetails.choice1 == '') {
                            setState(() {
                              choiceError = 'Select at least 1 choice';
                            });
                          } else {
                            setState(() {
                              choiceError = '';
                            });
                          }
                        },
                        isGradientColor: true,
                        gradientColors: ColorManager.gradientButtons2,
                        // isLoading: auth.getisCreatingUser,
                        buttonText: 'Continue',
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
