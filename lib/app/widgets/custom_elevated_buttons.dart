import 'package:flutter/material.dart';
import 'package:app/app/export.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';

class CenterTextIconButton extends StatelessWidget {
  final String buttonText;
  final String? iconData;
  final MainAxisAlignment? mainAlignment;
  final CrossAxisAlignment? crossAlignment;
  final VoidCallback onPress;
  final ButtonPosition iconPosition;
  final bool isLoading;
  // final bool buttonColors;
  final List<Color>? gradientColors;
  final Color? color;
  final bool isGradientColor;
  final Color? textColor;
  final double leftPadding;
  final double rightPadding;

  const CenterTextIconButton({
    super.key,
    required this.buttonText,
    this.iconData,
    this.mainAlignment,
    this.crossAlignment,
    required this.onPress,
    this.iconPosition = ButtonPosition.RIGHT,
    this.isLoading = false,
    // this.buttonColors = false,
    this.gradientColors,
    this.color,
    this.isGradientColor = true,
    this.textColor,
    this.leftPadding = 20,
    this.rightPadding = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SpinKitFadingCircle(color: ColorManager.kPrimary, size: 40);
    }
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: onPress,
      child: Container(
        padding: context.padding(left: leftPadding, right: rightPadding, bottom: 4, top: 4),
        width: context.horizontalSize(380),
        height: context.verticalSize(44),
        decoration: BoxDecoration(
          gradient:
              isGradientColor
                  ? LinearGradient(
                    colors: gradientColors ?? ColorManager.gradientButtons2,
                    begin: const Alignment(1.00, -0.00),
                    end: const Alignment(-1, 0),
                  )
                  : null,
          color: isGradientColor ? null : color,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: mainAlignment ?? MainAxisAlignment.center,
          crossAxisAlignment: crossAlignment ?? CrossAxisAlignment.center,
          children: [
            if (iconPosition == ButtonPosition.LEFT)
              iconData != null ? SvgPicture.asset(iconData ?? '') : const SizedBox.shrink(),
            if (iconPosition == ButtonPosition.LEFT) const SizedBox(width: 8),
            Text(buttonText, style: context.semiBold18(color: textColor ?? ColorManager.white)),
            if (iconPosition == ButtonPosition.RIGHT) const SizedBox(width: 6),
            if (iconPosition == ButtonPosition.RIGHT)
              iconData != null ? SvgPicture.asset(iconData ?? '') : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

enum ButtonPosition { LEFT, RIGHT }

class FilterButton extends StatelessWidget {
  final String icon;
  final String text;
  final bool isSelected;
  final Function(bool) onPressed;
  const FilterButton({
    super.key,
    required this.icon,
    required this.text,
    this.isSelected = false,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        onPressed(!isSelected);
      },
      child: Container(
        padding: context.padding(horizontal: 10, vertical: 4),
        margin: context.margin(right: 14),
        // width: context.horizontalSize(s100),
        // height: context.verticalSize(s44),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isSelected
                    ? ColorManager.gradientButtons
                    : [ColorManager.bgForButton, ColorManager.bgForButton, ColorManager.bgForButton],
            begin: const Alignment(1.00, -0.00),
            end: const Alignment(-1, 0),
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(icon, color: isSelected ? ColorManager.white : ColorManager.grayText),
            const SizedBox(width: 8),
            Text(text, style: context.semiBold14(color: isSelected ? ColorManager.white : ColorManager.grayText)),
          ],
        ),
      ),
    );
  }
}
