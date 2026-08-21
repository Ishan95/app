import 'dart:io';

import 'package:app/app/models/filter_model.dart';
import 'package:app/app/models/person_details_model.dart';
import 'package:app/app/utils/context_helper.dart';
import 'package:app/providers/service_providers/firebase_service.dart';
import 'package:app/screens/delete/reauthenticate_screen.dart';
import 'package:app/screens/onboarding/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider extends ChangeNotifier {
  BuildContext context = ContextHelper.navigatorKey.currentContext!;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController idCardController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    idCardController.dispose();
    contactController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    noteController.dispose();
    super.dispose();
  }

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Represents the current user, or null if logged out
  firebase_auth.User? _user;
  firebase_auth.User? get user => _user;

  PersonDetailsModel? _appUser;
  PersonDetailsModel? get appUser => _appUser;

  // Track loading state for UI feedback
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error message for UI display
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Constructor to listen for auth state changes
  AuthenticationProvider() {
    _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) {
      _user = firebaseUser;
      _errorMessage = null; // Clear error on auth state change
      notifyListeners(); // Notify all listening widgets that the user state has changed
    });
  }

  Future<firebase_auth.User?> registerEmail(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      firebase_auth.User user = credential.user!;
      await user.sendEmailVerification();
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> reloadAndCheckVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Future<void> createUserFirestore({
  //   required firebase_auth.User user,
  //   required Map<String, dynamic> profileData,
  // }) async {
  //   await _firestore.collection('users').doc(user.uid).set(profileData);
  // }

  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return android.id ?? "unknown-android";
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      return ios.identifierForVendor ?? "unknown-ios";
    }

    return "unknown-device";
  }

  FilterModel filterDetails = FilterModel();

  Future<bool> createAccount({
    int? age,
    bool isPhoneHide = false,
    bool isSchoolHide = false,
    bool isEnable = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newUser = _auth.currentUser;
      if (newUser == null) return false;
      final String currentDevice = await getDeviceId();

      final existingDeviceQuery = await _firestore
        .collection('users')
        .where('deviceId', isEqualTo: currentDevice)
        .limit(1)
        .get();

      if (existingDeviceQuery.docs.isNotEmpty) {
        // Set a distinct error code/message so the UI knows to show the custom dialog
        _errorMessage = "DEVICE_ALREADY_EXISTS";
        return false;
      }

      if (newUser != null) {
        // Set Auth displayName
        await newUser.updateProfile(
          displayName:
              "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
        );

        // String? token = await FirebaseService.getFcmToken();
        // print("FCM Token retrievedddd: $token");
        String? token;

        try {
          token = await FirebaseService.getFcmToken();
          print("FCM Token: $token");
        } catch (e) {
          print("Couldn't get FCM token yet: $e");
          token = null;
        }

        // Prepare data for Firestore using your model's fields
        Map<String, dynamic> firestoreData = {
          // 'id': id,
          'nicNo': idCardController.text.trim(),
          'name':
              '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
          'email':
              emailController.text
                  .trim(), // Storing in Firestore too for queries
          'age': age,
          'phone': contactController.text.trim(),
          'isPhoneHide': isPhoneHide,
          'isSchoolHide': isSchoolHide,
          'job': filterDetails.job,
          'province': filterDetails.province,
          'district': filterDetails.district,
          'kalapa': filterDetails.kalapa,
          'kottasa': filterDetails.kottasa,
          'school': filterDetails.school,
          'kottasaForNationalScl': filterDetails.kottasaForNationalScl,
          'nationalSchool': filterDetails.nationalSchool,
          'institutionTypeForNurse': filterDetails.institutionTypeForNurse,
          'officeForNurse': filterDetails.officeForNurse,
          'institutionTypeForMA': filterDetails.institutionTypeForMA,
          'officeForMA': filterDetails.officeForMA,
          'policeDivisions': filterDetails.policeDivisions,
          'policeStations': filterDetails.policeStations,
          'divisionalSecretariat': filterDetails.divisionalSecretariat,
          'gramaNiladhariDivision': filterDetails.gramaNiladhariDivision,
          'scheme': filterDetails.scheme,
          'subject': filterDetails.subject,
          'grade': filterDetails.grade,
          'choice1': filterDetails.choice1,
          'choice2': filterDetails.choice2,
          'choice3': filterDetails.choice3,
          'note': noteController.text.trim(),
          'isEnable': isEnable,
          'createdAt': FieldValue.serverTimestamp(),
          'uid': newUser.uid,
          'fcmToken': token,
          'lastLogin': FieldValue.serverTimestamp(),
          'deviceId': currentDevice, // for 2 devices restriction feature
        };

        await _firestore
            .collection('users')
            .doc(newUser.uid)
            .set(firestoreData);
        print(
          "Additional user data saved to Firestore for UID: ${newUser.uid}",
        );
        _errorMessage = null;

        //  Populate _appUser with the newly created PersonDetailsModel
        _appUser = PersonDetailsModel.fromAuthAndFirestore(
          firebaseUser: newUser,
          firestoreData: firestoreData,
        );
        await notifyMatches(firestoreData, newUser.uid);
        return true;
      } else {
        _errorMessage =
            "Account created, but failed to retrieve user data to save profile.";
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("Error creating user (Auth): ${e.code} - ${e.message}");
      _errorMessage = _getFirebaseAuthErrorMessage(e.code);
      return false;
    } on FirebaseException catch (e) {
      print("Error saving user profile to Firestore: ${e.code} - ${e.message}");
      _errorMessage =
          "Account created, but failed to save profile: ${e.message}";
      return false;
    } catch (e) {
      print("General error during account creation: $e");
      _errorMessage = "An unexpected error occurred.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> notifyMatches(Map<String, dynamic> newUserInfo, String currentUid) async {
  final db = FirebaseFirestore.instance;

  // Prepare choices list (filter out nulls/empty strings)
  List<String> newUserChoices = [
    newUserInfo['choice1'],
    newUserInfo['choice2'],
    newUserInfo['choice3'],
  ].where((c) => c != null && c.toString().isNotEmpty).cast<String>().toList();

  // 1. Guard against empty choices list to prevent Firestore crash
  if (newUserChoices.isEmpty) {
    return; 
  }

  // 2. Base Query
  Query query = db.collection('users');

  // Extract job safely from newUserInfo
  final String userJob = newUserInfo['job'] ?? '';

  // 3. Apply Job Role Filter (Ensures Nurses only see Nurses, etc.)
  if (userJob.isNotEmpty) {
    query = query.where('job', isEqualTo: userJob);
  }

  // 4. Apply Teacher-Specific Filters
  final isTeacher = userJob == "Provincial School Teacher" || 
                    userJob == "National School Teacher";

  if (isTeacher) {
    query = query
        .where('scheme', isEqualTo: newUserInfo['scheme'])
        .where('subject', isEqualTo: newUserInfo['subject']);
  }

  // 5. Apply District Choices Filter
  query = query.where('district', whereIn: newUserChoices);

  // 6. Execute single query
  final matchesQuery = await query.get();

  final batch = db.batch();

  for (var doc in matchesQuery.docs) {
    // FIX: Explicitly cast doc.data() to Map<String, dynamic>
    Map<String, dynamic> matchedUserData = doc.data() as Map<String, dynamic>;
    
    // Skip self-notification if current user is in results
    if (doc.id == currentUid) continue;

    // 1. Identify which choice of User B (the receiver) matches User A's district
    String matchingChoiceTitle = "New Match Found!"; // Default
    if (matchedUserData['choice1'] == newUserInfo['district']) {
      matchingChoiceTitle = "Match under Choice 1";
    } else if (matchedUserData['choice2'] == newUserInfo['district']) {
      matchingChoiceTitle = "Match under Choice 2";
    } else if (matchedUserData['choice3'] == newUserInfo['district']) {
      matchingChoiceTitle = "Match under Choice 3";
    }

    // 2. RECIPROCAL CHECK: Does User B want to come where User A is?
    List<String> matchedUserChoices = [
      matchedUserData['choice1'],
      matchedUserData['choice2'],
      matchedUserData['choice3'],
    ].where((c) => c != null).cast<String>().toList();

    if (matchedUserChoices.contains(newUserInfo['district'])) {
      final notificationRef = db.collection('notifications').doc();
      
      batch.set(notificationRef, {
        'receiverId': doc.id,
        'senderId': currentUid,
        'title': matchingChoiceTitle,
        'message': '${newUserInfo['firstName'] ?? 'A user'} wants to move to ${matchedUserData['district']}.',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  await batch.commit();
}

//   Future<void> notifyMatches(Map<String, dynamic> newUserInfo, String currentUid) async {
//   final db = FirebaseFirestore.instance;

//   // Prepare choices list (filter out nulls/empty strings)
//   List<String> newUserChoices = [
//     newUserInfo['choice1'],
//     newUserInfo['choice2'],
//     newUserInfo['choice3'],
//   ].where((c) => c != null && c.toString().isNotEmpty).cast<String>().toList();

//   // final matchesQuery = await db.collection('users')
//   //     .where('scheme', isEqualTo: newUserInfo['scheme'])
//   //     .where('subject', isEqualTo: newUserInfo['subject'])
//   //     .where('district', whereIn: newUserChoices) 
//   //     .get();

//   // 1. Guard against empty choices list to prevent Firestore crash
// if (newUserChoices.isEmpty) {
//   // Return empty result or handle accordingly
//   return; 
// }

// // 2. Base Query
// Query query = db.collection('users');

// // 3. Apply Job Role Filter (Ensures Nurses only see Nurses, etc.)
// if (filterDetails.job.isNotEmpty) {
//   query = query.where('job', isEqualTo: filterDetails.job);
// }

// // 4. Apply Teacher-Specific Filters
// final isTeacher = filterDetails.job == "Provincial School Teacher" || 
//                   filterDetails.job == "National School Teacher";

// if (isTeacher) {
//   query = query
//       .where('scheme', isEqualTo: newUserInfo['scheme'])
//       .where('subject', isEqualTo: newUserInfo['subject']);
// }

// // 5. Apply District Choices Filter
// query = query.where('district', whereIn: newUserChoices);

// // 6. Execute single query
// final matchesQuery = await query.get();

//   final batch = db.batch();

//   for (var doc in matchesQuery.docs) {
//   Map<String, dynamic> matchedUserData = doc.data();
  
//   // 1. Identify which choice of User B (the receiver) matches User A's district
//   String matchingChoiceTitle = "New Match Found!"; // Default
//   if (matchedUserData['choice1'] == newUserInfo['district']) {
//     matchingChoiceTitle = "Match under Choice 1";
//   } else if (matchedUserData['choice2'] == newUserInfo['district']) {
//     matchingChoiceTitle = "Match under Choice 2";
//   } else if (matchedUserData['choice3'] == newUserInfo['district']) {
//     matchingChoiceTitle = "Match under Choice 3";
//   }

//   // 2. RECIPROCAL CHECK: Does User B want to come where User A is?
//   // (We already filtered by User A's choices in the query, so we just check User B's interest)
//   List<String> matchedUserChoices = [
//     matchedUserData['choice1'],
//     matchedUserData['choice2'],
//     matchedUserData['choice3'],
//   ].where((c) => c != null).cast<String>().toList();

//   if (matchedUserChoices.contains(newUserInfo['district'])) {
//     final notificationRef = db.collection('notifications').doc();
    
//     batch.set(notificationRef, {
//       'receiverId': doc.id,
//       'senderId': currentUid,
//       'title': matchingChoiceTitle,
//       'message': '${newUserInfo['name']} wants to move to ${matchedUserData['district']}.',
//       'createdAt': FieldValue.serverTimestamp(),
//       'isRead': false,
//     });
//   }
// }

//   await batch.commit();
// }

  String currentDeviceID = "";

  //  LOGIN Function
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("User signed in successfully: ${_auth.currentUser?.email}");

      await updateFcmToken();

      // for 2 devices restriction feature --
      final uid = _auth.currentUser!.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        _errorMessage = "User not found in database.";
        _isLoading = false; // Reset isLoading here
        notifyListeners();
        return false;
      }
      final String currentDevice = await getDeviceId();
      final String? savedDevice = userDoc.data()?['deviceId'];
      print("currentDevice: $currentDevice");
      print("savedDevice: $savedDevice");
      // _isLoading = false;

      if (savedDevice == null || savedDevice == '') {
        // First ever login → register device
        await _firestore.collection('users').doc(uid).update({
          'deviceId': currentDevice,
          'lastLogin': FieldValue.serverTimestamp(),
        });
        print("Device registered for user: $currentDevice");
        _errorMessage = null;
        _isLoading = false; // Reset isLoading here
        notifyListeners();
        return true;
      } else if (savedDevice != currentDevice) {
        // Block second device
        currentDeviceID = currentDevice;
        _errorMessage = "This account is already used on another device.";
        await _auth.signOut();
        _isLoading = false; // Reset isLoading here
        notifyListeners();
        return false;
      } else {
        await _firestore.collection('users').doc(uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
        _errorMessage = null;
        _isLoading = false; // Reset isLoading here
        notifyListeners();
        return true;
      }
      // _errorMessage = null;
      // for 2 devices restriction feature --
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("Error signing in: ${e.code} - ${e.message}");
      _errorMessage = e.code;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print("General error during sign-in: $e");
      _errorMessage = "An unexpected error occurred during sign-in.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateFcmToken() async {
    try {
      // Get the current user
      final user = _auth.currentUser;
      if (user == null) {
        print("No user is currently logged in. Cannot update FCM token.");
        return;
      }

      // Retrieve the FCM token
      String? token = await FirebaseService.getFcmToken();
      if (token == null) {
        print("Failed to retrieve FCM token.");
        return;
      }

      // Update the token in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });

      print("FCM token updated successfully for user: ${user.uid}");
    } catch (e) {
      print("Error updating FCM token: $e");
    }
  }

  String _getFirebaseAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'This email is already in use by another account.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. (Developer error)';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'An unknown error occurred. Please try again.';
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
      await _auth.signOut();
      _user = null;
      print("User signed out successfully.");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("Error during sign out: ${e.code} - ${e.message}");
      _errorMessage = "Failed to sign out: ${e.message}";
    } catch (e) {
      print("General error during sign out: $e");
      _errorMessage = "An unexpected error occurred during sign out.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify listeners about loading state

    try {
      firebase_auth.User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("No user is currently logged in to delete.");
      }

      final uidToDelete = currentUser.uid;

      await currentUser.delete();
      print(
        "User successfully deleted from Firebase Authentication for UID: $uidToDelete",
      );

      await _firestore.collection('users').doc(uidToDelete).delete();
      print(
        "User data successfully deleted from Firestore for UID: $uidToDelete",
      );

      _appUser = null;
      _user = null;
      _errorMessage = null;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print("Error deleting account: ${e.message}");
        final reauthenticated = await Navigator.push(
          context,
          MaterialPageRoute<bool>(
            builder: (BuildContext context) => const ReauthenticateScreen(),
          ),
        );
        if (reauthenticated == true) {
          // Retry account deletion after successful reauthentication
          await deleteAccount(context);
        }
      } else {
        _errorMessage =
            "Error deleting account: ${e.message ?? 'An unknown error occurred.'}";
        print("Error deleting account: ${_errorMessage}");
      }
    } catch (e) {
      _errorMessage = "An unexpected error occurred: ${e.toString()}";
      print("Error deleting account: ${_errorMessage}");
      signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
