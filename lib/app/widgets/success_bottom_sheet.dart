import 'package:flutter/material.dart';
import 'package:app/app/export.dart';

class SuccessBottomSheet {
  static Future<Widget> showSuccessBottomSheet(
      {required BuildContext context,
      String? iconPath,
      String? title,
      String? description,
      String? buttonText,
      String? buttonText2,
      required double height,
      Function()? onPress,
      Function()? cancelOnTap,
      Function()? onDismiss}) async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: ColorManager.black,
      builder: (BuildContext context) {
        return SizedBox(
          height: height,
          child: Column(
            children: [
              iconPath != null
                  ? Image.asset(
                      iconPath,
                      width: 70.0,
                      fit: BoxFit.fill,
                    )
                  : const SizedBox(),
              SizedBox(height: context.verticalSize(20)),
              Text(
                title ?? "",
                style:
                    context.bold16(fontSize: 18, color: ColorManager.white),
              ),
              SizedBox(height: context.verticalSize(10)),
              Text(
                description ?? "",
                style: context.regular12(color: ColorManager.disabledText),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              buttonText != null
                  ? CenterTextIconButton(
                      buttonText: buttonText,
                      onPress: onPress ?? () {},
                      // iconData: Assets.circleOutwardArrowSVG,
                      mainAlignment: MainAxisAlignment.spaceBetween,
                      crossAlignment: CrossAxisAlignment.center,
                    )
                  : const SizedBox(),
              buttonText2 != null
                  ? CenterTextIconButton(
                      buttonText: buttonText2,
                      onPress: onPress ?? () {},
                      crossAlignment: CrossAxisAlignment.center,
                    )
                  : const SizedBox(),
              SizedBox(height: context.verticalSize(20)),
            ],
          ),
        );
      },
    ).then((value) {
      if (onDismiss != null) {
        onDismiss();
      }
      return const SizedBox();
    });
  }
}
