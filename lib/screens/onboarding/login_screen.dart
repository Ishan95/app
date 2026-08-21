import 'package:app/app/utils/custom_toast.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/screens/home/home.dart';
import 'package:app/screens/onboarding/get_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/export.dart';

class LoginScreen extends StatefulWidget {
  final String? userType;
  const LoginScreen({super.key, this.userType});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final signInForm = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _obscureDeviceID = true;

  String? verificationId;
  String? passwordError;

  String? emailError;
    
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
    final authProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorManager.kPrimaryBlack,
      body: Padding(
        padding: context.padding(horizontal: 24, top: 14, bottom: 44),
        child: Consumer<AuthenticationProvider>(
          builder: (context, auth, child) {
            return Form(
              key: signInForm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Welcome",
                      style: context.semiBold20(
                        color: ColorManager.white,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  SizedBox(height: context.verticalSize(6)),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Log in to your account below",
                      style: context.regular14(color: ColorManager.white),
                    ),
                  ),
                  SizedBox(height: context.verticalSize(90)),
                  Text(
                    'Email',
                    textAlign: TextAlign.left,
                    style: context.semiBold14(color: ColorManager.grayText),
                  ),
                  SizedBox(height: context.verticalSize(6)),
                  CustomTextField(
                    radius: 30,
                    height: 40,
                    controller: auth.emailController,
                    inputType: TextInputType.emailAddress,
                    hintText: 'Email Address',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() {
                          emailError = "Email is required";
                        });
                        return '';
                      } else if (!RegExp(
                        r'^[^@]+@[^@]+\.[^@]+',
                      ).hasMatch(value!)) {
                        setState(() {
                          emailError = "Enter a valid email address";
                        });
                        return '';
                      }
                      setState(() {
                        emailError = null;
                      });
                      return null;
                    },
                    errorMessage: emailError,
                  ),
                  SizedBox(height: context.verticalSize(2)),
                  Text(
                    "Password",
                    textAlign: TextAlign.left,
                    style: context.semiBold14(color: ColorManager.grayText),
                  ),
                  SizedBox(height: context.verticalSize(6)),
                  CustomTextField(
                    radius: 30,
                    height: 40,
                    controller: auth.passwordController,
                    obscure: _obscureText,
                    hintText: '*******',
                    // interactiveSelection: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        // return "Password is required";
                        setState(() {
                          passwordError = "Password is required";
                        });
                        return '';
                      }
                      setState(() {
                        passwordError = null;
                      });
                      return null;
                    },
                    errorMessage: passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: context.verticalSize(10)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder:
                              (BuildContext context) =>
                                  const GetDetailsScreen(isSignupEmail: true),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Don\'t have an account?    ",
                            style: context.regular12(
                              color: ColorManager.grayText,
                            ),
                          ),
                          TextSpan(
                            text: "Create a new account",
                            style: context.bold12(color: ColorManager.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: context.verticalSize(10)),
                  auth.currentDeviceID != "" ? Row(
                    children: [
                      GestureDetector(
                          child: Icon(
                            _obscureDeviceID ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            setState(() {
                              _obscureDeviceID = !_obscureDeviceID;
                            });
                          },
                        ),
                  SizedBox(width: context.horizontalSize(10)),
                        !_obscureDeviceID ? Text(
                      auth.currentDeviceID,
                      style: context.regular14(color: ColorManager.white),
                    ) : SizedBox.shrink(),
                    ],
                  ) : SizedBox.shrink(),
                  SizedBox(height: context.verticalSize(100)),
                  CenterTextIconButton(
                    onPress: () async {
                      final success = await auth.signIn(
                        email: auth.emailController.text.trim(),
                        password: auth.passwordController.text.trim(),
                      );

                      // After signIn, check if the user is now logged in
                      // (The provider's listener will handle UI updates for _user state)
                      if (authProvider.user != null && success) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => Home(index: 0),
                          ),
                          (route) => false,
                        );
                      } else {
                        if (mounted) {
                          toastErrorMessage(
                            auth.errorMessage ??
                                'Login failed. Please try again.',
                          );
                        }
                      }
                    },
                    // isLoading: auth.getIsSignIn,
                    buttonText: "Log in",
                    isLoading: auth.isLoading,
                  ),
                  SizedBox(height: context.verticalSize(50)),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        contactWhatsApp(
                          "94713905383",
                          "Hello, I need assistance with my account.",
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Can't Log In or Create an Account?    ",
                              style: context.regular12(
                                color: ColorManager.grayText,
                              ),
                            ),
                            TextSpan(
                              text: "Need Help?",
                              style: context.bold12(color: ColorManager.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.verticalSize(50)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
