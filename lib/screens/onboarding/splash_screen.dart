import 'dart:async';

import 'package:app/app/utils/context_helper.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/screens/home/home.dart';
import 'package:app/screens/onboarding/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/app/export.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final authProvider = Provider.of<AuthenticationProvider>(ContextHelper.navigatorKey.currentContext!, listen: false);
  late VideoPlayerController _controller;

  String _currentAppVersion = 'Loading...';
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseAndCheckForUpdates();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final userID = prefs.getString('userId');
      if (userID != null) {
      } else {
        await Future.delayed(const Duration(seconds: 4)); // Ensure Lottie runs
      }

      if (!mounted) return;
    });
    _controller = VideoPlayerController.asset(Assets.splashVideo)
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {});
              _controller.play();
            }
          })
          .catchError((error) {
            // THIS WILL PRINT THE EXACT FAILURE IN DEBUG CONSOLE
            print("Video Initialization Error: $error");
          });

    _controller.addListener(() {
      if (_controller.value.hasError) {
        print("Video Player Error: ${_controller.value.errorDescription}");
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeFirebaseAndCheckForUpdates() async {
    // Ensure Firebase is initialized
    await Future.delayed(const Duration(seconds: 2));
    await Firebase.initializeApp(); // Only needed if not already called in main()

    // Get current app version
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _currentAppVersion = packageInfo.version;
    });

    // Initialize Remote Config
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1), // How long to wait to fetch
        minimumFetchInterval: const Duration(minutes: 1), // How often to fetch
      ),
    );

    // Set default values (matches console default, important for initial fetch)
    // await _remoteConfig.setDefaults(<String, dynamic>{
    //   'minimum_required_app_version': '1.0.2', // Default if no value is fetched
    // });

    try {
      // Fetch and activate remote config values
      await _remoteConfig.fetchAndActivate();

      String minimumRequiredVersion = _remoteConfig.getString('minimum_required_app_version');
      print("Fetched minimum required version: $minimumRequiredVersion    $_currentAppVersion");
      // Compare versions
      if (_isUpdateRequired(_currentAppVersion, minimumRequiredVersion)) {
        _showForceUpdateDialog();
      } else {
        if (authProvider.user != null) {
          // return const LoginScreen();
          await authProvider.updateFcmToken();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(builder: (BuildContext context) => const Home(index: 0)),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(builder: (BuildContext context) => const LoginScreen()),
            (route) => false,
          );
          // return const UserListScreen(); // Or your main app screen after login
        }
      }
    } catch (e) {
      print("Error fetching remote config: $e");
      // Handle error gracefully, maybe allow user to proceed or show a warning.
      if (authProvider.user != null) {
        // return const LoginScreen();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(builder: (BuildContext context) => const Home(index: 0)),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(builder: (BuildContext context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  bool _isUpdateRequired(String currentVersion, String minimumRequiredVersion) {
    List<int> currentParts = currentVersion.split('.').map(int.parse).toList();
    List<int> minimumParts = minimumRequiredVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < minimumParts.length; i++) {
      if (i >= currentParts.length || currentParts[i] < minimumParts[i]) {
        return true; // Current version is older
      } else if (currentParts[i] > minimumParts[i]) {
        return false; // Current version is newer or equal at this part
      }
    }
    return false; // Versions are the same, no update required
  }

  void _showForceUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorManager.white,
          title: Text('New Version Available', style: context.semiBold14(color: ColorManager.blackMedium)),
          content: Text(
            'A new version of the app is available. Please update to continue using the app.',
            style: context.semiBold14(color: ColorManager.blackMedium),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Need Help?', style: context.semiBold14(color: ColorManager.kPrimary)),
              onPressed: () {
                contactWhatsApp("94713905383", "Hello, I need assistance with my account.");
              },
            ),
            TextButton(
              child: Text('Update Now', style: context.semiBold14(color: ColorManager.blackMedium)),
              onPressed: () {
                _launchStore();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchStore() async {
    String url = '';
    if (Platform.isAndroid) {
      // Replace 'com.example.app' with your actual Android package name
      url = 'market://details?id=lk.transfer.multiservice';
    } else if (Platform.isIOS) {
      // Replace 'id123456789' with your actual iOS App Store ID
      url = 'https://apps.apple.com/app/id123456789';
    }

    if (url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('Could not launch $url');
      // Optionally show an error message to the user
    }
  }

  Future<void> contactWhatsApp(String phone, String message) async {
    // Ensure the phone number is in E.164 format
    if (!phone.startsWith('+')) {
      phone = '+$phone'; // Add '+' if missing
    }

    // Encode the message
    final encodedMessage = Uri.encodeComponent(message);

    // Create WhatsApp URLs
    // final uriApp = Uri.parse("whatsapp://send?phone=$phone&text=$encodedMessage");
    final uriApp = Uri.parse("https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage");
    final uriWeb = Uri.parse("https://wa.me/$phone?text=$encodedMessage");

    try {
      // 1. Try opening the WhatsApp app
      if (await canLaunchUrl(uriApp)) {
        print('$uriApp');
        await launchUrl(uriApp, mode: LaunchMode.externalApplication);
        return;
      }

      // 2. Fallback to WhatsApp Web
      if (await canLaunchUrl(uriWeb)) {
        print('$uriWeb');
        await launchUrl(uriWeb, mode: LaunchMode.platformDefault); // For iOS
        return;
      }

      // 3. If both fail, print an error
      print("WhatsApp not available");
    } catch (e) {
      print("Error launching WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: SizedBox.expand(child: Image.asset(Assets.appIcon2, fit: BoxFit.fill)),
    );
    //       body: _controller.value.isInitialized
    //         ? SizedBox.expand(
    //   child: Transform.scale(
    //     scale: 0.85, // Reduces BoxFit.cover zoom by 8%
    //     child: FittedBox(
    //       fit: BoxFit.cover,
    //       child: SizedBox(
    //         width: _controller.value.size.width,
    //         height: _controller.value.size.height,
    //         child: VideoPlayer(_controller),
    //       ),
    //     ),
    //   ),
    // ) : const Center(child: CircularProgressIndicator()),
    //   );
  }
}
