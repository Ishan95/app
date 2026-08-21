// class UserDetailsModel {
//   bool? status;
//   SingleUserDetailsModel? returnObj;
//   String? bearerToken;

//   UserDetailsModel({this.status, this.returnObj});

//   UserDetailsModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     returnObj = json['data'] != null
//         ? SingleUserDetailsModel.fromJson(json['data'])
//         : null;
//     bearerToken = json['token'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['status'] = status;
//     if (returnObj != null) {
//       data['data'] = returnObj!.toJson();
//     }
//     data['token'] = bearerToken;
//     return data;
//   }
// }

// class SingleUserDetailsModel {
//   int? id;
//   String? firstName;
//   String? lastName;
//   String? userEmail;
//   String? userPhone;
//   String? userCreation;
//   String? userLastActive;
//   String? userLastVersion;
//   String? userMobileToken;
//   String? userPerspective;
//   bool? userCompliance;
//   String? userQrCode;
//   bool? userActive;
//   int? userId;
//   String? token;
//   bool? hasSubscription;
//   bool? hasPayment;


//   SingleUserDetailsModel(
//       {this.id,
//       this.firstName,
//       this.lastName,
//       this.userEmail,
//       this.userPhone,
//       this.userCreation,
//       this.userLastActive,
//       this.userLastVersion,
//       this.userMobileToken,
//       this.userPerspective,
//       this.userCompliance,
//       this.userQrCode,
//       this.userActive,
//       this.userId,
//       this.token,
//       this.hasSubscription,
//       this.hasPayment});

//   SingleUserDetailsModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     firstName = json['first_name'];
//     lastName = json['last_name'];
//     userEmail = json['user_email'];
//     userPhone = json['user_phone'];
//     userCreation = json['user_creation'];
//     userLastActive = json['user_last_active'];
//     userLastVersion = json['user_last_version'];
//     userMobileToken = json['user_mobile_token'];
//     userPerspective = json['user_perspective'];
//     userCompliance = json['user_compliance'];
//     userQrCode = json['user_qr_code'];
//     userActive = json['user_active'];
//     userId = json['user_id'];
//     token = json['token'];
//     hasSubscription= json['has_subscription'];
//     hasPayment= json['has_payment'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['first_name'] = firstName;
//     data['last_name'] = lastName;
//     data['user_email'] = userEmail;
//     data['user_phone'] = userPhone;
//     data['user_creation'] = userCreation;
//     data['user_last_active'] = userLastActive;
//     data['user_last_version'] = userLastVersion;
//     data['user_mobile_token'] = userMobileToken;
//     data['user_perspective'] = userPerspective;
//     data['user_compliance'] = userCompliance;
//     data['user_qr_code'] = userQrCode;
//     data['user_active'] = userActive;
//     data['user_id'] = userId;
//     data['token'] = token;
//     data['has_subscription'] = hasSubscription;
//     data['has_payment'] = hasPayment;
//     return data;
//   }
// }
