import 'package:flutter/material.dart';

/// Shared layout breakpoints for mobile → desktop web shells.
class IAMBreakpoints {
  IAMBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double wide = 1440;

  /// Max content width so product grids don't stretch endlessly on large monitors.
  static const double contentMaxWidth = 1200;

  /// Narrow form column (login / signup / checkout panels).
  static const double formMaxWidth = 440;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobile && w < desktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  /// Product grid columns that scale with the viewport.
  static int productGridCount(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= wide) return 5;
    if (w >= desktop) return 4;
    if (w >= tablet) return 3;
    return 2;
  }
}
