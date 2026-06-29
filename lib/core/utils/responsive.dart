import 'package:flutter/widgets.dart';

class Responsive {
  const Responsive._();

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 760;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 760 && width < 1100;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1100;

  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1400) return 1180;
    if (width >= 900) return 1040;
    return double.infinity;
  }
}
