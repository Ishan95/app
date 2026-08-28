import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/app/utils/context_helper.dart';
import 'package:app/screens/home/home.dart';

class OneSignalService {
  static String get appId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';
  static String get restApiKey => dotenv.env['ONESIGNAL_REST_API_KEY'] ?? '';

  static void initialize() {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(appId);
    OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      event.preventDefault();
    });

    OneSignal.Notifications.addClickListener((event) {
      if (FirebaseAuth.instance.currentUser != null) {
        int homeIndex = 1;

        final additionalData = event.notification.additionalData;
        if (additionalData != null && additionalData.containsKey('type')) {
          final type = additionalData['type'];
          if (type == 'CHAT_MESSAGE' || type == 'GROUP_CHAT_MESSAGE') {
            homeIndex = 2;
          } else if (type == 'MATCH_NOTIFICATION') {
            homeIndex = 1;
          }
        }

        ContextHelper.navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => Home(index: homeIndex)),
              (route) => false,
        );
      }
    });
  }

  static void loginUser(String uid) {
    OneSignal.login(uid);
  }

  static void logoutUser() {
    OneSignal.logout();
  }

  /// Sends a push notification to a specific user matching via OneSignal REST API
  static Future<void> sendMatchNotification({
    required String receiverUid,
    required String title,
    required String message,
  }) async {
    final url = Uri.parse('https://api.onesignal.com/notifications');

    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Basic $restApiKey'
    };

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

  /// Sends 1-on-1 Chat Push Notification
  static Future<void> sendChatMessageNotification({
    required String receiverUid,
    required String senderName,
    required String message,
  }) async {
    final url = Uri.parse('https://api.onesignal.com/notifications');

    final headers = {'Content-Type': 'application/json; charset=utf-8', 'Authorization': 'Basic ${restApiKey.trim()}'};

    final body = jsonEncode({
      "app_id": appId,
      "include_aliases": {
        "external_id": [receiverUid],
      },
      "target_channel": "push",
      "headings": {"en": senderName},
      "contents": {"en": message},
      "data": {"type": "CHAT_MESSAGE"},
      "priority": 10,
    });

    try {
      await http.post(url, headers: headers, body: body);
    } catch (e) {
      print("Error sending OneSignal 1-on-1 chat notification: $e");
    }
  }

  /// Sends Group Chat Push Notification to Multiple Users
  static Future<void> sendGroupChatMessageNotification({
    required List<String> receiverUids,
    required String groupName,
    required String senderName,
    required String message,
  }) async {
    if (receiverUids.isEmpty) {
      return;
    }

    final url = Uri.parse('https://api.onesignal.com/notifications');

    final headers = {'Content-Type': 'application/json; charset=utf-8', 'Authorization': 'Basic ${restApiKey.trim()}'};

    final body = jsonEncode({
      "app_id": appId,
      "include_aliases": {"external_id": receiverUids},
      "target_channel": "push",
      "headings": {"en": groupName},
      "contents": {"en": "$senderName:$message"},
      "data": {"type": "GROUP_CHAT_MESSAGE"},
      "priority": 10,
    });

    try {
      await http.post(url, headers: headers, body: body);
    } catch (e) {
      print("Error sending OneSignal group chat notification: $e");
    }
  }
}
