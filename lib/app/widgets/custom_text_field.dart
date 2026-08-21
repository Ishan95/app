import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../export.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      required this.controller,
      required this.validator,
      this.obscure,
      this.inputType,
      this.width,
      this.radius,
      this.context,
      this.hintText,
      this.hintTextStyle,
      this.errorMessage,
      this.interactiveSelection,
      this.emailBgColor,
      this.isEmailBgColor = false,
      this.txtColor = Colors.white,
      this.height = 40,
      this.onChanged,
      this.numberMaxLength,
      this.inputFormatters,
      this.suffixIcon,
      this.enabled = true,
      this.minLine = 1});

  final bool? obscure;
  final BuildContext? context;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final TextInputType? inputType;
  final double? width;
  final double? radius;
  final String? hintText;
  final TextStyle? hintTextStyle;
  final String? errorMessage;
  final bool? interactiveSelection;
  final bool isEmailBgColor;
  final Color? emailBgColor;
  final Color txtColor;
  final double height;
  final int? numberMaxLength;
  // final VoidCallback onChanged;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final Widget? suffixIcon;
  final int minLine;

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          // height: context.verticalSize(height),
          constraints: BoxConstraints(
            minHeight: context.verticalSize(height),
          ),
          decoration: ShapeDecoration(
            color: isEmailBgColor ? emailBgColor : ColorManager.white101,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? 10),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x19070424),
                blurRadius: 1,
                offset: Offset(1, 1),
                spreadRadius: 0,
              )
            ],
          ),
          child: TextFormField(
            enabled: enabled,
            onChanged: onChanged,
            keyboardType: inputType ?? TextInputType.multiline,
            obscureText: obscure ?? false,
            validator: validator,
            enableInteractiveSelection: interactiveSelection ?? true,
            autocorrect: false,
            controller: controller,
            textInputAction: TextInputAction.done,
            inputFormatters: inputFormatters,
            style: context.regular14(
              color: txtColor,
            ),
            maxLines: minLine,
            // minLines: 1,
            cursorColor: ColorManager.grayText,
            textAlignVertical: hintText == null
                ? TextAlignVertical.top
                : TextAlignVertical.center,
            decoration: InputDecoration(
              isDense: true,
              // constraints: BoxConstraints(
              //   minHeight: context.verticalSize(40),
              // ),
              // contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              constraints: BoxConstraints(
                minHeight:
                    context.verticalSize(height), // you can keep this as is
              ),
              hintText: hintText,
              hintStyle: hintTextStyle ??
                  TextStyle(
                    fontFamily: FontManager.fontFamily,
                    fontWeight: regular,
                    fontSize: context.fontSize(14),
                    color: ColorManager.disabledText,
                  ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(radius ?? 10),
              ),
              errorStyle: const TextStyle(height: -5),
              suffixIcon: suffixIcon,
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(radius ?? 10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(radius ?? 10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(radius ?? 10),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(radius ?? 10),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              top: errorMessage != null ? 4.0 : 4.0,
              left: 5.0,
            ),
            child: Text(
              errorMessage != null ? errorMessage! : '',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12.0,
              ),
            ),
          ),
        )
      ],
    );
  }
}
