import 'dart:developer';

import 'package:app/app/models/filter_model.dart';
import 'package:app/app/models/person_details_model.dart';
import 'package:app/app/utils/context_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FiltterProvider extends ChangeNotifier {
  BuildContext context = ContextHelper.navigatorKey.currentContext!;

  // late FilterModel filterDetails;
  FilterModel filterDetails = FilterModel();

  firebase_auth.User? _firebaseUser;
  firebase_auth.User? get firebaseUser => _firebaseUser;

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  PersonDetailsModel? _appUser;
  PersonDetailsModel? get appUser => _appUser;

  List<PersonDetailsModel> _allUsersData = []; // Change type
  List<PersonDetailsModel> get allUsersData => _allUsersData;
  List<PersonDetailsModel> _filteredUsersData = []; // Change type
  List<PersonDetailsModel> get filteredUsersData => _filteredUsersData;

  // Store all user data
  // List<Map<String, dynamic>> _allUsersData = [];
  // List<Map<String, dynamic>> get allUsersData => _allUsersData;

  // Store filtered user data for display
  // List<Map<String, dynamic>> _filteredUsersData = [];
  // List<Map<String, dynamic>> get filteredUsersData => _filteredUsersData;

  // getAllUserDetails now populates the internal list

  FiltterProvider() {
    _auth.authStateChanges().listen((firebase_auth.User? user) async {
      _firebaseUser = user;
      _errorMessage = null;

      if (_firebaseUser != null) {
        //  Fetch and set the PersonDetailsModel when auth state changes
        await _fetchAndSetPersonDetailsModel(_firebaseUser!.uid);
      } else {
        _appUser = null; // Clear combined profile on logout
        _allUsersData = []; // Clear all user data on logout
        _filteredUsersData = []; // Clear filtered data on logout
      }
      notifyListeners();
    });
  }

  Future<void> _fetchAndSetPersonDetailsModel(String uid) async {
    // We need _firebaseUser to be non-null here to construct PersonDetailsModel
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
        print("Firestore profile not found for UID: $uid. Using only Auth data.");
      }
    } on FirebaseException catch (e) {
      print("Error fetching Firestore profile for UID $uid: ${e.message}");
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
    }
  }

  Future<void> getAllUserDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _allUsersData = []; // Clear previous data
    _filteredUsersData = []; // Clear previous filtered data

    try {
      if (_auth.currentUser == null) {
        _errorMessage = "You must be logged in to view all user details.";
        _isLoading = false;
        notifyListeners();
        return;
      } else {
        // print("Current user ID: ${_auth.currentUser!.uid}");
        // print("_auth.currentUser details: ${_auth.currentUser}");
      }

      QuerySnapshot querySnapshot = await _firestore.collection('users').get();

      for (var doc in querySnapshot.docs) {
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Check if the user is active (default to true for backward compatibility)
          bool isActive = data['isActive'] ?? true;

          // If the user is INACTIVE and is NOT the current logged-in user, skip them
          if (!isActive && doc.id != _auth.currentUser?.uid) {
            continue;
          }

          _allUsersData.add(PersonDetailsModel.fromJson(data));
        }
      }
      _filteredUsersData = List.from(_allUsersData);
      _errorMessage = null;
    } on FirebaseException catch (e) {
      print("Error fetching all user details from Firestore: ${e.code} - ${e.message}");
      _errorMessage = "Failed to load user list: ${e.message}";
    } catch (e) {
      print("General error fetching all user details: $e");
      _errorMessage = "An unexpected error occurred while fetching user list.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //  New: Filtering method
  void filterUsers(String query) {
    if (query.isEmpty) {
      _filteredUsersData = List.from(_allUsersData);
    } else {
      _filteredUsersData =
          _allUsersData.where((user) {
            final name = user.firstName?.toLowerCase() ?? ''; // Access via model properties
            final firestoreEmail = user.firestoreEmail?.toLowerCase() ?? '';
            final province = user.province?.toLowerCase() ?? '';
            final searchLower = query.toLowerCase();

            return name.contains(searchLower) || firestoreEmail.contains(searchLower) || province.contains(searchLower);
          }).toList();
    }
    notifyListeners();
  }

  void applyFilters({String? district, String? school, String? scheme, String? subject, String? grade, String? job}) {
    print(grade);
    List<PersonDetailsModel> filtered = List.from(_allUsersData);

    if (district != null && district.isNotEmpty) {
      filtered =
          filtered.where((u) {
            final d = district.toLowerCase();
            return (u.choice1 ?? '').toLowerCase() == d ||
                (u.choice2 ?? '').toLowerCase() == d ||
                (u.choice3 ?? '').toLowerCase() == d;
          }).toList();
    }

    if (school != null && school.isNotEmpty) {
      job == "Provincial School Teacher"
          ? filtered = filtered.where((u) => (u.school ?? '').toLowerCase() == school.toLowerCase()).toList()
          : job == "National School Teacher"
          ? filtered = filtered.where((u) => (u.nationalSchool ?? '').toLowerCase() == school.toLowerCase()).toList()
          : job == "Nurse"
          ? filtered = filtered.where((u) => (u.officeForNurse ?? '').toLowerCase() == school.toLowerCase()).toList()
          : job == "Management Assistant"
          ? filtered = filtered.where((u) => (u.officeForMA ?? '').toLowerCase() == school.toLowerCase()).toList()
          : job == "Police Officer"
          ? filtered = filtered.where((u) => (u.policeStations ?? '').toLowerCase() == school.toLowerCase()).toList()
          : filtered =
              filtered.where((u) => (u.gramaNiladhariDivision ?? '').toLowerCase() == school.toLowerCase()).toList();
    }

    // ✅ 2. Apply secondary filters (scheme / subject)
    if (scheme != null && scheme.isNotEmpty) {
      filtered = filtered.where((u) => (u.scheme ?? '').toLowerCase() == scheme.toLowerCase()).toList();
    }

    if (subject != null && subject.isNotEmpty) {
      filtered = filtered.where((u) => (u.subject ?? '').toLowerCase() == subject.toLowerCase()).toList();
    }

    if (grade != null && grade.isNotEmpty) {
      filtered = filtered.where((u) => (u.grade ?? '').toLowerCase() == grade.toLowerCase()).toList();
    }

    // ✅ Update provider list
    _filteredUsersData = filtered;
    notifyListeners();
  }

  Future<void> reapplySavedFilters() async {
    final prefs = await SharedPreferences.getInstance();

    final savedDistrict = prefs.getString('district') ?? '';
    final savedSchool = prefs.getString('school') ?? '';
    final savedScheme = prefs.getString('scheme') ?? '';
    final savedSubject = prefs.getString('subject') ?? '';
    final savedGrade = prefs.getString('grade') ?? '';
    final savedSelectedName = prefs.getString('selectedName') ?? '';

    final locationFilter = prefs.getString('locationViaFilter') == 'true';

    final schoolFilter = prefs.getString('schoolViaFilter') == 'true';

    final subjectFilter = prefs.getString('subjectViaFilter') == 'true';
    final gradeFilter = prefs.getString('gradeViaFilter') == 'true';

    applyFilters(
      // Location filter
      district: locationFilter && savedDistrict.isNotEmpty ? savedDistrict : null,

      // School filter
      school:
          schoolFilter && savedSchool.isNotEmpty
              ? savedSchool
              : schoolFilter && savedSelectedName.isNotEmpty
              ? savedSelectedName
              : null,

      // Subject filter
      scheme: subjectFilter && savedScheme.isNotEmpty ? savedScheme : null,

      subject: subjectFilter && savedSubject.isNotEmpty ? savedSubject : null,

      grade: gradeFilter && savedGrade.isNotEmpty ? savedGrade : null,
    );

    // Apply filters only if at least one value is saved
    // if (savedDistrict.isNotEmpty ||
    //     savedSchool.isNotEmpty ||
    //     savedScheme.isNotEmpty ||
    //     savedSubject.isNotEmpty) {
    //   applyFilters(
    //     district: savedDistrict.isNotEmpty ? savedDistrict : null,
    //     school: savedSchool.isNotEmpty ? savedSchool : null,
    //     scheme: savedScheme.isNotEmpty ? savedScheme : null,
    //     subject: savedSubject.isNotEmpty ? savedSubject : null,
    //   );
    // } else {
    //   clearFilters();
    // }
  }

  void clearFilters() {
    _filteredUsersData = List.from(_allUsersData);
    notifyListeners();
  }
}
