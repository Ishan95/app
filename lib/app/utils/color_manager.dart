import 'package:flutter/material.dart';

class ColorManager {
  static Color kPrimary = HexColor.fromHex('#1877F2');
  static Color kPrimaryDark = HexColor.fromHex('#165DB9');
  static Color kPrimaryExtra = HexColor.fromHex('#4267B2');
  static Color kPrimaryWarm = HexColor.fromHex('#89CFF0');
  static Color kPrimaryLight = HexColor.fromHex('#E7F3FF');
  static Color kSecondary = HexColor.fromHex('#B983FF');
  static Color kSecondaryOP = HexColor.fromHex('#B983FF').withOpacity(.12);

  static Color kNewSecondary = HexColor.fromHex('#4831D4');
  static Color kSecondaryLight = HexColor.fromHex('#F0F2F5');
  static Color kSecondaryGrad = HexColor.fromHex('#E7F3FF');
  static Color greenPrimary = HexColor.fromHex('#1877F2');
  static Color kfilterButtonColor = HexColor.fromHex('#EBEDF0');
  static Color kAleartTextColor = HexColor.fromHex('#0A84FF');
  static Color kAleartCancelTextColor = HexColor.fromHex('#FE7575');
  static Color kSubplanTextColor = HexColor.fromHex('#1C1E21');
  static Color kCirculerFirstColor = HexColor.fromHex('#1877F2');
  static Color kCirculerSecondColor = HexColor.fromHex('#8B46FB1F').withOpacity(0.12);

  static List<Color> gradientButtons = [
    HexColor.fromHex('#4267B2'),
    HexColor.fromHex('#1877F2'),
    HexColor.fromHex('#89CFF0'),
  ];

  static List<Color> gradientButtons2 = [
    HexColor.fromHex('#4267B2'),
    HexColor.fromHex('#1877F2'),
  ];

  static List<Color> gradientButtons3 = [
    HexColor.fromHex('#E7F3FF'),
    HexColor.fromHex('#89CFF0'),
  ];

  static List<Color> gradientButtonsPurple = [
    HexColor.fromHex('#D1ADFF'),
    HexColor.fromHex('#E7D5FF'),
  ];

  static List<Color> gradientBlueButtons = [
    HexColor.fromHex('#4267B2'),
    HexColor.fromHex('#1877F2'),
  ];

  static List<Color> gradientLightGreen = [
    HexColor.fromHex('#E7F3FF'),
    HexColor.fromHex('#89CFF0'),
  ];

  static List<Color> gradientGreenDark = [
    HexColor.fromHex('#1877F2').withOpacity(.80),
    HexColor.fromHex('#FFFFFF').withOpacity(.10),
  ];

  static List<Color> gradientBlackforBlur = [
    HexColor.fromHex('#FFFFFF'),
    HexColor.fromHex('#F0F2F500'),
  ];

  static List<Color> gradientGray = [
    HexColor.fromHex('#E0E0E0'),
    HexColor.fromHex('#ECEFEB'),
  ];

  static List<Color> lightBlackGradient = [
    HexColor.fromHex('#F0F2F5'),
    HexColor.fromHex('#FFFFFF'),
  ];

  static List<Color> subPlanRemain = [
    HexColor.fromHex('#EEFF0000').withOpacity(0.1),
    HexColor.fromHex('#FFEA0000'),
    HexColor.fromHex('#1877F2'),
  ];

  static Color black = HexColor.fromHex('#1C1E21');
  static Color black2 = HexColor.fromHex('#000000');
  static Color blackMedium = HexColor.fromHex('#1C1E21');
  static Color blackTransparent60 = Color.fromRGBO(28, 30, 33, 0.6);
  static Color lightBlack = HexColor.fromHex('#1C1E2199');
  static Color red = HexColor.fromHex('#FF0000');
  static Color gray = HexColor.fromHex('#E0E0E0');
  static Color grayDark = HexColor.fromHex('#989E93');
  static Color grayLight = HexColor.fromHex('#ECEFEB');
  static Color redLight = HexColor.fromHex('#FFF2F2');
  static Color redDark = HexColor.fromHex('#933939');
  static Color redExtra = HexColor.fromHex('#FE7575');
  static Color white = HexColor.fromHex('#FFFFFF');
  static Color whiteddd = HexColor.fromHex('#F0F2F5');
  static Color white101 = Color.fromRGBO(0, 0, 0, 0.04);
  static Color white10 = Color.fromRGBO(0, 0, 0, 0.05);
  static Color white20 = Color.fromRGBO(0, 0, 0, 0.08);
  static Color white30 = Color.fromRGBO(0, 0, 0, 0.12);
  static Color white75 = HexColor.fromHex('#bfbfbf');
  static Color greenDisable = HexColor.fromHex('#B0D0FF');
  static Color blueExtra = HexColor.fromHex('#A4A3FD');

  /// Bg = Background
  static Color bgForButton = HexColor.fromHex('#F5F5F5');
  static Color primaryLight = HexColor.fromHex('#E7F3FF');

  static Color grayText = HexColor.fromHex('#1C1E21');
  // static Color disabledText = HexColor.fromHex('#BCC0C4');
  static Color disabledText = HexColor.fromHex('#1C1E21');
  static Color lightGray = HexColor.fromHex('#D9D9D9');
  static Color blue = HexColor.fromHex('#1877F2');
  static Color yellowLight = HexColor.fromHex('#FFEDA4');
  static Color serachGray = HexColor.fromHex('#F0F2F5');
  static Color purpleText = HexColor.fromHex('#B983FF');

  static Color kPrimaryBlack = HexColor.fromHex('#F0F2F5');
  static Color kPrimaryBlackLight = HexColor.fromHex('#FFFFFF');
  static Color kLightGreen = HexColor.fromHex('#1877F2');
  static Color kGray = HexColor.fromHex('#EBEBEB').withOpacity(.1);

  static Color kTextGreen = HexColor.fromHex('#1877F2');
  static Color kDottedBlack = HexColor.fromHex('#BCC0C4');
  static Color kDottedGray = HexColor.fromHex('#D2D2D2');

  static Color bgStationDetail = HexColor.fromHex('#FFFFFF');

  static Color greenCard = HexColor.fromHex('#E7F3FF');

  //purple

  static Color purple = HexColor.fromHex('#B04DFF');

  static Color blackblur = HexColor.fromHex('#F0F2F5');

  static Color yellow = HexColor.fromHex('#F5C54A');
}

extension HexColor on Color {
  static Color fromHex(String hexColorString) {
    hexColorString = hexColorString.replaceAll('#', '');

    if (hexColorString.length == 6) {
      hexColorString =
      'FF$hexColorString';
    }
    return Color(int.parse(hexColorString, radix: 16));
  }
}
