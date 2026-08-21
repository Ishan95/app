import 'package:flutter/material.dart';

class ColorManager {
  static Color kPrimary = HexColor.fromHex('#7FE62E');
  static Color kPrimaryDark = HexColor.fromHex('#3C6C1F');
  static Color kPrimaryExtra = HexColor.fromHex('#58AB16');
  static Color kPrimaryWarm = HexColor.fromHex('#ABE138');
  static Color kPrimaryLight = HexColor.fromHex('#DFFABD');
  static Color kSecondary = HexColor.fromHex('#B983FF');
  static Color kSecondaryOP = HexColor.fromHex('#B983FF').withOpacity(.12);

  static Color kNewSecondary = HexColor.fromHex('#4831D4');
  static Color kSecondaryLight = HexColor.fromHex('#E4FFD0');
  static Color kSecondaryGrad = HexColor.fromHex('#E7D5FF');
  static Color greenPrimary = HexColor.fromHex('#E2FFA5');
  static Color kfilterButtonColor = HexColor.fromHex('#4A4458');
  static Color kAleartTextColor = HexColor.fromHex('#0A84FF');
  static Color kAleartCancelTextColor = HexColor.fromHex('#FE7575');
  static Color kSubplanTextColor = HexColor.fromHex('#EBEBEB');
  static Color kCirculerFirstColor = HexColor.fromHex('##F5C54A');
  static Color kCirculerSecondColor = HexColor.fromHex('#8B46FB1F').withOpacity(0.12);

  static List<Color> gradientButtons = [
    HexColor.fromHex('#DFFABD'), //#454545 #424242
    HexColor.fromHex('#E0FFBB'),
    HexColor.fromHex('#C6EEB1'),
  ];

  static List<Color> gradientButtons2 = [
    HexColor.fromHex('#BDFF00'),
    HexColor.fromHex('#80CF32'),
    // HexColor.fromHex('#C6EEB1'),
  ];

  static List<Color> gradientButtons3 = [
    HexColor.fromHex('#E6FCE5'),
    // HexColor.fromHex('#E0FFBB'),
    HexColor.fromHex('#9BE462'),
  ];

  static List<Color> gradientButtonsPurple = [
    HexColor.fromHex('#D1ADFF'),
    HexColor.fromHex('#E7D5FF'),
  ];

  static List<Color> gradientBlueButtons = [
    HexColor.fromHex('#D1ADFF'),
    HexColor.fromHex('#E7D5FF'),
  ];

  static List<Color> gradientLightGreen = [
    HexColor.fromHex('#CFF0AD'),
    HexColor.fromHex('#A6E675'),
  ];

  static List<Color> gradientGreenDark = [
    HexColor.fromHex('#7FE62E').withOpacity(.80),
    HexColor.fromHex('#FFFFFF').withOpacity(.10),
  ];

  static List<Color> gradientBlackforBlur = [
    HexColor.fromHex('#161715F0'),
    HexColor.fromHex('#46464600'),
  ];

  static List<Color> gradientGray = [
    HexColor.fromHex('#E0E0E0'),
    HexColor.fromHex('#ECEFEB'),
  ];

  static List<Color> lightBlackGradient = [
    HexColor.fromHex('#454545'),
    HexColor.fromHex('#424242'),
  ];

  static List<Color> subPlanRemain = [
    HexColor.fromHex('#EEFF0000').withOpacity(0.1),
    HexColor.fromHex('#FFEA0000'),
    HexColor.fromHex('#FBFF00'),
  ];

  static Color black = HexColor.fromHex('#000000');
  static Color blackMedium = HexColor.fromHex('#0C1101');
  static Color blackTransparent60 = Color.fromRGBO(22, 23, 21, 0.6);
  static Color lightBlack = HexColor.fromHex('#00000099');
  static Color red = HexColor.fromHex('#FF0000');
  static Color gray = HexColor.fromHex('#E0E0E0');
  static Color grayDark = HexColor.fromHex('#989E93');
  static Color grayLight = HexColor.fromHex('#ECEFEB');
  static Color redLight = HexColor.fromHex('#FFF2F2');
  static Color redDark = HexColor.fromHex('#933939');
  static Color redExtra = HexColor.fromHex('#FE7575');
  static Color white = HexColor.fromHex('#FFFFFF');
  static Color whiteddd = HexColor.fromHex('#FFFF1A');
  static Color white101 = const Color(0x1AFFFFFF);
  static Color white10 = HexColor.fromHex('#FFFFFF').withOpacity(.10);
  static Color white20 = HexColor.fromHex('#FFFFFF').withOpacity(.20);
  static Color white30 = HexColor.fromHex('#FFFFFF').withOpacity(.30);
  static Color white75 = HexColor.fromHex('#bfbfbf');
  static Color greenDisable = HexColor.fromHex('#7EB86B');
  static Color blueExtra = HexColor.fromHex('#A4A3FD');

  /// Bg = Background
  static Color bgForButton = HexColor.fromHex('#F5F5F5');
  static Color primaryLight = HexColor.fromHex('#E9FFE6');

  static Color grayText = HexColor.fromHex('#7F847D');
  static Color disabledText = HexColor.fromHex('#BEC5B8');
  static Color lightGray = HexColor.fromHex('#D9D9D9');
  static Color blue = HexColor.fromHex('#007AFF');
  static Color yellowLight = HexColor.fromHex('#FFEDA4');
  static Color serachGray = HexColor.fromHex('#7676803D');
  static Color purpleText = HexColor.fromHex('#B983FF');

  static Color kPrimaryBlack = HexColor.fromHex('#161715');
  static Color kPrimaryBlackLight = HexColor.fromHex('#16171599');
  static Color kLightGreen = HexColor.fromHex('#BDFF00');
  static Color kGray = HexColor.fromHex('#EBEBEB').withOpacity(.1);

  static Color kTextGreen = HexColor.fromHex('#B3FF38');
  static Color kDottedBlack = HexColor.fromHex('#010101');
  static Color kDottedGray = HexColor.fromHex('#D2D2D2');

  static Color bgStationDetail = HexColor.fromHex('#161715');

  static Color greenCard = HexColor.fromHex('#74E62E47');

  //purple

  static Color purple = HexColor.fromHex('#B04DFF');

  static Color blackblur = HexColor.fromHex('#252525');

  static Color yellow = HexColor.fromHex('#F5C54A');
}

extension HexColor on Color {
  static Color fromHex(String hexColorString) {
    hexColorString = hexColorString.replaceAll('#', '');

    if (hexColorString.length == 6) {
      hexColorString =
          'FF$hexColorString'; // 8 char for the color code = 100% opacity.
    }
    return Color(int.parse(hexColorString, radix: 16));
  }
}
