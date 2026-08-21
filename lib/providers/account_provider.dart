import 'package:app/app/models/filter_model.dart';
import 'package:app/app/models/person_details_model.dart';
import 'package:app/app/utils/context_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class AccountProvider extends ChangeNotifier {
  BuildContext context = ContextHelper.navigatorKey.currentContext!;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  TextEditingController refNoController = TextEditingController();
  TextEditingController senderNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController serviceProviderController = TextEditingController();

  bool isContactVisible = false;
  bool isWhatsappVisible = false;
  bool isSchoolVisible = false;
  String emailAddress = '';

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    contactController.dispose();
    whatsappController.dispose();
    noteController.dispose();
    super.dispose();
  }

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  firebase_auth.User? _firebaseUser;
  firebase_auth.User? get firebaseUser => _firebaseUser;

  PersonDetailsModel? _appUser;
  PersonDetailsModel? get appUser => _appUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AccountProvider() {
    _auth.authStateChanges().listen((firebase_auth.User? user) async {
      _firebaseUser = user;
      _errorMessage = null;

      if (_firebaseUser != null) {
        await _fetchAndSetPersonDetailsModel(_firebaseUser!.uid);
      } else {
        _appUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> refreshCurrentUser() async {
    final user = _auth.currentUser;

    if (user == null) {
      _firebaseUser = null;
      _appUser = null;
      notifyListeners();
      return;
    }

    _firebaseUser = user;

    await _fetchAndSetPersonDetailsModel(user.uid);
  }

  Future<void> _fetchAndSetPersonDetailsModel(String uid) async {
    _isLoading = true;
    notifyListeners();

    if (_firebaseUser == null) {
      _appUser = null;
      return;
    }

    try {
      DocumentSnapshot userProfileDoc = await _firestore.collection('users').doc(uid).get();
      if (userProfileDoc.exists) {
        _appUser = PersonDetailsModel.fromAuthAndFirestore(
          firebaseUser: _firebaseUser!,
          firestoreData: userProfileDoc.data() as Map<String, dynamic>,
        );
        List<String> parts = (_appUser?.displayName ?? "").split(' ');

        firstNameController.text = parts[0];
        lastNameController.text = parts.length > 1 ? parts[1] : '';
        contactController.text = _appUser?.phone != null ? _appUser!.phone.toString() : '';

        whatsappController.text = _appUser?.whatsapp != null ? _appUser!.whatsapp.toString() : '';
        isContactVisible = _appUser?.isPhoneHide ?? false;
        isWhatsappVisible = _appUser?.isWhatsappHide ?? false;

        isSchoolVisible = _appUser?.isSchoolHide ?? false;
        noteController.text = _appUser?.note ?? '';
        emailAddress = _appUser?.authEmail ?? '';
      } else {
        _appUser = PersonDetailsModel(
          uid: _firebaseUser!.uid,
          authEmail: _firebaseUser!.email ?? '',
          displayName: _firebaseUser!.displayName,
          isEmailVerified: _firebaseUser!.emailVerified,
          createdAtAuth: _firebaseUser!.metadata.creationTime,
          lastSignInTimeAuth: _firebaseUser!.metadata.lastSignInTime,
        );
      }
    } on FirebaseException catch (e) {
      _errorMessage = "Failed to load user profile: ${e.message}";
      _appUser = PersonDetailsModel(
        uid: _firebaseUser!.uid,
        authEmail: _firebaseUser!.email ?? '',
        displayName: _firebaseUser!.displayName,
        isEmailVerified: _firebaseUser!.emailVerified,
        createdAtAuth: _firebaseUser!.metadata.creationTime,
        lastSignInTimeAuth: _firebaseUser!.metadata.lastSignInTime,
      );
    } catch (e) {
      _errorMessage = "An unexpected error occurred loading your profile.";
      _appUser = PersonDetailsModel(
        uid: _firebaseUser!.uid,
        authEmail: _firebaseUser!.email ?? '',
        displayName: _firebaseUser!.displayName,
        isEmailVerified: _firebaseUser!.emailVerified,
        createdAtAuth: _firebaseUser!.metadata.creationTime,
        lastSignInTimeAuth: _firebaseUser!.metadata.lastSignInTime,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAuthProfile({String? newDisplayName, String? newPhotoURL}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (_firebaseUser == null) {
      _errorMessage = "No user logged in to update profile.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      await _firebaseUser!.updateProfile(displayName: newDisplayName, photoURL: newPhotoURL);
      await _firebaseUser!.reload();
      _firebaseUser = _auth.currentUser;

      await _fetchAndSetPersonDetailsModel(_firebaseUser!.uid);

      _errorMessage = null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = "Failed to update profile: ${e.message}";
    } catch (e) {
      _errorMessage = "An unexpected error occurred while updating profile.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAccount(FilterModel editDetails) async {
    if (_appUser == null) {
      print("No user data to update.");
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not logged in.");
      }

      Map<String, dynamic> updatedData = {};

      String currentDisplayName = "${firstNameController.text.trim()} ${lastNameController.text.trim()}";
      String originalDisplayName = "${_appUser!.firstName} ${_appUser!.lastName}";
      String originalDisplayNameInAuth = currentUser.displayName ?? '';

      if (currentDisplayName != originalDisplayName) {
        updatedData['name'] = currentDisplayName;
      }

      if (contactController.text.trim() != _appUser!.phone) {
        updatedData['phone'] = contactController.text.trim();
      }

      if (whatsappController.text.trim() != _appUser!.whatsapp) {
        updatedData['whatsapp'] = whatsappController.text.trim();
      }
      if (isWhatsappVisible != (_appUser?.isWhatsappHide ?? false)) {
        updatedData['isWhatsappHide'] = isWhatsappVisible;
      }

      if (isContactVisible != (_appUser?.isPhoneHide ?? false)) {
        updatedData['isPhoneHide'] = isContactVisible;
      }

      if (isSchoolVisible != (_appUser?.isSchoolHide ?? false)) {
        updatedData['isSchoolHide'] = isSchoolVisible;
      }
      if (editDetails.job != "" && _appUser!.job != editDetails.job) {
        updatedData['job'] = editDetails.job;
      }
      if (editDetails.province != "" && _appUser!.province != editDetails.province) {
        updatedData['province'] = editDetails.province;
      }

      if (editDetails.district != "" && _appUser!.district != editDetails.district) {
        updatedData['district'] = editDetails.district;
      }

      if (editDetails.kalapa != "" && _appUser!.kalapa != editDetails.kalapa) {
        updatedData['kalapa'] = editDetails.kalapa;
      }

      if (editDetails.kottasa != "" && _appUser!.kottasa != editDetails.kottasa) {
        updatedData['kottasa'] = editDetails.kottasa;
      }

      if (editDetails.school != "" && _appUser!.school != editDetails.school) {
        updatedData['school'] = editDetails.school;
      }

      if (editDetails.kottasaForNationalScl != "" &&
          _appUser!.kottasaForNationalScl != editDetails.kottasaForNationalScl) {
        updatedData['kottasaForNationalScl'] = editDetails.kottasaForNationalScl;
      }

      if (editDetails.nationalSchool != "" && _appUser!.nationalSchool != editDetails.nationalSchool) {
        updatedData['nationalSchool'] = editDetails.nationalSchool;
      }

      if (editDetails.institutionTypeForNurse != "" &&
          _appUser!.institutionTypeForNurse != editDetails.institutionTypeForNurse) {
        updatedData['institutionTypeForNurse'] = editDetails.institutionTypeForNurse;
      }

      if (editDetails.officeForNurse != "" && _appUser!.officeForNurse != editDetails.officeForNurse) {
        updatedData['officeForNurse'] = editDetails.officeForNurse;
      }

      if (editDetails.institutionTypeForMA != "" &&
          _appUser!.institutionTypeForMA != editDetails.institutionTypeForMA) {
        updatedData['institutionTypeForMA'] = editDetails.institutionTypeForMA;
      }

      if (editDetails.officeForMA != "" && _appUser!.officeForMA != editDetails.officeForMA) {
        updatedData['officeForMA'] = editDetails.officeForMA;
      }

      if (editDetails.policeDivisions != "" && _appUser!.policeDivisions != editDetails.policeDivisions) {
        updatedData['policeDivisions'] = editDetails.policeDivisions;
      }

      if (editDetails.policeStations != "" && _appUser!.policeStations != editDetails.policeStations) {
        updatedData['policeStations'] = editDetails.policeStations;
      }

      if (editDetails.divisionalSecretariat != "" &&
          _appUser!.divisionalSecretariat != editDetails.divisionalSecretariat) {
        updatedData['divisionalSecretariat'] = editDetails.divisionalSecretariat;
      }

      if (editDetails.gramaNiladhariDivision != "" &&
          _appUser!.gramaNiladhariDivision != editDetails.gramaNiladhariDivision) {
        updatedData['gramaNiladhariDivision'] = editDetails.gramaNiladhariDivision;
      }

      if (editDetails.scheme != "" && _appUser!.scheme != editDetails.scheme) {
        updatedData['scheme'] = editDetails.scheme;
      }

      updatedData['subject'] = editDetails.subject;

      if (editDetails.subjectMedium != "" && _appUser!.subjectMedium != editDetails.subjectMedium) {
        updatedData['subjectMedium'] = editDetails.subjectMedium;
      }

      if (editDetails.grade != "" && _appUser!.grade != editDetails.grade) {
        updatedData['grade'] = editDetails.grade;
      }

      if (editDetails.choice1 != "" && _appUser!.choice1 != editDetails.choice1) {
        updatedData['choice1'] = editDetails.choice1;
      }

      updatedData['choice2'] = editDetails.choice2;
      updatedData['choice3'] = editDetails.choice3;

      if (noteController.text.trim() != _appUser!.note) {
        updatedData['note'] = noteController.text.trim();
      }

      updatedData['updatedAt'] = FieldValue.serverTimestamp();

      if (updatedData.isNotEmpty) {
        await _firestore.collection('users').doc(currentUser.uid).update(updatedData);
      }

      if (currentDisplayName != originalDisplayNameInAuth) {
        await currentUser.updateProfile(displayName: currentDisplayName);
        await currentUser.reload();
        currentUser = _auth.currentUser;
        _firebaseUser = currentUser;
      }

      _errorMessage = null;
      await _fetchAndSetPersonDetailsModel(currentUser?.uid ?? '');
      Navigator.of(ContextHelper.navigatorKey.currentContext!).pop();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPaymentDetails(DateTime transferDate, File? selectedImage) async {
    if (_appUser == null) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("User not logged in.");
      }

      Map<String, dynamic> updatedData = {};

      updatedData['transferDate'] = transferDate;
      updatedData['refNo'] = refNoController.text.trim();
      updatedData['accountNo'] = accountNumberController.text.trim();
      updatedData['clientName'] = senderNameController.text.trim();
      updatedData['amount'] = amountController.text.trim();
      updatedData['serviceProvider'] = serviceProviderController.text.trim();
      updatedData['isEnable'] = true;

      if (updatedData.isNotEmpty) {
        await _firestore.collection('users').doc(currentUser.uid).update(updatedData);
      }

      _errorMessage = null;
      await _fetchAndSetPersonDetailsModel(currentUser.uid);
      Navigator.of(ContextHelper.navigatorKey.currentContext!).pop();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    _isLoading = true;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _isLoading = false;
      throw Exception('No user is currently logged in.');
    }

    try {
      final credential = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      _isLoading = false;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      throw Exception(e.message ?? 'Failed to change password.');
    }
  }
}
