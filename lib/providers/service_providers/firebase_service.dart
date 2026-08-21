// import 'dart:convert';
// import 'dart:io';

// import 'package:app/screens/reservation_action_page.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import '../../app/utils/context_helper.dart';
// import '../../main.dart';
// import 'notification_handler.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// class FirebaseService{
//   static final _firebaseMessaging = FirebaseMessaging.instance;

//   final _androidChannel = const AndroidNotificationChannel(
//       'reservation_update_channel',
//       'Reservation Update Notifications',
//       description: 'This channel is used for reservation update notification',
//       importance: Importance.defaultImportance
//   );

//   final _localNotifications = FlutterLocalNotificationsPlugin();

//   static handleMessage(RemoteMessage? remoteMessage) async {
//     NotificationHandler.notificationEvent(jsonDecode(remoteMessage?.data["body"])["reservation"].toString());
//   }

//   handleForegroundMessage(NotificationResponse notification) {
//     Map<String, dynamic> payload = jsonDecode(notification.payload ?? '');
//     Navigator.of(ContextHelper.navigatorKey.currentContext!).push(MaterialPageRoute(
//       builder: (context) => ReservationActionPage(reservationId: jsonDecode(payload["data"]["body"])["reservation"].toString()),
//     ));
//   }

//   Future initPushNotifications() async {
//     await _firebaseMessaging.setForegroundNotificationPresentationOptions(
//         alert: true,
//         badge: true,
//         sound: true
//     );

//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//     FirebaseMessaging.onMessage.listen((message) async {

//       if(Platform.isIOS) {
//         return;
//       }
//       final notification = message.notification;

//       if(notification == null) return;
//       String type = (jsonDecode(message.data["body"]))["type"];
//       if(type ==  "Booking Confirmation") {
//         _localNotifications.show(
//             notification.hashCode,
//             notification.title,
//             notification.body,
//             NotificationDetails(
//                 android: AndroidNotificationDetails(
//                   _androidChannel.id,
//                   _androidChannel.name,
//                   channelDescription: _androidChannel.description,
//                   icon: '@drawable/ic_launcher',
//                 )
//             ),
//             payload: jsonEncode(message.toMap())
//         );
//       }
//     });
//   }

//   Future initLocalNotifications() async {
//     const ios = DarwinInitializationSettings();
//     const android = AndroidInitializationSettings('@drawable/ic_launcher');
//     const settings = InitializationSettings(android: android, iOS: ios);

//     await _localNotifications.initialize(
//         settings,
//         onDidReceiveNotificationResponse: (notification){
//           handleForegroundMessage(notification);
//         }
//     );
//     final platform = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
//     await platform?.createNotificationChannel(_androidChannel);
//   }

//   Future<void> initNotifications() async {
//     await _firebaseMessaging.requestPermission();
//     initPushNotifications();
//     initLocalNotifications();
//   }

//   static Future<String?> getFcmToken() async {
//     String? fcmToken;
//     FirebaseMessaging instance = FirebaseMessaging.instance;
//     if(Platform.isIOS){
//       String? apnsToken = await instance.getAPNSToken();
//       if(apnsToken != null){
//         fcmToken = await instance.getToken();
//       }
//     } else {
//       fcmToken = await instance.getToken();
//     }
//     return fcmToken;
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'package:app/app/utils/context_helper.dart';
import 'package:app/main.dart';
import 'package:app/screens/edit_details/edit_details_screen.dart';
import 'package:app/screens/home/home.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _androidChannel = const AndroidNotificationChannel(
    'transer_notifications',
    'Transer Notifications',
    description: 'This channel is used for all notifications',
    importance: Importance.high,
  );

  /// Background message
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print("Background message received: ${message.data}");
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    /// Initialize local notifications
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        ContextHelper.navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const Home(index: 1),
          ),
          (route) => false,
        );
      },
    );

    if (Platform.isAndroid) {
      final platform = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await platform?.createNotificationChannel(_androidChannel);
    }

    // Show notifications in foreground (iOS)
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: false,
  badge: false,
  sound: false,
    );

    // Foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title ?? "Notification",
        notification.body ?? "",
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    });

    // Background / tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      ContextHelper.navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const Home(index: 1),
        ),
        (route) => false,
      );
    });

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  static Future<String?> getFcmToken() async {
    try {
      if (Platform.isIOS) {
        // Wait for the APNS token to be available before requesting the FCM token
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        int retries = 0;

        // Retry fetching the APNS token up to 5 times (5 seconds total)
        while (apnsToken == null && retries < 5) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await _firebaseMessaging.getAPNSToken();
          retries++;
        }

        if (apnsToken == null) {
          debugPrint('APNS token is still null after waiting. Check your Xcode configuration.');
          return null; // Don't proceed to getToken() if APNS is missing
        }
      }

      // Once APNS is confirmed (or if on Android), get the FCM token
      return await _firebaseMessaging.getToken();

    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }
}