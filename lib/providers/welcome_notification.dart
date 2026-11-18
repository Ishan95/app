import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

const welcomeNotificationTitle =
    'රාජ්‍ය සේවයේ සුහදමාරු යෙදුම වෙත සාදරයෙන් පිලිගනිමු.';

const welcomeNotificationMessage =
    '''ඔබේ තොරතුරු දැනටමත් පද්ධතියට සුරක්ෂිතව ඇතුලත් කොට ඇත. යෙදුම සමග අඛණ්ඩව රැදී සිටින්න.
ඔබට ගැලපෙන සුහදමාරුවක්, යාවත්කාලීන වූ විගසම ඒ බව දැනුම් දෙන්නෙමු.

යෙදුම සමග සම්බන්ධ වීමේදී, ඔබට තාක්ශණික දෝශ ඇත්නම් mutualtransfer.gov.lk@gmail.com වෙත දැනුම් දෙන්න.

Please stay connected with the App. We will notify you as soon as a suitable mutual transfer opportunity matching your preferences becomes available.

If you experience any technical issues while using the application, please notify us via email at mutualtransfer.gov.lk@gmail.com''';

const welcomePushMessage =
    '''ඔබේ තොරතුරු දැනටමත් පද්ධතියට සුරක්ෂිතව ඇතුලත් කොට ඇත.යෙදුම සමග අඛණ්ඩව රැදී සිටින්න.
ඔබට ගැලපෙන සුහදමාරුවක්, යාවත්කාලීන වූ විගසම ඒ බව දැනුම් දෙන්නෙමු.

යෙදුම සමග සම්බන්ධ වීමේදී ,ඔබට තාක්ශණික දෝශ ඇත්නම්  mutualtransfer.gov.lk@gmail.com වෙත දැනුම් දෙන්න''';

Future<bool> createWelcomeNotification(
  FirebaseFirestore firestore,
  String uid,
) async {
  try {
    // A fixed ID prevents a retry from creating a second welcome notification.
    await firestore.collection('notifications').doc('welcome_$uid').set({
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'message': welcomeNotificationMessage,
      'receiverId': uid,
      'senderId': '23',
      'title': welcomeNotificationTitle,
      'type': 'welcome',
    });
    return true;
  } on FirebaseException catch (error) {
    // A failed notification must not leave a completed account in onboarding.
    debugPrint('Welcome notification could not be created: ${error.code}');
    return false;
  }
}
