import 'package:flutter/material.dart';
import 'package:app/app/export.dart';
import 'package:flutter_svg/svg.dart';

class CircularCustomIconButton extends StatelessWidget {
  const CircularCustomIconButton({
    super.key,
    this.radius,
    required this.assetName,
    this.backgroundColor,
    this.onPressed,
  });
  final Color? backgroundColor;
  final double? radius;
  final String assetName;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: CircleAvatar(
        backgroundColor: backgroundColor ?? ColorManager.kPrimaryLight,
        radius: radius ?? 22,
        child: SvgPicture.asset(
          assetName,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
