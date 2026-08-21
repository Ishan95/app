import 'package:app/app/themes/text_themes.dart';
import 'package:app/app/utils/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReauthenticateScreen extends StatefulWidget {
  const ReauthenticateScreen({super.key});

  @override
  State<ReauthenticateScreen> createState() => _ReauthenticateScreenState();
}

class _ReauthenticateScreenState extends State<ReauthenticateScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage;

  Future<void> _reauthenticate() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = "No user is currently logged in.";
        });
        return;
      }

      final credential = EmailAuthProvider.credential(email: user.email!, password: _passwordController.text.trim());

      await user.reauthenticateWithCredential(credential);
      Navigator.pop(context, true); // Return success to the previous screen
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An unexpected error occurred.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.kPrimaryBlack,
      appBar: AppBar(
        title: Text("Delete User", style: TextStyle(color: ColorManager.blackMedium)),
        backgroundColor: ColorManager.white,
        iconTheme: IconThemeData(color: ColorManager.blackMedium),
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Please enter your password to continue.", style: context.regular16(color: ColorManager.blackMedium)),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(color: ColorManager.blackMedium),
              decoration: InputDecoration(
                labelText: "Password",
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
                onPressed: _reauthenticate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.kPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Text("Delete User", style: context.semiBold14(color: ColorManager.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
