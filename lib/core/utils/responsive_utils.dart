import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static double getMaxWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 800;
    } else if (isTablet(context)) {
      return 600;
    }
    return double.infinity;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(48);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(32);
    }
    return const EdgeInsets.all(24);
  }
}
