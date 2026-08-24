import 'package:app/app/themes/text_themes.dart';
import 'package:app/app/utils/color_manager.dart';
import 'package:app/app/utils/context_helper.dart';
import 'package:app/app/utils/custom_toast.dart';
import 'package:app/app/utils/responsive_size_config.dart';
import 'package:app/app/widgets/custom_elevated_buttons.dart';
import 'package:app/app/widgets/custom_text_field.dart';
import 'package:app/providers/account_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/l10n/app_localizations.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final informationFormKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String? errorMessage;
  String? errorNewPasswordMessage;
  String? errorConfirmPasswordMessage;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureTextConfirmPassword = true;
  final accProvider = Provider.of<AccountProvider>(ContextHelper.navigatorKey.currentContext!, listen: false);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorManager.kPrimaryBlack,
      appBar: AppBar(
        title: Text(l10n.changePasswordTitle, style: context.semiBold20(color: ColorManager.blackMedium)),
        backgroundColor: ColorManager.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: ColorManager.blackMedium),
      ),
      body: Padding(
        padding: context.padding(horizontal: 24),
        child: Form(
          key: informationFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.verticalSize(20)),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.currentPassword, style: context.semiBold14(color: ColorManager.blackMedium)),
              ),
              SizedBox(height: context.verticalSize(4)),
              CustomTextField(
                radius: 30,
                controller: currentPasswordController,
                inputType: TextInputType.visiblePassword,
                hintText: '*******',
                obscure: _obscureCurrentPassword,
                validator: (value) {
                  if (currentPasswordController.text.isEmpty) {
                    setState(() {
                      errorMessage = l10n.reqCurrentPassword;
                    });
                    return '';
                  }
                  setState(() {
                    errorMessage = null;
                  });
                  return null;
                },
                errorMessage: errorMessage,
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrentPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
              ),
              SizedBox(height: context.verticalSize(4)),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.newPassword, style: context.semiBold14(color: ColorManager.blackMedium)),
              ),
              SizedBox(height: context.verticalSize(4)),
              CustomTextField(
                radius: 30,
                controller: newPasswordController,
                inputType: TextInputType.visiblePassword,
                hintText: '*******',
                obscure: _obscureNewPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    setState(() {
                      errorNewPasswordMessage = l10n.reqNewPassword;
                    });
                    return '';
                  } else if (value.length < 8) {
                    setState(() {
                      errorNewPasswordMessage = l10n.reqPasswordLength;
                    });
                    return '';
                  } else if (value.length > 64) {
                    setState(() {
                      errorNewPasswordMessage = l10n.reqPasswordLength64;
                    });
                    return '';
                  } else if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                    setState(() {
                      errorNewPasswordMessage = l10n.reqUppercase;
                    });
                    return '';
                  } else if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
                    setState(() {
                      errorNewPasswordMessage = l10n.reqNumber;
                    });
                    return '';
                  } else if (!RegExp(r'^(?=.*[!@#\$&*~%^()_\-+=<>?])').hasMatch(value)) {
                    setState(() {
                      errorNewPasswordMessage = l10n.reqSpecialChar;
                    });
                    return '';
                  }
                  setState(() {
                    errorNewPasswordMessage = null;
                  });
                  return null;
                },
                errorMessage: errorNewPasswordMessage,
                suffixIcon: IconButton(
                  icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
              SizedBox(height: context.verticalSize(10)),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.confirmPassword, style: context.semiBold14(color: ColorManager.blackMedium)),
              ),
              SizedBox(height: context.verticalSize(4)),
              CustomTextField(
                radius: 30,
                controller: confirmPasswordController,
                inputType: TextInputType.visiblePassword,
                hintText: '*******',
                obscure: _obscureTextConfirmPassword,
                validator: (value) {
                  if (confirmPasswordController.text.isEmpty) {
                    setState(() {
                      errorConfirmPasswordMessage = l10n.reqConfirmPassword;
                    });
                    return '';
                  } else if (value != newPasswordController.text) {
                    setState(() {
                      errorConfirmPasswordMessage = l10n.reqPasswordMatch;
                    });
                    return '';
                  }
                  setState(() {
                    errorConfirmPasswordMessage = null;
                  });
                  return null;
                },
                errorMessage: errorConfirmPasswordMessage,
                suffixIcon: IconButton(
                  icon: Icon(_obscureTextConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
                    });
                  },
                ),
              ),
              SizedBox(height: context.verticalSize(20)),
              CenterTextIconButton(
                onPress: () async {
                  final currentPassword = currentPasswordController.text.trim();
                  final newPassword = newPasswordController.text.trim();
                  if (informationFormKey.currentState!.validate()) {
                    try {
                      await accProvider.changePassword(currentPassword: currentPassword, newPassword: newPassword);
                      Navigator.pop(context);
                      toastSuccessMessage(l10n.passwordChangedSuccess);
                    } catch (e) {
                      setState(() {
                        errorMessage = l10n.currentPasswordIncorrect;
                      });
                    }
                  }
                },
                isGradientColor: true,
                gradientColors: ColorManager.gradientButtons2,
                buttonText: l10n.changePasswordTitle,
                isLoading: accProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
