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

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final informationFormKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String? errorMessage;
  String? errorNewPasswordMessage;
  String? errorConfirmPasswordMessage;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureTextConfirmPassword = true;
  final accProvider = Provider.of<AccountProvider>(
    ContextHelper.navigatorKey.currentContext!,
    listen: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.kPrimaryBlack,
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: context.semiBold20(color: ColorManager.white),
        ),
        backgroundColor: ColorManager.kPrimaryBlack,
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
                child: Text(
                  "Current Password",
                  style: context.semiBold14(color: ColorManager.grayText),
                ),
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
                      errorMessage = "Current Password is required";
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
                  icon: Icon(
                    _obscureCurrentPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
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
                child: Text(
                  "New Password",
                  style: context.semiBold14(color: ColorManager.grayText),
                ),
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
                      errorNewPasswordMessage = "New Password is required";
                    });
                    return '';
                  } else if (value.length < 8) {
                    setState(() {
                      errorNewPasswordMessage =
                          "New Password must be 8+ characters and include a number, uppercase letter, and special character";
                    });
                    return '';
                  } else if (value.length > 64) {
                    setState(() {
                      errorNewPasswordMessage =
                          "New Password must be 8–64 characters long";
                    });
                    return '';
                  } else if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                    setState(() {
                      errorNewPasswordMessage =
                          "Must include at least one uppercase letter";
                    });
                    return '';
                  } else if (!RegExp(r'^(?=.*\d)').hasMatch(value)) {
                    setState(() {
                      errorNewPasswordMessage =
                          "Must include at least one number";
                    });
                    return '';
                  } else if (!RegExp(
                    r'^(?=.*[!@#\$&*~%^()_\-+=<>?])',
                  ).hasMatch(value)) {
                    setState(() {
                      errorNewPasswordMessage =
                          "Must include at least one special character";
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
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
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
                child: Text(
                  "Confirm Password",
                  style: context.semiBold14(color: ColorManager.grayText),
                ),
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
                      errorConfirmPasswordMessage =
                          "Confirm Password is required";
                    });
                    return '';
                  } else if (value != newPasswordController.text) {
                    setState(() {
                      errorConfirmPasswordMessage = "Passwords do not match!";
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
                  icon: Icon(
                    _obscureTextConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureTextConfirmPassword =
                          !_obscureTextConfirmPassword;
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
                      await accProvider.changePassword(
                        currentPassword: currentPassword,
                        newPassword: newPassword,
                      );
                      Navigator.pop(context);
                      toastSuccessMessage('Password changed successfully.');
                    } catch (e) {
                      setState(() {
                        errorMessage = "Current password is incorrect.";
                      });
                    }
                  }
                },
                isGradientColor: true,
                gradientColors: ColorManager.gradientButtons2,
                buttonText: 'Change Password',
                isLoading: accProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
