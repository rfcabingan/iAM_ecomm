import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/breakpoints.dart';

/// Shared gate for desktop-web layouts. Mobile (Android/iOS) always false.
class IAMPlatformLayout {
  IAMPlatformLayout._();

  /// True only in a browser at tablet+/desktop width.
  static bool isWebDesktop(BuildContext context) =>
      kIsWeb && IAMBreakpoints.isDesktop(context);

  /// True for any web build (including phone-width browser).
  static bool get isWeb => kIsWeb;
}
