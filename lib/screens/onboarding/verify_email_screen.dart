import 'package:app/app/export.dart';
import 'package:app/providers/account_provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/screens/home/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VerifyEmailScreen extends StatefulWidget {
  final firebase_auth.User user;
  final bool isSelected;
  final bool isSchoolSelected;
  final bool isEnable;
  const VerifyEmailScreen({required this.user, required this.isSelected, required this.isSchoolSelected, required this.isEnable, super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool checking = false;

  Future<bool?> _saveAlertDialog(
    BuildContext context,
    String title,
    String content,
    String confirmText,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              textAlign: TextAlign.start,
              style: context.bold16(color: ColorManager.black),
            ),
            content: Text(
              content,
              textAlign: TextAlign.start,
              style: context.regular14(
                color: ColorManager.black.withOpacity(0.8),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: context.semiBold14(color: ColorManager.black),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  confirmText,
                  style: context.semiBold14(color: ColorManager.red),
                ),
              ),
            ],
          ),
    );
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
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "A verification link has been sent to your email.\nPlease verify and then click continue.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: checking ? null : checkVerification,
              child: checking
                  ? const CircularProgressIndicator()
                  : const Text("I Verified, Continue"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                await widget.user.sendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Verification email resent")),
                );
              },
              child: const Text("Resend Verification Email"),
            )
          ],
        ),
      ),
    );
  }

  Future<void> checkVerification() async {
    setState(() => checking = true);

    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final accProvider = Provider.of<AccountProvider>(context, listen: false);
    final verified = await authProvider.reloadAndCheckVerified();

    if (verified) {

      final success = await authProvider.createAccount(isPhoneHide: widget.isSelected, isSchoolHide: widget.isSchoolSelected, isEnable: widget.isEnable);

      if(success) {
        await accProvider.refreshCurrentUser();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => Home(index: 0)),
          (route) => false,
        );
      } else {
        final shouldSave = await _saveAlertDialog(
                            context,
                            "Can't create your Account",
                            "Please connect with us via WhatsApp to create your account.",
                            'Need Help?',
                          );

                          if (shouldSave == true) {
                            contactWhatsApp(
                          "94713905383",
                          "Hello, I need assistance with my account.",
                        );
                          }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email not verified yet!")),
      );
    }

    setState(() => checking = false);
  }
}
