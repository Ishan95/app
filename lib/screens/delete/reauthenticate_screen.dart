import 'package:app/app/themes/text_themes.dart';
import 'package:app/app/utils/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/l10n/app_localizations.dart';

class ReauthenticateScreen extends StatefulWidget {
  const ReauthenticateScreen({super.key});

  @override
  State<ReauthenticateScreen> createState() => _ReauthenticateScreenState();
}

class _ReauthenticateScreenState extends State<ReauthenticateScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage;

  Future<void> _reauthenticate(AppLocalizations l10n) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = l10n.noUserLoggedIn;
        });
        return;
      }

      final credential = EmailAuthProvider.credential(email: user.email!, password: _passwordController.text.trim());

      await user.reauthenticateWithCredential(credential);
      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = l10n.unexpectedError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorManager.kPrimaryBlack,
      appBar: AppBar(
        title: Text(l10n.deleteUser, style: TextStyle(color: ColorManager.blackMedium)),
        backgroundColor: ColorManager.white,
        iconTheme: IconThemeData(color: ColorManager.blackMedium),
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.enterPasswordToContinue, style: context.regular16(color: ColorManager.blackMedium)),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(color: ColorManager.blackMedium),
              decoration: InputDecoration(
                labelText: l10n.password,
                labelStyle: TextStyle(color: ColorManager.grayText),
                errorText: _errorMessage,
                filled: true,
                fillColor: ColorManager.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _reauthenticate(l10n),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Text(l10n.deleteUser, style: context.semiBold14(color: ColorManager.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
