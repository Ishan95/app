import 'dart:io';
import 'package:app/app/utils/color_manager.dart';
import 'package:app/app/utils/context_helper.dart';
import 'package:app/app/utils/scroll_behavior.dart';
import 'package:app/firebase_options.dart';
import 'package:app/providers/account_provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/chat_provider.dart';
import 'package:app/providers/filtter_provider.dart';
import 'package:app/providers/service_providers/firebase_service.dart';
import 'package:app/screens/home/home.dart';
import 'package:app/screens/onboarding/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

RemoteMessage? _initialMessage;

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage remoteMessage) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  final firebaseService = FirebaseService();
  await firebaseService.initNotifications();
  _initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  FirebaseService.getFcmToken();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  HttpOverrides.global = MyHttpOverrides();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: ColorManager.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
          ChangeNotifierProvider(create: (_) => AccountProvider()),
          ChangeNotifierProvider(create: (_) => FiltterProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Handle app opened from terminated notification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_initialMessage != null) {
        ContextHelper.navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Home(index: 1)),
          (route) => false,
        );
        _initialMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MaterialApp(
          navigatorObservers: [routeObserver],
          debugShowCheckedModeBanner: false,
          navigatorKey: ContextHelper.navigatorKey,
          scrollBehavior: const MyScrollBehavior(),
          title: 'App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: ColorManager.kPrimary, primary: ColorManager.kPrimary),
            useMaterial3: false,
            textTheme: Typography.blackMountainView,
            dialogTheme: const DialogThemeData(surfaceTintColor: Colors.transparent),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
