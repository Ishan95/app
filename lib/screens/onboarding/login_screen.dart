import 'package:app/app/utils/custom_toast.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/screens/home/home.dart';
import 'package:app/screens/onboarding/get_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/app/widgets/language_selector.dart';

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
    if (!phone.startsWith('+')) {
      phone = '+$phone';
    }

    final encodedMessage = Uri.encodeComponent(message);

    final uriApp = Uri.parse("https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage");
    final uriWeb = Uri.parse("https://wa.me/$phone?text=$encodedMessage");

    try {
      if (await canLaunchUrl(uriApp)) {
        print('$uriApp');
        await launchUrl(uriApp, mode: LaunchMode.externalApplication);
        return;
      }

      if (await canLaunchUrl(uriWeb)) {
        print('$uriWeb');
        await launchUrl(uriWeb, mode: LaunchMode.platformDefault);
        return;
      }
      print("WhatsApp not available");
    } catch (e) {
      print("Error launching WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorManager.kPrimaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [LanguageSelector(), SizedBox(width: 16)],
      ),
      body: Padding(
        padding: context.padding(horizontal: 24, bottom: 24),
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
                    child: Text(l10n.welcome, style: context.semiBold20(color: ColorManager.blackMedium, fontSize: 30)),
                  ),
                  SizedBox(height: context.verticalSize(6)),
                  Align(
                    alignment: Alignment.center,
                    child: Text(l10n.loginBelow, style: context.regularMulish18(color: ColorManager.grayText)),
                  ),
                  SizedBox(height: context.verticalSize(50)),
                  // Text(l10n.email, textAlign: TextAlign.left, style: context.semiBold14(color: ColorManager.grayText)),
                  // SizedBox(height: context.verticalSize(6)),
                  // CustomTextField(
                  //   radius: 30,
                  //   height: 40,
                  //   controller: auth.emailController,
                  //   inputType: TextInputType.emailAddress,
                  //   hintText: l10n.emailAddress,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       setState(() {
                  //         emailError = l10n.reqEmail;
                  //       });
                  //       return '';
                  //     } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                  //       setState(() {
                  //         emailError = l10n.reqValidEmail;
                  //       });
                  //       return '';
                  //     }
                  //     setState(() {
                  //       emailError = null;
                  //     });
                  //     return null;
                  //   },
                  //   errorMessage: emailError,
                  // ),
                  // SizedBox(height: context.verticalSize(2)),
                  // Text(
                  //   l10n.password,
                  //   textAlign: TextAlign.left,
                  //   style: context.semiBold14(color: ColorManager.grayText),
                  // ),
                  // SizedBox(height: context.verticalSize(6)),
                  // CustomTextField(
                  //   radius: 30,
                  //   height: 40,
                  //   controller: auth.passwordController,
                  //   obscure: _obscureText,
                  //   hintText: '*******',
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       setState(() {
                  //         passwordError = l10n.reqPassword;
                  //       });
                  //       return '';
                  //     }
                  //     setState(() {
                  //       passwordError = null;
                  //     });
                  //     return null;
                  //   },
                  //   errorMessage: passwordError,
                  //   suffixIcon: IconButton(
                  //     icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  //     onPressed: () {
                  //       setState(() {
                  //         _obscureText = !_obscureText;
                  //       });
                  //     },
                  //   ),
                  // ),
                  // SizedBox(height: context.verticalSize(10)),
                  GestureDetector(
                    onTap: () {
                      authProvider.clearData();
                      setState(() {
                        emailError = null;
                        passwordError = null;
                        _obscureText = true;
                        _obscureDeviceID = true;
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const GetDetailsScreen(isSignupEmail: true),
                        ),
                      ).then((_) {
                        authProvider.clearData();
                        setState(() {
                          emailError = null;
                          passwordError = null;
                          _obscureText = true;
                          _obscureDeviceID = true;
                        });
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: l10n.dontHaveAccount, style: context.regular16(color: ColorManager.grayText)),
                          TextSpan(text: l10n.createNewAccount, style: context.bold16(color: ColorManager.kPrimary)),
                        ],
                      ),
                    ),
                  ),
                  // SizedBox(height: context.verticalSize(10)),
                  // auth.currentDeviceID != ""
                  //     ? Row(
                  //       children: [
                  //         GestureDetector(
                  //           child: Icon(_obscureDeviceID ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  //           onTap: () {
                  //             setState(() {
                  //               _obscureDeviceID = !_obscureDeviceID;
                  //             });
                  //           },
                  //         ),
                  //         SizedBox(width: context.horizontalSize(10)),
                  //         !_obscureDeviceID
                  //             ? Text(auth.currentDeviceID, style: context.regular14(color: ColorManager.blackMedium))
                  //             : const SizedBox.shrink(),
                  //       ],
                  //     )
                  //     : const SizedBox.shrink(),
                  // SizedBox(height: context.verticalSize(50)),
                  // CenterTextIconButton(
                  //   onPress: () async {
                  //     if (signInForm.currentState!.validate()) {
                  //       final success = await auth.signIn(
                  //         email: auth.emailController.text.trim(),
                  //         password: auth.passwordController.text.trim(),
                  //       );
                  //
                  //       if (authProvider.user != null && success) {
                  //         Navigator.pushAndRemoveUntil(
                  //           context,
                  //           MaterialPageRoute<void>(builder: (BuildContext context) => const Home(index: 0)),
                  //               (route) => false,
                  //         );
                  //       } else {
                  //         if (mounted) {
                  //           toastErrorMessage(auth.errorMessage ?? l10n.loginFailed);
                  //         }
                  //       }
                  //     }
                  //   },
                  //   buttonText: l10n.logIn,
                  //   isLoading: auth.isLoading && !auth.isGoogleAuth,
                  // ),
                  // SizedBox(height: context.verticalSize(16)),
                  // Align(
                  //   alignment: Alignment.center,
                  //   child: Text(l10n.or, style: context.semiBold14(color: ColorManager.blackMedium, fontSize: 16)),
                  // ),
                  SizedBox(height: context.verticalSize(16)),
                  CenterTextIconButton(
                    onPress: () async {
                      final res = await auth.signInWithGoogle();
                      if (res['success'] == true) {
                        if (res['isComplete'] == true) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute<void>(builder: (BuildContext context) => const Home(index: 0)),
                                (route) => false,
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(builder: (BuildContext context) => const GetDetailsScreen(isSignupEmail: false)),
                          );
                        }
                      } else if (res['error'] != 'Sign in aborted') {
                        if (mounted) {
                          toastErrorMessage(res['error']);
                        }
                      }
                    },
                    buttonText: l10n.continueWithGoogle,
                    isLoading: auth.isLoading && auth.isGoogleAuth,
                  ),

                  SizedBox(height: context.verticalSize(40)),
                  GestureDetector(
                      onTap: () {
                        contactWhatsApp("94713905383", l10n.whatsappSupportMessage);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: l10n.cantLogInOrCreate,
                                    style: context.regular16(color: ColorManager.grayText),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: l10n.needHelp, style: context.bold16(color: ColorManager.kPrimary)),
                              ],
                            ),
                          ),
                        ],
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
