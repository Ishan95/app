import 'package:app/app/export.dart';
import 'package:flutter/material.dart';

extension MulishTextStyles on BuildContext {
  /// Heading 1 text style
  /// fontWeight = 700
  TextStyle bold30({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamily,
        fontWeight: fontWeight ?? bold,
        fontSize: this.fontSize(fontSize ?? 30),
        color: color,
      );

  /// Heading 1 text style
  /// fontWeight = 700
  TextStyle boldNunito30({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamilyNunito,
        fontWeight: fontWeight ?? bold,
        fontSize: this.fontSize(fontSize ?? 30),
        color: color,
      );

  /// Heading 2 text style
  /// fontWeight = 600
  TextStyle semiBold20({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamily,
        fontWeight: fontWeight ?? semiBold,
        fontSize: this.fontSize(fontSize ?? 20),
        color: color,
      );

  /// Heading 3 text style
  /// fontWeight = 600
  TextStyle semiBold18({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamily,
        fontWeight: fontWeight ?? semiBold,
        fontSize: this.fontSize(fontSize ?? 18),
        color: color,
      );

  /// subtitle 1 text style
  /// fontWeight = 500
  TextStyle medium16({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamily,
        fontWeight: fontWeight ?? medium,
        fontSize: this.fontSize(fontSize ?? 16),
        color: color,
      );

  /// subtitle 1 text style sf pro
  /// fontWeight = 500
  TextStyle mediumSf16({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamilySf,
        fontWeight: fontWeight ?? medium,
        fontSize: this.fontSize(fontSize ?? 16),
        color: color,
      );

       /// subtitle 1 text style sf pro
  /// fontWeight = 400
  TextStyle mediumSf17({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamilySf,
        fontWeight: fontWeight ?? regular,
        fontSize: this.fontSize(fontSize ?? 17),
        color: color,
      );

  /// subtitle 2 text style
  /// fontWeight = 700
  TextStyle bold16({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamily,
        fontWeight: fontWeight ?? bold,
        fontSize: this.fontSize(fontSize ?? 16),
        color: color,
      );

  /// body 1 text style
  /// fontWeight = 400
  TextStyle regular16({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamily,
        fontWeight: fontWeight ?? regular,
        fontSize: this.fontSize(fontSize ?? 16),
        color: color,
      );

  /// body 2 text style
  /// fontWeight = 400
  TextStyle regular14({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamily,
        fontWeight: fontWeight ?? regular,
        fontSize: this.fontSize(fontSize ?? 14),
        color: color,
      );

  /// body 2 text style
  /// fontWeight = 400
  TextStyle regularMulish14({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamilyNunito,
        fontWeight: fontWeight ?? regular,
        fontSize: this.fontSize(fontSize ?? 14),
        color: color,
      );

  /// body 2 text style
  /// fontWeight = 400
  TextStyle regularMulish18({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamilyNunito,
        fontWeight: fontWeight ?? regular,
        fontSize: this.fontSize(fontSize ?? 18),
        color: color,
      );

  /// body 3 text style
  /// fontWeight = 600
  TextStyle semiBold14({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamily,
        fontWeight: fontWeight ?? semiBold,
        fontSize: this.fontSize(fontSize ?? 14),
        color: color,
      );

  /// body 4 text style
  /// fontWeight = 700
  TextStyle bold14({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,  
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamily,
        fontWeight: fontWeight ?? bold,
        fontSize: this.fontSize(fontSize ?? 14),
        color: color,
      );

  /// underlined Text text style
  /// fontWeight = 700
  TextStyle underlinedBold14({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamily,
        fontWeight: fontWeight ?? bold,
        fontSize: this.fontSize(fontSize ?? 14),
        color: color,
        decoration: TextDecoration.underline,
        decorationColor: color,
      );

  /// mini 1 text style
  /// fontWeight = 400
  TextStyle regular12({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamily,
        fontWeight: fontWeight ?? regular,
        fontSize: this.fontSize(fontSize ?? 12),
        color: color,
      );

  /// mini 2 text style
  /// fontWeight = 700
  TextStyle bold12({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamily,
        fontWeight: fontWeight ?? bold,
        fontSize: this.fontSize(fontSize ?? 12),
        color: color,
      );

  /// body 3 text style
  /// fontWeight = 300
  TextStyle light14({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) =>
      TextStyle(
        fontFamily: FontManager.fontFamily,
        fontWeight: fontWeight ?? light,
        fontSize: this.fontSize(fontSize ?? 14),
        color: color,
      );
}
