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
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/providers/service_providers/onesignal_service.dart';

class AuthenticationProvider extends ChangeNotifier {
  BuildContext context = ContextHelper.navigatorKey.currentContext!;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController idCardController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController whatsappController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  bool isGoogleAuth = false;

  void clearData() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    idCardController.clear();
    contactController.clear();
    whatsappController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    noteController.clear();
    filterDetails = FilterModel();
    _errorMessage = null;
    isGoogleAuth = false;
    notifyListeners();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    idCardController.dispose();
    contactController.dispose();
    whatsappController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    noteController.dispose();
    super.dispose();
  }

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  firebase_auth.User? _user;
  firebase_auth.User? get user => _user;

  PersonDetailsModel? _appUser;
  PersonDetailsModel? get appUser => _appUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthenticationProvider() {
    _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) {
      _user = firebaseUser;
      _errorMessage = null;
      notifyListeners();
    });
  }

  Future<firebase_auth.User?> registerEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password.trim());
      firebase_auth.User user = credential.user!;
      await user.sendEmailVerification();
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reloadAndCheckVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

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
    bool isWhatsappHide = false,
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

      final existingDeviceQuery =
          await _firestore.collection('users').where('deviceId', isEqualTo: currentDevice).limit(1).get();

      if (existingDeviceQuery.docs.isNotEmpty && existingDeviceQuery.docs.first.id != newUser.uid) {
        _errorMessage = "DEVICE_ALREADY_EXISTS";
        return false;
      }

      if (newUser != null) {
        await newUser.updateProfile(
          displayName: "${firstNameController.text.trim()} ${lastNameController.text.trim()}",
        );

        String? token;

        try {
          token = await FirebaseService.getFcmToken();
          print("FCM Token: $token");
        } catch (e) {
          print("Couldn't get FCM token yet: $e");
          token = null;
        }

        Map<String, dynamic> firestoreData = {
          // 'nicNo': idCardController.text.trim(),
          'name': '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
          'email': emailController.text.trim(),
          // 'age': age,
          'phone': contactController.text.trim(),
          'whatsapp': whatsappController.text.trim(),
          'isPhoneHide': isPhoneHide,
          'isWhatsappHide': isWhatsappHide,
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
          'subjectMedium': filterDetails.subjectMedium,
          // 'grade': filterDetails.grade,
          'choice1': filterDetails.choice1,
          'choice2': filterDetails.choice2,
          'choice3': filterDetails.choice3,
          // 'note': noteController.text.trim(),
          'isEnable': isEnable,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'uid': newUser.uid,
          'fcmToken': token,
          'lastLogin': FieldValue.serverTimestamp(),
          'deviceId': currentDevice,
        };

        await _firestore.collection('users').doc(newUser.uid).set(firestoreData, SetOptions(merge: true));
        print("Additional user data saved to Firestore for UID: ${newUser.uid}");
        _errorMessage = null;

        _appUser = PersonDetailsModel.fromAuthAndFirestore(firebaseUser: newUser, firestoreData: firestoreData);
        await notifyMatches(firestoreData, newUser.uid);
        return true;
      } else {
        _errorMessage = "Account created, but failed to retrieve user data to save profile.";
        return false;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("Error creating user (Auth): ${e.code} - ${e.message}");
      _errorMessage = _getFirebaseAuthErrorMessage(e.code);
      return false;
    } on FirebaseException catch (e) {
      print("Error saving user profile to Firestore: ${e.code} - ${e.message}");
      _errorMessage = "Account created, but failed to save profile: ${e.message}";
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
    try {
      final db = FirebaseFirestore.instance;

      List<String> newUserChoices =
          [
            newUserInfo['choice1'],
            newUserInfo['choice2'],
            newUserInfo['choice3'],
          ].where((c) => c != null && c.toString().isNotEmpty).cast<String>().toList();

      if (newUserChoices.isEmpty) {
        return;
      }

      Query query = db.collection('users');
      final String userJob = newUserInfo['job'] ?? '';

      if (userJob.isNotEmpty) {
        query = query.where('job', isEqualTo: userJob);
      }

      final isTeacher = userJob == "Provincial School Teacher" || userJob == "National School Teacher";

      if (isTeacher) {
        query = query
            .where('scheme', isEqualTo: newUserInfo['scheme'])
            .where('subject', isEqualTo: newUserInfo['subject']);
      }

      query = query.where('district', whereIn: newUserChoices);

      final matchesQuery = await query.get();
      final batch = db.batch();

      for (var doc in matchesQuery.docs) {
        Map<String, dynamic> matchedUserData = doc.data() as Map<String, dynamic>;
        if (doc.id == currentUid) continue;

        String matchingChoiceTitle = "New Match Found!";
        if (matchedUserData['choice1'] == newUserInfo['district']) {
          matchingChoiceTitle = "Match under Choice 1";
        } else if (matchedUserData['choice2'] == newUserInfo['district']) {
          matchingChoiceTitle = "Match under Choice 2";
        } else if (matchedUserData['choice3'] == newUserInfo['district']) {
          matchingChoiceTitle = "Match under Choice 3";
        }

        List<String> matchedUserChoices =
            [
              matchedUserData['choice1'],
              matchedUserData['choice2'],
              matchedUserData['choice3'],
            ].where((c) => c != null).cast<String>().toList();

        if (matchedUserChoices.contains(newUserInfo['district'])) {
          final notificationMessage =
              '${newUserInfo['name'] ?? 'A user'} wants to move to ${matchedUserData['district']}.';

          await OneSignalService.sendMatchNotification(
            receiverUid: doc.id,
            title: matchingChoiceTitle,
            message: notificationMessage,
          );

          final notificationRef = db.collection('notifications').doc();
          batch.set(notificationRef, {
            'receiverId': doc.id,
            'senderId': currentUid,
            'title': matchingChoiceTitle,
            'message': notificationMessage,
            'createdAt': FieldValue.serverTimestamp(),
            'isRead': false,
          });
        }
      }

      await batch.commit();
    } catch (e) {
      print("Error in notifyMatches: $e");
    }
  }

  String currentDeviceID = "";

  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("User signed in successfully: ${_auth.currentUser?.email}");

      await updateFcmToken();

      final uid = _auth.currentUser!.uid;

      OneSignalService.loginUser(uid);

      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        _errorMessage = "User not found in database.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final String currentDevice = await getDeviceId();
      final String? savedDevice = userDoc.data()?['deviceId'];

      if (savedDevice == null || savedDevice == '') {
        await _firestore.collection('users').doc(uid).update({
          'deviceId': currentDevice,
          'lastLogin': FieldValue.serverTimestamp(),
        });
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (savedDevice != currentDevice) {
        currentDeviceID = currentDevice;
        _errorMessage = "This account is already used on another device.";
        await _auth.signOut();
        OneSignalService.logoutUser();
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        await _firestore.collection('users').doc(uid).update({'lastLogin': FieldValue.serverTimestamp()});
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = e.code;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = "An unexpected error occurred during sign-in.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    _isLoading = true;
    isGoogleAuth = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final googleSignIn = google_sign_in.GoogleSignIn.instance;
      await googleSignIn.initialize();
      google_sign_in.GoogleSignInAccount? googleUser;

      try {
        googleUser = await googleSignIn.attemptLightweightAuthentication(reportAllExceptions: false);
      } catch (e) {
        debugPrint('Lightweight Google authentication failed: $e');
        googleUser = null;
      }

      if (googleUser == null) {
        if (!googleSignIn.supportsAuthenticate()) {
          throw Exception('Google Sign-In authentication is not supported on this platform.');
        }
        googleUser = await googleSignIn.authenticate();
      }
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google authentication failed because no ID token was received.');
      }
      final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(idToken: idToken);
      final firebase_auth.UserCredential userCredential = await _auth.signInWithCredential(credential);
      final firebase_auth.User? user = userCredential.user;

      if (user == null) {
        _isLoading = false;
        isGoogleAuth = false;
        notifyListeners();
        return {'success': false, 'error': 'Failed to authenticate with Firebase.'};
      }
      debugPrint('Firebase UID: ${user.uid}');
      debugPrint('Google account: ${googleUser.email}');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      if (userDoc.exists &&
          userData != null &&
          userData.containsKey('job') &&
          userData['job'] != null &&
          userData['job'].toString().isNotEmpty) {
        isGoogleAuth = false;
        await updateFcmToken();
        OneSignalService.loginUser(user.uid);
        final String currentDevice = await getDeviceId();
        final String? savedDevice = userData['deviceId']?.toString();
        if (savedDevice == null || savedDevice.isEmpty) {
          await _firestore.collection('users').doc(user.uid).update({
            'deviceId': currentDevice,
            'lastLogin': FieldValue.serverTimestamp(),
          });
        } else if (savedDevice != currentDevice) {
          currentDeviceID = currentDevice;
          _errorMessage = 'This account is already used on another device.';
          await _auth.signOut();
          OneSignalService.logoutUser();
          _isLoading = false;
          notifyListeners();
          return {'success': false, 'error': _errorMessage};
        } else {
          await _firestore.collection('users').doc(user.uid).update({'lastLogin': FieldValue.serverTimestamp()});
        }
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'isComplete': true};
      }
      isGoogleAuth = true;
      emailController.text = user.email ?? googleUser.email;
      final String? displayName = user.displayName ?? googleUser.displayName;
      if (displayName != null && displayName.trim().isNotEmpty) {
        final parts = displayName.trim().split(RegExp(r'\s+'));
        firstNameController.text = parts.first;
        if (parts.length > 1) {
          lastNameController.text = parts.sublist(1).join(' ');
        } else {
          lastNameController.clear();
        }
      }
      _isLoading = false;
      notifyListeners();
      return {'success': true, 'isComplete': false};
    } on google_sign_in.GoogleSignInException catch (e) {
      debugPrint('GoogleSignInException: ${e.code} - ${e.description}');
      _isLoading = false;
      isGoogleAuth = false;
      _errorMessage = e.description ?? 'Google authentication failed.';
      notifyListeners();
      return {'success': false, 'error': _errorMessage};
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      _isLoading = false;
      isGoogleAuth = false;
      _errorMessage = e.message ?? 'Firebase authentication failed.';
      notifyListeners();
      return {'success': false, 'error': _errorMessage};
    } catch (e) {
      debugPrint('Google authentication error: $e');
      _isLoading = false;
      isGoogleAuth = false;
      _errorMessage = e.toString();
      notifyListeners();
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<void> updateFcmToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return;
      }
      String? token = await FirebaseService.getFcmToken();
      if (token == null) {
        return;
      }
      await _firestore.collection('users').doc(user.uid).update({'fcmToken': token});
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

      try {
        if (_firebaseAuth != _auth) {
          await _firebaseAuth.signOut();
        }
      } catch (e) {
        debugPrint('Secondary Firebase sign out error: $e');
      }

      OneSignalService.logoutUser();
      _user = null;
      clearData();
      debugPrint('User signed out successfully.');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(builder: (BuildContext context) => const LoginScreen()),
        (route) => false,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      _errorMessage = 'Failed to sign out: ${e.message}';
      debugPrint('Firebase sign out error: ${e.code} - ${e.message}');
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during sign out.';
      debugPrint('Unexpected sign out error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final firebase_auth.User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _errorMessage = "No user is currently logged in to delete.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    final String uidToDelete = currentUser.uid;

    try {
      await currentUser.delete();
      await _firestore.collection('users').doc(uidToDelete).delete();
      _completeDeletion(context);
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during delete: ${e.code} - ${e.message}');

      if (e.code == 'requires-recent-login') {
        debugPrint('Token expired. Attempting automatic Google re-authentication...');

        try {
          final googleSignIn = google_sign_in.GoogleSignIn.instance;
          await googleSignIn.initialize();

          google_sign_in.GoogleSignInAccount? googleUser;
          try {
            googleUser = await googleSignIn.attemptLightweightAuthentication(reportAllExceptions: false);
          } catch (authErr) {
            debugPrint('Lightweight auth failed: $authErr');
          }

          if (googleUser == null) {
            if (!googleSignIn.supportsAuthenticate()) {
              throw Exception('Google Sign-In is not supported on this device.');
            }
            googleUser = await googleSignIn.authenticate();
          }

          if (googleUser == null) {
            _errorMessage = 'Re-authentication was canceled.';
            _isLoading = false;
            notifyListeners();
            return;
          }

          final googleAuth = googleUser.authentication;
          final String? idToken = googleAuth.idToken;

          if (idToken == null || idToken.isEmpty) {
            throw Exception('No Google ID token received during re-authentication.');
          }

          final firebase_auth.AuthCredential credential = firebase_auth.GoogleAuthProvider.credential(idToken: idToken);

          await currentUser.reauthenticateWithCredential(credential);
          debugPrint('Re-authentication successful. Retrying account deletion...');

          await currentUser.delete();
          await _firestore.collection('users').doc(uidToDelete).delete();

          _completeDeletion(context);
        } on firebase_auth.FirebaseAuthException catch (reAuthError) {
          debugPrint('Re-authentication FirebaseAuthException: ${reAuthError.code} - ${reAuthError.message}');
          _errorMessage = reAuthError.message ?? 'Re-authentication failed.';
        } catch (innerError) {
          debugPrint('Error during Google re-authentication process: $innerError');
          _errorMessage = innerError.toString();
        }
      } else {
        _errorMessage = e.message ?? 'Failed to delete account.';
      }
    } catch (e) {
      debugPrint('Unexpected error in deleteAccount: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _completeDeletion(BuildContext context) {
    _appUser = null;
    _user = null;
    _errorMessage = null;
    clearData();

    debugPrint('User account and Firestore data deleted successfully.');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (BuildContext context) => const LoginScreen()),
      (route) => false,
    );
  }
}
