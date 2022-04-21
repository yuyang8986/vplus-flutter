import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vplus_merchant_app/styles/font.dart';

class ScreenHelper {
  static bool isLandScape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  static double getResponsiveTitleFontSize(BuildContext context) {
    return isLargeScreen(context)
        ? largeScreenTitleFontSize
        : phoneScreenTitleFontSize;
  }

  static double getResponsiveTextBodyFontSize(BuildContext context) {
    return isLargeScreen(context)
        ? largeScreenTextBodyFontSize
        : phoneScreenTextBodyFontSize;
  }

  static double getResponsiveTextBodySmallFontSize(BuildContext context) {
    return isLargeScreen(context)
        ? largeScreenTextBodySmallFontSize
        : phoneScreenTextBodySmallFontSize;
  }

  static double getResponsiveTextFieldFontSize(BuildContext context) {
    return isLargeScreen(context)
        ? largeScreenTextFieldFontSize
        : phoneScreenTextFieldFontSize;
  }

  static void lockOrientation(BuildContext context) {
    if (!isLargeScreen(context)) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }
}
