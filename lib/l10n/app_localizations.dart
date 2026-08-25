import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  /// No description provided for @addBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Add Basic Information'**
  String get addBasicInfo;

  /// No description provided for @welcomeText.
  ///
  /// In en, this message translates to:
  /// **'Welcome! To get started, we need a few basic details to finish setting up your account.'**
  String get welcomeText;

  /// No description provided for @legalName.
  ///
  /// In en, this message translates to:
  /// **'Legal Name'**
  String get legalName;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailNotice.
  ///
  /// In en, this message translates to:
  /// **'Please add a fresh email address and remember it carefully. This email will be used for all communication'**
  String get emailNotice;

  /// No description provided for @dob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dob;

  /// No description provided for @birthdate.
  ///
  /// In en, this message translates to:
  /// **'Birthdate'**
  String get birthdate;

  /// No description provided for @idCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Identity Card Number'**
  String get idCardNumber;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @whatsappOptional.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number (Optional)'**
  String get whatsappOptional;

  /// No description provided for @whatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number'**
  String get whatsappNumber;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @selectJobCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Your Job Category'**
  String get selectJobCategory;

  /// No description provided for @setupSchoolingDetails.
  ///
  /// In en, this message translates to:
  /// **'Setup your Schooling Details'**
  String get setupSchoolingDetails;

  /// No description provided for @setupOfficeDetails.
  ///
  /// In en, this message translates to:
  /// **'Setup your Office Details'**
  String get setupOfficeDetails;

  /// No description provided for @setupSubjectDetails.
  ///
  /// In en, this message translates to:
  /// **'Setup your Subject Details'**
  String get setupSubjectDetails;

  /// No description provided for @setupGradeDetails.
  ///
  /// In en, this message translates to:
  /// **'Setup your Grade Details'**
  String get setupGradeDetails;

  /// No description provided for @selectProvince.
  ///
  /// In en, this message translates to:
  /// **'Select Province'**
  String get selectProvince;

  /// No description provided for @selectDistrict.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get selectDistrict;

  /// No description provided for @selectKalapa.
  ///
  /// In en, this message translates to:
  /// **'Select Kalapa'**
  String get selectKalapa;

  /// No description provided for @selectInstitutionType.
  ///
  /// In en, this message translates to:
  /// **'Select Institution Type'**
  String get selectInstitutionType;

  /// No description provided for @selectKottasa.
  ///
  /// In en, this message translates to:
  /// **'Select Kottasa'**
  String get selectKottasa;

  /// No description provided for @selectOffice.
  ///
  /// In en, this message translates to:
  /// **'Select Office'**
  String get selectOffice;

  /// No description provided for @selectSchool.
  ///
  /// In en, this message translates to:
  /// **'Select School'**
  String get selectSchool;

  /// No description provided for @selectScheme.
  ///
  /// In en, this message translates to:
  /// **'Select Scheme'**
  String get selectScheme;

  /// No description provided for @selectGrade.
  ///
  /// In en, this message translates to:
  /// **'Select Grade'**
  String get selectGrade;

  /// No description provided for @selectSubjectMedium.
  ///
  /// In en, this message translates to:
  /// **'Select Subject Medium'**
  String get selectSubjectMedium;

  /// No description provided for @selectSubject.
  ///
  /// In en, this message translates to:
  /// **'Select Subject'**
  String get selectSubject;

  /// No description provided for @selectYourChoice.
  ///
  /// In en, this message translates to:
  /// **'Select your choice'**
  String get selectYourChoice;

  /// No description provided for @transferChoice1.
  ///
  /// In en, this message translates to:
  /// **'Your Transfer first choice District'**
  String get transferChoice1;

  /// No description provided for @selectChoice1.
  ///
  /// In en, this message translates to:
  /// **'Select 1st choice'**
  String get selectChoice1;

  /// No description provided for @transferChoice2.
  ///
  /// In en, this message translates to:
  /// **'Your Transfer Second choice District'**
  String get transferChoice2;

  /// No description provided for @selectChoice2.
  ///
  /// In en, this message translates to:
  /// **'Select 2nd choice'**
  String get selectChoice2;

  /// No description provided for @transferChoice3.
  ///
  /// In en, this message translates to:
  /// **'Your Transfer third choice District'**
  String get transferChoice3;

  /// No description provided for @selectChoice3.
  ///
  /// In en, this message translates to:
  /// **'Select 3rd choice'**
  String get selectChoice3;

  /// No description provided for @addSpecialNote.
  ///
  /// In en, this message translates to:
  /// **'Add any Special note'**
  String get addSpecialNote;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'note'**
  String get note;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @reEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re Enter Password'**
  String get reEnterPassword;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @editInformation.
  ///
  /// In en, this message translates to:
  /// **'Edit information'**
  String get editInformation;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @removePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove photo?'**
  String get removePhotoTitle;

  /// No description provided for @removePhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the uploaded photo?'**
  String get removePhotoDesc;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @goBackConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to go back?'**
  String get goBackConfirmTitle;

  /// No description provided for @goBackConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. This will undo your changes to previous Stage'**
  String get goBackConfirmDesc;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'GO BACK'**
  String get goBack;

  /// No description provided for @choosePhotoSource.
  ///
  /// In en, this message translates to:
  /// **'Choose photo source'**
  String get choosePhotoSource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from gallery'**
  String get selectFromGallery;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetAllFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset All Filters?'**
  String get resetAllFiltersTitle;

  /// No description provided for @resetAllFiltersDesc.
  ///
  /// In en, this message translates to:
  /// **'This action will clear all of your currently selected filters and cannot be undone.'**
  String get resetAllFiltersDesc;

  /// No description provided for @locationFilterChoice.
  ///
  /// In en, this message translates to:
  /// **'Location Filter According to choice'**
  String get locationFilterChoice;

  /// No description provided for @schoolFilter.
  ///
  /// In en, this message translates to:
  /// **'School Filter'**
  String get schoolFilter;

  /// No description provided for @officeFilter.
  ///
  /// In en, this message translates to:
  /// **'Office Filter'**
  String get officeFilter;

  /// No description provided for @schemeSubjectFilter.
  ///
  /// In en, this message translates to:
  /// **'Scheme & Subject Filter'**
  String get schemeSubjectFilter;

  /// No description provided for @gradeFilter.
  ///
  /// In en, this message translates to:
  /// **'Grade Filter'**
  String get gradeFilter;

  /// No description provided for @searchName.
  ///
  /// In en, this message translates to:
  /// **'Search a name...'**
  String get searchName;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @reqFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name is required'**
  String get reqFirstName;

  /// No description provided for @reqValidFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid First Name'**
  String get reqValidFirstName;

  /// No description provided for @reqLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name is required'**
  String get reqLastName;

  /// No description provided for @reqValidLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Last Name'**
  String get reqValidLastName;

  /// No description provided for @reqEmail.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get reqEmail;

  /// No description provided for @reqValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get reqValidEmail;

  /// No description provided for @reqId.
  ///
  /// In en, this message translates to:
  /// **'ID number is required'**
  String get reqId;

  /// No description provided for @reqValidId.
  ///
  /// In en, this message translates to:
  /// **'Enter Valid ID number'**
  String get reqValidId;

  /// No description provided for @reqContact.
  ///
  /// In en, this message translates to:
  /// **'Contact number is required'**
  String get reqContact;

  /// No description provided for @reqValidContact.
  ///
  /// In en, this message translates to:
  /// **'Enter Valid Contact number'**
  String get reqValidContact;

  /// No description provided for @reqValidWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Enter Valid WhatsApp number'**
  String get reqValidWhatsapp;

  /// No description provided for @reqPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get reqPassword;

  /// No description provided for @reqPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be 8+ characters and include a number, uppercase letter, and special character'**
  String get reqPasswordLength;

  /// No description provided for @reqPasswordMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match!'**
  String get reqPasswordMatch;

  /// No description provided for @reqSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a Date'**
  String get reqSelectDate;

  /// No description provided for @reqSelectSchool.
  ///
  /// In en, this message translates to:
  /// **'Select your school'**
  String get reqSelectSchool;

  /// No description provided for @reqSelectOffice.
  ///
  /// In en, this message translates to:
  /// **'Select your office'**
  String get reqSelectOffice;

  /// No description provided for @reqSelectSubject.
  ///
  /// In en, this message translates to:
  /// **'Select your subject'**
  String get reqSelectSubject;

  /// No description provided for @reqSelectMedium.
  ///
  /// In en, this message translates to:
  /// **'Select your subject medium'**
  String get reqSelectMedium;

  /// No description provided for @reqSelectChoice.
  ///
  /// In en, this message translates to:
  /// **'Select at least 1 choice'**
  String get reqSelectChoice;

  /// No description provided for @chatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsTitle;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorPrefix;

  /// No description provided for @noActiveChats.
  ///
  /// In en, this message translates to:
  /// **'No active chats.'**
  String get noActiveChats;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'UnMute'**
  String get unmute;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @pleaseLoginToSeeChats.
  ///
  /// In en, this message translates to:
  /// **'Please login to see chats.'**
  String get pleaseLoginToSeeChats;

  /// No description provided for @accountDisabledMsg.
  ///
  /// In en, this message translates to:
  /// **'Your account has been disabled. Please contact support for more information.'**
  String get accountDisabledMsg;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @filterYourResults.
  ///
  /// In en, this message translates to:
  /// **'Filter your Results'**
  String get filterYourResults;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No Data Found!'**
  String get noDataFound;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get unknown;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @newText.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newText;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @occupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @whatsappLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsappLabel;

  /// No description provided for @provinceLabel.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get provinceLabel;

  /// No description provided for @districtLabel.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get districtLabel;

  /// No description provided for @kalapaLabel.
  ///
  /// In en, this message translates to:
  /// **'Kalapa'**
  String get kalapaLabel;

  /// No description provided for @policeDivisionLabel.
  ///
  /// In en, this message translates to:
  /// **'Police Division'**
  String get policeDivisionLabel;

  /// No description provided for @divisionalSecretariatLabel.
  ///
  /// In en, this message translates to:
  /// **'D. Secretariat'**
  String get divisionalSecretariatLabel;

  /// No description provided for @institutionLabel.
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get institutionLabel;

  /// No description provided for @schoolLabel.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get schoolLabel;

  /// No description provided for @policeStationLabel.
  ///
  /// In en, this message translates to:
  /// **'Police Station'**
  String get policeStationLabel;

  /// No description provided for @officeLabel.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get officeLabel;

  /// No description provided for @schemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Scheme'**
  String get schemeLabel;

  /// No description provided for @gradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get gradeLabel;

  /// No description provided for @subjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subjectLabel;

  /// No description provided for @mediumLabel.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mediumLabel;

  /// No description provided for @choice1Label.
  ///
  /// In en, this message translates to:
  /// **'Choice 1'**
  String get choice1Label;

  /// No description provided for @choice2Label.
  ///
  /// In en, this message translates to:
  /// **'Choice 2'**
  String get choice2Label;

  /// No description provided for @choice3Label.
  ///
  /// In en, this message translates to:
  /// **'Choice 3'**
  String get choice3Label;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @hidden.
  ///
  /// In en, this message translates to:
  /// **'(Hidden)'**
  String get hidden;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help and Support'**
  String get helpAndSupport;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'This will sign you out of the application and reset all your data.'**
  String get signOutConfirmDesc;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all associated data. This action cannot be undone.'**
  String get deleteAccountConfirmDesc;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'VERSION'**
  String get version;

  /// No description provided for @takePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhotoTitle;

  /// No description provided for @cameraInstruction.
  ///
  /// In en, this message translates to:
  /// **'Step back and capture a clear, well-framed photo that provides the best details possible.'**
  String get cameraInstruction;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @photoPreviewInstruction.
  ///
  /// In en, this message translates to:
  /// **'Before submitting your request, please make \nsure that the photo shows the charging station in its entirety'**
  String get photoPreviewInstruction;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'A verification link has been sent to your email.\nPlease verify and then click continue.'**
  String get verifyEmailMessage;

  /// No description provided for @iVerifiedContinue.
  ///
  /// In en, this message translates to:
  /// **'I Verified, Continue'**
  String get iVerifiedContinue;

  /// No description provided for @verificationEmailResent.
  ///
  /// In en, this message translates to:
  /// **'Verification email resent'**
  String get verificationEmailResent;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerificationEmail;

  /// No description provided for @emailNotVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet!'**
  String get emailNotVerifiedYet;

  /// No description provided for @cantCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Can\'t create your Account'**
  String get cantCreateAccount;

  /// No description provided for @connectWhatsappToCreate.
  ///
  /// In en, this message translates to:
  /// **'Please connect with us via WhatsApp to create your account.'**
  String get connectWhatsappToCreate;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get needHelp;

  /// No description provided for @newVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'New Version Available'**
  String get newVersionAvailable;

  /// No description provided for @newVersionMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available. Please update to continue using the app.'**
  String get newVersionMessage;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @transactionRequestingDistrict.
  ///
  /// In en, this message translates to:
  /// **'Transaction Requesting for(District) -'**
  String get transactionRequestingDistrict;

  /// No description provided for @firstChoiceIndicator.
  ///
  /// In en, this message translates to:
  /// **' (1st Choice)'**
  String get firstChoiceIndicator;

  /// No description provided for @secondThirdChoiceIndicator.
  ///
  /// In en, this message translates to:
  /// **' (2nd & 3rd Choice)'**
  String get secondThirdChoiceIndicator;

  /// No description provided for @contentHiddenTooltip.
  ///
  /// In en, this message translates to:
  /// **'This content is hidden. Tap the chat icon to request your details.'**
  String get contentHiddenTooltip;

  /// No description provided for @contactIndicator.
  ///
  /// In en, this message translates to:
  /// **'   Contact :  '**
  String get contactIndicator;

  /// No description provided for @whatsappIndicator.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp: '**
  String get whatsappIndicator;

  /// No description provided for @chatWithWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Chat with WhatsApp'**
  String get chatWithWhatsapp;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @userDetailsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'User details no longer available'**
  String get userDetailsUnavailable;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as Read ✅'**
  String get markAsRead;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @reqCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password is required'**
  String get reqCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @reqNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password is required'**
  String get reqNewPassword;

  /// No description provided for @reqPasswordLength64.
  ///
  /// In en, this message translates to:
  /// **'New Password must be 8–64 characters long'**
  String get reqPasswordLength64;

  /// No description provided for @reqUppercase.
  ///
  /// In en, this message translates to:
  /// **'Must include at least one uppercase letter'**
  String get reqUppercase;

  /// No description provided for @reqNumber.
  ///
  /// In en, this message translates to:
  /// **'Must include at least one number'**
  String get reqNumber;

  /// No description provided for @reqSpecialChar.
  ///
  /// In en, this message translates to:
  /// **'Must include at least one special character'**
  String get reqSpecialChar;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @reqConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password is required'**
  String get reqConfirmPassword;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangedSuccess;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get currentPasswordIncorrect;

  /// No description provided for @editPaymentInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit Payment Information'**
  String get editPaymentInfo;

  /// No description provided for @transferDate.
  ///
  /// In en, this message translates to:
  /// **'Transfer Date'**
  String get transferDate;

  /// No description provided for @refNo.
  ///
  /// In en, this message translates to:
  /// **'Ref No'**
  String get refNo;

  /// No description provided for @reqRefNo.
  ///
  /// In en, this message translates to:
  /// **'Ref Number is required'**
  String get reqRefNo;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @reqAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number is required'**
  String get reqAccountNumber;

  /// No description provided for @senderName.
  ///
  /// In en, this message translates to:
  /// **'Sender Name'**
  String get senderName;

  /// No description provided for @reqName.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get reqName;

  /// No description provided for @reqNameLength.
  ///
  /// In en, this message translates to:
  /// **'Must be 1–100 characters'**
  String get reqNameLength;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @reqValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Input valid amount'**
  String get reqValidAmount;

  /// No description provided for @serviceProvider.
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get serviceProvider;

  /// No description provided for @reqServiceProvider.
  ///
  /// In en, this message translates to:
  /// **'Service Provider is required'**
  String get reqServiceProvider;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @noUserLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'No user is currently logged in.'**
  String get noUserLoggedIn;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// No description provided for @enterPasswordToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password to continue.'**
  String get enterPasswordToContinue;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @cannotLoadChat.
  ///
  /// In en, this message translates to:
  /// **'Cannot load chat. Missing user ID or contact.'**
  String get cannotLoadChat;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @sayHello.
  ///
  /// In en, this message translates to:
  /// **'Say hello!'**
  String get sayHello;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Message...'**
  String get messageHint;

  /// No description provided for @homeNav.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNav;

  /// No description provided for @notificationsNav.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsNav;

  /// No description provided for @chatNav.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chatNav;

  /// No description provided for @accountNav.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountNav;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @loginBelow.
  ///
  /// In en, this message translates to:
  /// **'Log in to your account below'**
  String get loginBelow;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?    '**
  String get dontHaveAccount;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get createNewAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @cantLogInOrCreate.
  ///
  /// In en, this message translates to:
  /// **'Can\'t Log In or Create an Account?    '**
  String get cantLogInOrCreate;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailed;

  /// No description provided for @whatsappSupportMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello, I need assistance with my account.'**
  String get whatsappSupportMessage;

  /// No description provided for @transferCycles.
  ///
  /// In en, this message translates to:
  /// **'Transfer Cycles'**
  String get transferCycles;

  /// No description provided for @firstChoiceTab.
  ///
  /// In en, this message translates to:
  /// **'1st Choice'**
  String get firstChoiceTab;

  /// No description provided for @secondChoiceTab.
  ///
  /// In en, this message translates to:
  /// **'2nd Choice'**
  String get secondChoiceTab;

  /// No description provided for @thirdChoiceTab.
  ///
  /// In en, this message translates to:
  /// **'3rd Choice'**
  String get thirdChoiceTab;

  /// No description provided for @twoPersonTab.
  ///
  /// In en, this message translates to:
  /// **'2-Person'**
  String get twoPersonTab;

  /// No description provided for @threePersonTab.
  ///
  /// In en, this message translates to:
  /// **'3-Person'**
  String get threePersonTab;

  /// No description provided for @fourPersonTab.
  ///
  /// In en, this message translates to:
  /// **'4-Person'**
  String get fourPersonTab;

  /// No description provided for @noMatchesFound.
  ///
  /// In en, this message translates to:
  /// **'No matches found.'**
  String get noMatchesFound;

  /// No description provided for @twoPersonCycle.
  ///
  /// In en, this message translates to:
  /// **'2-Person Cycle'**
  String get twoPersonCycle;

  /// No description provided for @threePersonCycle.
  ///
  /// In en, this message translates to:
  /// **'3-Person Cycle'**
  String get threePersonCycle;

  /// No description provided for @fourPersonCycle.
  ///
  /// In en, this message translates to:
  /// **'4-Person Cycle'**
  String get fourPersonCycle;

  /// No description provided for @viewCycleFlow.
  ///
  /// In en, this message translates to:
  /// **'View Cycle Flow'**
  String get viewCycleFlow;

  /// No description provided for @cycleDetails.
  ///
  /// In en, this message translates to:
  /// **'Cycle Details'**
  String get cycleDetails;

  /// No description provided for @matchFulfillsChoice.
  ///
  /// In en, this message translates to:
  /// **'This match fulfills your choice:'**
  String get matchFulfillsChoice;

  /// No description provided for @cycleConfirmationNotice.
  ///
  /// In en, this message translates to:
  /// **'This cycle requires all people to confirm the transfer. If one cancels, the cycle breaks.'**
  String get cycleConfirmationNotice;

  /// No description provided for @currentPost.
  ///
  /// In en, this message translates to:
  /// **'Current Post:'**
  String get currentPost;

  /// No description provided for @transfersTo.
  ///
  /// In en, this message translates to:
  /// **'Transfers to:'**
  String get transfersTo;

  /// No description provided for @cycleCompletesBackTo.
  ///
  /// In en, this message translates to:
  /// **'Cycle completes back to'**
  String get cycleCompletesBackTo;

  /// No description provided for @findMultiPersonCycles.
  ///
  /// In en, this message translates to:
  /// **'Find Multi-Person Transfer Cycles'**
  String get findMultiPersonCycles;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
