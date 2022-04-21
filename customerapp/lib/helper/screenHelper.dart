import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vplus/styles/font.dart';

class ScreenHelper {
  static bool isLandScape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  static int getResponsiveTitleFontSize(BuildContext context) {
    return isLargeScreen(context)
        ? largeScreenTitleFontSize
        : phoneScreenTitleFontSize;
  }

  static int getResponsiveTextBodyFontSize(BuildContext context) {
    return isLargeScreen(context)
        ? largeScreenTextBodyFontSize
        : phoneScreenTextBodyFontSize;
  }

  static int getResponsiveTextBodySmallFontSize(BuildContext context) {
    return isLargeScreen(context)
        ? largeScreenTextBodySmallFontSize
        : phoneScreenTextBodySmallFontSize;
  }

  static int getResponsiveTextFieldFontSize(BuildContext context) {
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
