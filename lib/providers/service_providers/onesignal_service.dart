import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  static const String appId = "4d85a755-9a30-4b60-a359-5b2f728000bb";
  static const String restApiKey =
      "os_v2_app_jwc2ovm2gbfwbi2zlmxxfaaaxoupi35ikuhunp4h5qt22pydfj5n7xstr2iynepymle77s64765fe76hbmkmfv45qbs7t2ecdtcjkli";

  static void initialize() {
    // Initialize OneSignal
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(appId);

    // Request permission from the user to send notifications
    OneSignal.Notifications.requestPermission(true);
  }

  /// Links the device to a specific user ID (so we can send notifications to them specifically)
  static void loginUser(String uid) {
    OneSignal.login(uid);
  }

  /// Unlinks the device when the user logs out
  static void logoutUser() {
    OneSignal.logout();
  }

  /// Sends a push notification to a specific user via OneSignal REST API
  static Future<void> sendMatchNotification({
    required String receiverUid,
    required String title,
    required String message,
  }) async {
    final url = Uri.parse('https://api.onesignal.com/notifications');

    final headers = {'Content-Type': 'application/json; charset=utf-8', 'Authorization': 'Basic $restApiKey'};

    final body = jsonEncode({
      "app_id": appId,
      "include_aliases": {
        "external_id": [receiverUid],
      },
      "target_channel": "push",
      "headings": {"en": title},
      "contents": {"en": message},
      "data": {"type": "MATCH_NOTIFICATION"},
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print("OneSignal notification sent successfully to $receiverUid");
      } else {
        print("Failed to send OneSignal notification: ${response.body}");
      }
    } catch (e) {
      print("Error sending OneSignal notification: $e");
    }
  }
}
