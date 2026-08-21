import 'package:app/app/export.dart';
import 'package:flutter/material.dart';

class CustomHeightBox extends StatelessWidget {
  const CustomHeightBox({
    super.key,
    required this.height,
  });
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.horizontalSize(height),
    );
  }
}
