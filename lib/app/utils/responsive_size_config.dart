import 'package:flutter/material.dart';

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight =>
      MediaQuery.of(this).size.height -
      MediaQuery.of(this).padding.top -
      MediaQuery.of(this).padding.bottom;

  /// Calculate the horizontal size in pixels based on the provided pixel value (px).
  double horizontalSize(double px) {
    return (px * screenWidth) / ResponsiveHelper.figmaDesignWidth;
  }

  /// Calculate the vertical size in pixels based on the provided pixel value (px).
  double verticalSize(double px) {
    return (px * screenHeight) /
        (ResponsiveHelper.figmaDesignHeight -
            ResponsiveHelper.figmaDesignStatusBar);
  }

  /// Calculate the responsive size in pixels based on the provided pixel value (px).
  ///
  /// Adjusts the size based on the screen's orientation (landscape or portrait).
  double responsiveSize(double px) {
    return screenWidth < screenHeight ? horizontalSize(px) : verticalSize(px);
  }

  /// Calculate the font size in pixels based on the provided pixel value (px)
  double fontSize(double px) {
    return responsiveSize(px);
  }

  /// Create EdgeInsetsGeometry with specified padding values.
  ///
  /// Supports setting padding for individual sides or both horizontal and vertical at once.
  EdgeInsetsGeometry padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left != null
          ? horizontalSize(left)
          : (horizontal != null ? horizontalSize(horizontal) : 0),
      top: top != null
          ? verticalSize(top)
          : (vertical != null ? verticalSize(vertical) : 0),
      right: right != null
          ? horizontalSize(right)
          : (horizontal != null ? horizontalSize(horizontal) : 0),
      bottom: bottom != null
          ? verticalSize(bottom)
          : (vertical != null ? verticalSize(vertical) : 0),
    );
  }

  /// Create EdgeInsetsGeometry with specified margin values.
  ///
  /// Supports setting margin for individual sides or both horizontal and vertical at once.
  EdgeInsetsGeometry margin({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left != null
          ? horizontalSize(left)
          : (horizontal != null ? horizontalSize(horizontal) : 0),
      top: top != null
          ? verticalSize(top)
          : (vertical != null ? verticalSize(vertical) : 0),
      right: right != null
          ? horizontalSize(right)
          : (horizontal != null ? horizontalSize(horizontal) : 0),
      bottom: bottom != null
          ? verticalSize(bottom)
          : (vertical != null ? verticalSize(vertical) : 0),
    );
  }
}

class ResponsiveHelper {
  static const double figmaDesignWidth = 412;
  static const double figmaDesignHeight = 892;
  static const double figmaDesignStatusBar = 44;
}
