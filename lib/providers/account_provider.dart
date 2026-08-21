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
  // TextEditingController passwordController = TextEditingController();
  // TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  TextEditingController refNoController = TextEditingController();
  TextEditingController senderNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController serviceProviderController = TextEditingController();

  bool isContactVisible = false;
  bool isSchoolVisible = false;
  String emailAddress = '';

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    contactController.dispose();
    // passwordController.dispose();
    // confirmPasswordController.dispose();
    noteController.dispose();
    super.dispose();
  }

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  firebase_auth.User? _firebaseUser;
  firebase_auth.User? get firebaseUser => _firebaseUser;

  // --- Change this type to PersonDetailsModel ---
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
        // --- Fetch and set the PersonDetailsModel when auth state changes ---
        await _fetchAndSetPersonDetailsModel(_firebaseUser!.uid);
      } else {
        _appUser = null; // Clear combined profile on logout
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

  // --- NEW: Helper to fetch and set the PersonDetailsModel ---
  Future<void> _fetchAndSetPersonDetailsModel(String uid) async {
    // We need _firebaseUser to be non-null here to construct PersonDetailsModel
    _isLoading = true;
    notifyListeners();

    if (_firebaseUser == null) {
      _appUser = null;
      return;
    }

    try {
      DocumentSnapshot userProfileDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userProfileDoc.exists) {
        _appUser = PersonDetailsModel.fromAuthAndFirestore(
          firebaseUser: _firebaseUser!,
          firestoreData: userProfileDoc.data() as Map<String, dynamic>,
        );
        List<String> parts = (_appUser?.displayName ?? "").split(' ');
        print("_appUser?.isEnable");
        print(_appUser?.isEnable);
        print("_appUser?.isEnable");
        firstNameController.text = parts[0];
        lastNameController.text = parts.length > 1 ? parts[1] : '';
        contactController.text =
            _appUser?.phone != null ? _appUser!.phone.toString() : '';
        isContactVisible = _appUser?.isPhoneHide ?? false;
        isSchoolVisible = _appUser?.isSchoolHide ?? false;
        noteController.text = _appUser?.note ?? '';
        emailAddress = _appUser?.authEmail ?? '';
      } else {
        // Handle case where Firestore profile might not exist (e.g., old user, or error)
        // You might create a basic PersonDetailsModel with only Auth data here
        _appUser = PersonDetailsModel(
          uid: _firebaseUser!.uid,
          authEmail: _firebaseUser!.email ?? '',
          displayName: _firebaseUser!.displayName,
          isEmailVerified: _firebaseUser!.emailVerified,
          createdAtAuth: _firebaseUser!.metadata.creationTime,
          lastSignInTimeAuth: _firebaseUser!.metadata.lastSignInTime,
        );
        print(
          "Firestore profile not found for UID: $uid. Using only Auth data.",
        );
      }
    } on FirebaseException catch (e) {
      _errorMessage = "Failed to load user profile: ${e.message}";
      // Fallback to Auth-only data if Firestore fetch fails
      _appUser = PersonDetailsModel(
        uid: _firebaseUser!.uid,
        authEmail: _firebaseUser!.email ?? '',
        displayName: _firebaseUser!.displayName,
        isEmailVerified: _firebaseUser!.emailVerified,
        createdAtAuth: _firebaseUser!.metadata.creationTime,
        lastSignInTimeAuth: _firebaseUser!.metadata.lastSignInTime,
      );
      print("Error fetching Firestore profile for UID $uid: ${e.message}");
    } catch (e) {
      print("General error fetching Firestore profile for UID $uid: $e");
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

  Future<void> updateAuthProfile({
    String? newDisplayName,
    String? newPhotoURL,
  }) async {
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
      await _firebaseUser!.updateProfile(
        displayName: newDisplayName,
        photoURL: newPhotoURL,
      );
      await _firebaseUser!.reload(); // Reload to get the latest profile data
      _firebaseUser = _auth.currentUser; // Update the internal _firebaseUser

      // Re-fetch/rebuild the _appUser (now PersonDetailsModel)
      await _fetchAndSetPersonDetailsModel(_firebaseUser!.uid);

      print("Auth profile updated successfully.");
      _errorMessage = null; // Clear error on success
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("Error updating Auth profile: ${e.code} - ${e.message}");
      _errorMessage = "Failed to update profile: ${e.message}";
    } catch (e) {
      print("General error updating Auth profile: $e");
      _errorMessage = "An unexpected error occurred while updating profile.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Placeholder for Phone Number Update (more complex due to verification) ---
  Future<void> updatePhoneNumber(String newPhoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (_firebaseUser == null) {
      _errorMessage = "No user logged in to update phone number.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      // Implement phone number verification flow here.
      // ... (as described previously)
      _errorMessage = "Phone number update requires a full verification flow.";
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("Error initiating phone number update: ${e.code} - ${e.message}");
      _errorMessage = "Failed to initiate phone update: ${e.message}";
    } catch (e) {
      print("General error initiating phone number update: $e");
      _errorMessage = "An unexpected error occurred.";
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

      // Compare and add only changed Firestore fields
      String currentDisplayName =
          "${firstNameController.text.trim()} ${lastNameController.text.trim()}";
      String originalDisplayName =
          "${_appUser!.firstName} ${_appUser!.lastName}";
      String originalDisplayNameInAuth = currentUser.displayName ?? '';

      // Check if name has changed (composed from first and last names)
      if (currentDisplayName != originalDisplayName) {
        updatedData['name'] = currentDisplayName;
      }

      if (contactController.text.trim() != _appUser!.phone) {
        updatedData['phone'] = contactController.text.trim();
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
      if (editDetails.province != "" &&
          _appUser!.province != editDetails.province) {
        updatedData['province'] =
            editDetails.province; // Replace with province from controller
      }

      if (editDetails.district != "" &&
          _appUser!.district != editDetails.district) {
        updatedData['district'] =
            editDetails.district; // Replace with district from controller
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

      if (editDetails.kottasaForNationalScl != "" && _appUser!.kottasaForNationalScl != editDetails.kottasaForNationalScl) {
        updatedData['kottasaForNationalScl'] = editDetails.kottasaForNationalScl;
      }

      if (editDetails.nationalSchool != "" && _appUser!.nationalSchool != editDetails.nationalSchool) {
        updatedData['nationalSchool'] = editDetails.nationalSchool;
      }

      if (editDetails.institutionTypeForNurse != "" && _appUser!.institutionTypeForNurse != editDetails.institutionTypeForNurse) {
        updatedData['institutionTypeForNurse'] = editDetails.institutionTypeForNurse;
      }

      if (editDetails.officeForNurse != "" && _appUser!.officeForNurse != editDetails.officeForNurse) {
        updatedData['officeForNurse'] = editDetails.officeForNurse;
      }

      if (editDetails.institutionTypeForMA != "" && _appUser!.institutionTypeForMA != editDetails.institutionTypeForMA) {
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

      if (editDetails.divisionalSecretariat != "" && _appUser!.divisionalSecretariat != editDetails.divisionalSecretariat) {
        updatedData['divisionalSecretariat'] = editDetails.divisionalSecretariat;
      }

      if (editDetails.gramaNiladhariDivision != "" && _appUser!.gramaNiladhariDivision != editDetails.gramaNiladhariDivision) {
        updatedData['gramaNiladhariDivision'] = editDetails.gramaNiladhariDivision;
      }

      if (editDetails.scheme != "" && _appUser!.scheme != editDetails.scheme) {
        updatedData['scheme'] = editDetails.scheme;
      }

      updatedData['subject'] = editDetails.subject;

      if (editDetails.grade != "" && _appUser!.grade != editDetails.grade) {
        updatedData['grade'] = editDetails.grade;
      }

      if (editDetails.choice1 != "" &&
          _appUser!.choice1 != editDetails.choice1) {
        updatedData['choice1'] = editDetails.choice1;
      }

      updatedData['choice2'] = editDetails.choice2;

      updatedData['choice3'] = editDetails.choice3;

      if (noteController.text.trim() != _appUser!.note) {
        updatedData['note'] = noteController.text.trim();
      }

      // Add a server timestamp for when the document was last updated
      updatedData['updatedAt'] = FieldValue.serverTimestamp();

      if (updatedData.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .update(updatedData);
        print("User data updated in Firestore for UID: ${currentUser.uid}");
      } else {
        print("No changes detected for Firestore update.");
      }

      // Update Auth displayName if it has changed
      if (currentDisplayName != originalDisplayNameInAuth) {
        await currentUser.updateProfile(displayName: currentDisplayName);
        print("Auth displayName updated.");
        await currentUser.reload();
        currentUser = _auth.currentUser;
        _firebaseUser = currentUser;
      }

      _errorMessage = null;
      // After update, you might want to refresh _appUser or specific controllers
      // by re-fetching the user data or manually updating _appUser's properties.
      await _fetchAndSetPersonDetailsModel(
        currentUser?.uid ?? '',
      ); // Re-fetch to ensure _appUser is up-to-date
      Navigator.of(ContextHelper.navigatorKey.currentContext!).pop();
    } catch (e) {
      _errorMessage = e.toString();
      print("Error updating accountt: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPaymentDetails(
    DateTime transferDate,
    File? selectedImage,
  ) async {
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

      updatedData['transferDate'] = transferDate;
      updatedData['refNo'] = refNoController.text.trim();
      updatedData['accountNo'] = accountNumberController.text.trim();
      updatedData['clientName'] = senderNameController.text.trim();
      updatedData['amount'] = amountController.text.trim();
      updatedData['serviceProvider'] = serviceProviderController.text.trim();
      updatedData['isEnable'] = true;

      // if (selectedImage != null) {
      //   // Create a unique file path for the image in Cloud Storage
      //   // Recommended structure: users/<user_uid>/payment_images/<timestamp>_<original_filename>
      //   final String fileName = selectedImage.path.split('/').last;
      //   final String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      //   print(await selectedImage.exists());

      //   final firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance
      //       .ref()
      //       .child('users')
      //       .child(currentUser.uid)
      //       .child('payment_images')
      //       .child(uniqueFileName);

      //   // Upload the file
      //   final firebase_storage.UploadTask uploadTask = storageRef.putFile(selectedImage);

      //   // Await the completion of the upload and get the snapshot
      //   // final firebase_storage.TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      //   final firebase_storage.TaskSnapshot snapshot = await uploadTask;

      //   // Get the download URL of the uploaded image
      //   final String downloadUrl = await snapshot.ref.getDownloadURL();

      //   // Add the download URL to the data you'll save in Firestore
      //   updatedData['paymentImageUrl'] = downloadUrl;
      //   print("Payment image uploaded successfully to: $downloadUrl");
      // }

      if (updatedData.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .update(updatedData);
        print("User data updated in Firestore for UID: ${currentUser.uid}");
      } else {
        print("No changes detected for Firestore update.");
      }

      _errorMessage = null;
      await _fetchAndSetPersonDetailsModel(currentUser.uid);
      Navigator.of(ContextHelper.navigatorKey.currentContext!).pop();
    } catch (e) {
      _errorMessage = e.toString();
      print("Error updating account: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
    _isLoading = false;
      throw Exception('No user is currently logged in.');
    }

    try {
      // Reauthenticate the user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update the password
      await user.updatePassword(newPassword);
    _isLoading = false;
    } on FirebaseAuthException catch (e) {
    _isLoading = false;
      throw Exception(e.message ?? 'Failed to change password.');
    }
  }

  //   Future<void> updateUserProfile(PersonDetailsModel user) async {
  //   await _firestore.collection('users').doc(user.uid).update(user.toFirestore());
  //   _appUser = user;
  //   notifyListeners();
  // }
}
