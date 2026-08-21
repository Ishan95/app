import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class PersonDetailsModel {
  // Firebase Auth specific fields (native to firebase_auth.User)
  final String uid; // This must be non-null and comes from Firebase Auth
  final String
  authEmail; // Renamed from 'email' to avoid collision with Firestore email
  final bool isEmailVerified;
  final String? displayName; // From Firebase Auth
  final String? photoURL; // From Firebase Auth
  final String?
  authPhoneNumber; // Renamed to avoid collision with Firestore 'phone'
  final DateTime? createdAtAuth; // From Auth metadata
  final DateTime? lastSignInTimeAuth; // From Auth metadata

  // Your existing custom Firestore fields
  // String? id;
  String? nicNo;
  String? firstName;
  String? lastName;
  String? firestoreEmail; // Renamed for clarity, often same as authEmail
  // String? email;
  int? age;
  String? phone;
  bool isPhoneHide;
  bool isSchoolHide;
  String? job;
  String? province;
  String? district;
  String? kalapa;
  String? kottasa;
  String? school;
  String? kottasaForNationalScl;
  String? nationalSchool;
  String? institutionTypeForNurse;
  String? officeForNurse;
  String? institutionTypeForMA;
  String? officeForMA;
  String? policeDivisions;
  String? policeStations;
  String? divisionalSecretariat;
  String? gramaNiladhariDivision;
  String? scheme;
  String? subject;
  String? grade;
  String? choice1;
  String? choice2;
  String? choice3;
  String? note;
  bool isEnable;
  DateTime? firestoreCreatedAt; // From Firestore Timestamp

  DateTime? transferDate;
  String? refNo;
  String? accountNo;
  String? clientName;
  String? amount;
  String? serviceProvider;

  PersonDetailsModel({
    // Firebase Auth fields
    required this.uid,
    required this.authEmail,
    this.isEmailVerified = false,
    this.displayName,
    this.photoURL,
    this.authPhoneNumber,
    this.createdAtAuth,
    this.lastSignInTimeAuth,
    // this.id,
    this.nicNo,
    this.firstName,
    this.lastName,
    this.firestoreEmail,
    // this.email,
    this.age,
    this.phone,
    this.isPhoneHide = false,
    this.isSchoolHide = false,
    this.job,
    this.province,
    this.district,
    this.kalapa,
    this.kottasa,
    this.school,
    this.kottasaForNationalScl,
    this.nationalSchool,
    this.institutionTypeForNurse,
    this.officeForNurse,
    this.institutionTypeForMA,
    this.officeForMA,
    this.policeDivisions,
    this.policeStations,
    this.divisionalSecretariat,
    this.gramaNiladhariDivision,
    this.scheme,
    this.subject,
    this.grade,
    this.choice1,
    this.choice2,
    this.choice3,
    this.note,
    this.isEnable = false,
    this.firestoreCreatedAt,

    this.transferDate,
    this.refNo,
    this.accountNo,
    this.clientName,
    this.amount,
    this.serviceProvider,
  });

  // Factory to create from Firebase Auth User object and Firestore document data
  factory PersonDetailsModel.fromAuthAndFirestore({
    required firebase_auth.User firebaseUser,
    required Map<String, dynamic> firestoreData,
  }) {
    return PersonDetailsModel(
      // Firebase Auth fields
      uid: firebaseUser.uid,
      authEmail: firebaseUser.email ?? '', // Fallback for email if null
      isEmailVerified: firebaseUser.emailVerified,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      authPhoneNumber: firebaseUser.phoneNumber,
      createdAtAuth: firebaseUser.metadata.creationTime,
      lastSignInTimeAuth: firebaseUser.metadata.lastSignInTime,

      // Custom Firestore fields
      // id: firestoreData['uid'] as String?, // Casting for safety
      nicNo: firestoreData['nicNo'] as String?,
      firstName: firestoreData['name'] as String?,
      lastName: firestoreData['lastName'] as String?,
      firestoreEmail:
          firestoreData['email']
              as String?, // Assuming you store email in Firestore too
      age: firestoreData['age'] as int?,
      phone: firestoreData['phone'] as String?,
      isPhoneHide:
          (firestoreData['isPhoneHide'] as bool?) ??
          false, // Default to false if not present
      isSchoolHide:
          (firestoreData['isSchoolHide'] as bool?) ??
          false, 
      job: firestoreData['job'] as String?,
      province: firestoreData['province'] as String?,
      district: firestoreData['district'] as String?,
      kalapa: firestoreData['kalapa'] as String?,
      kottasa: firestoreData['kottasa'] as String?,
      school: firestoreData['school'] as String?,
      kottasaForNationalScl: firestoreData['kottasaForNationalScl'] as String?,
      nationalSchool: firestoreData['nationalSchool'] as String?,
      institutionTypeForNurse: firestoreData['institutionTypeForNurse'] as String?,
      officeForNurse: firestoreData['officeForNurse'] as String?,
      institutionTypeForMA: firestoreData['institutionTypeForMA'] as String?,
      officeForMA: firestoreData['officeForMA'] as String?,
      policeDivisions: firestoreData['policeDivisions'] as String?,
      policeStations: firestoreData['policeStations'] as String?,
      divisionalSecretariat: firestoreData['divisionalSecretariat'] as String?,
      gramaNiladhariDivision: firestoreData['gramaNiladhariDivision'] as String?,
      scheme: firestoreData['scheme'] as String?,
      subject: firestoreData['subject'] as String?,
      grade: firestoreData['grade'] as String?,
      choice1: firestoreData['choice1'] as String?,
      choice2: firestoreData['choice2'] as String?,
      choice3: firestoreData['choice3'] as String?,
      note: firestoreData['note'] as String?,
      isEnable: (firestoreData['isEnable'] as bool?) ?? false,
      firestoreCreatedAt:
          firestoreData['createdAt'] is Timestamp
              ? (firestoreData['createdAt'] as Timestamp).toDate()
              : null,
      

      transferDate:
          firestoreData['transferDate'] is Timestamp
              ? (firestoreData['transferDate'] as Timestamp).toDate()
              : null,
      refNo: firestoreData['refNo'] as String?,
      accountNo: firestoreData['accountNo'] as String?,
      clientName: firestoreData['clientName'] as String?,
      amount: firestoreData['amount'] as String?,
      serviceProvider: firestoreData['serviceProvider'] as String?,
      // firestoreCreatedAt: (firestoreData['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Your existing fromJson factory, potentially for when you only have Firestore data
  // You might not need this if you always combine with Auth data.
  // Or, you can rename this to fromFirestoreJson if it's strictly for Firestore data.
  factory PersonDetailsModel.fromJson(Map<String, dynamic> json) {
    return PersonDetailsModel(
      uid:
          json['uid'] as String? ??
          'UNKNOWN', // You need UID if using this to reference Auth data
      authEmail:
          json['authEmail'] as String? ?? '', // Needs to be explicitly added
      isEmailVerified:
          (json['isEmailVerified'] as bool?) ??
          false, // Needs to be explicitly added
      displayName:
          json['displayName'] as String?, // Needs to be explicitly added
      photoURL: json['photoURL'] as String?, // Needs to be explicitly added
      authPhoneNumber:
          json['authPhoneNumber'] as String?, // Needs to be explicitly added
      createdAtAuth:
          (json['createdAtAuth'] as Timestamp?)
              ?.toDate(), // Needs to be explicitly added
      lastSignInTimeAuth:
          (json['lastSignInTimeAuth'] as Timestamp?)
              ?.toDate(), // Needs to be explicitly added
      // id: json['uid'] as String?,
      nicNo: json['nicNo'] as String?,
      firstName: json['name'] as String?,
      lastName: json['lastName'] as String?,
      firestoreEmail: json['email'] as String?,
      age: json['age'] as int?,
      phone: json['phone'] as String?,
      isPhoneHide: (json['isPhoneHide'] as bool?) ?? false,
      isSchoolHide: (json['isSchoolHide'] as bool?) ?? false,
      job: json['job'] as String?,
      province: json['province'] as String?,
      district: json['district'] as String?,
      kalapa: json['kalapa'] as String?,
      kottasa: json['kottasa'] as String?,
      school: json['school'] as String?,
      kottasaForNationalScl: json['kottasaForNationalScl'] as String?,
      nationalSchool: json['nationalSchool'] as String?,
      institutionTypeForNurse: json['institutionTypeForNurse'] as String?,
      officeForNurse: json['officeForNurse'] as String?,
      institutionTypeForMA: json['institutionTypeForMA'] as String?,
      officeForMA: json['officeForMA'] as String?,
      policeDivisions: json['policeDivisions'] as String?,
      policeStations: json['policeStations'] as String?,
      divisionalSecretariat: json['divisionalSecretariat'] as String?,
      gramaNiladhariDivision: json['gramaNiladhariDivision'] as String?,
      scheme: json['scheme'] as String?,
      subject: json['subject'] as String?,
      grade: json['grade'] as String?,
      choice1: json['choice1'] as String?,
      choice2: json['choice2'] as String?,
      choice3: json['choice3'] as String?,
      note: json['note'] as String?,
      isEnable: (json['isEnable'] as bool?) ?? false,
      firestoreCreatedAt: (json['createdAt'] as Timestamp?)?.toDate(),

      transferDate: (json['transferDate'] as Timestamp?)?.toDate(),
      refNo: json['refNo'] as String?,
      accountNo: json['accountNo'] as String?,
      clientName: json['clientName'] as String?,
      amount: json['amount'] as String?,
      serviceProvider: json['serviceProvider'] as String?,
    );
  }

  // Method to convert the model back to a Firestore-compatible map (for updating)
  Map<String, dynamic> toFirestore() {
    return {
      'nicNo': nicNo,
      'name': firstName,
      'lastName': lastName,
      'email': firestoreEmail, // Use firestoreEmail here
      'age': age,
      'phone': phone,
      'isPhoneHide': isPhoneHide,
      'isSchoolHide': isSchoolHide,
      'job': job,
      'province': province,
      'district': district,
      'kalapa': kalapa,
      'kottasa': kottasa,
      'school': school,
      'kottasaForNationalScl': kottasaForNationalScl,
      'nationalSchool': nationalSchool,
      'institutionTypeForNurse': institutionTypeForNurse,
      'officeForNurse': officeForNurse,
      'institutionTypeForMA': institutionTypeForMA,
      'officeForMA': officeForMA,
      'policeDivisions': policeDivisions,
      'policeStations': policeStations,
      'divisionalSecretariat': divisionalSecretariat,
      'gramaNiladhariDivision': gramaNiladhariDivision,
      'scheme': scheme,
      'subject': subject,
      'grade': grade,
      'choice1': choice1,
      'choice2': choice2,
      'choice3': choice3,
      'note': note,
      'isEnable': isEnable,

      'refNo': refNo,
      'accountNo': accountNo,
      'clientName': clientName,
      'amount': amount,
      'serviceProvider': serviceProvider,
    };
  }
}