import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // <-- ADDED import for Material-based classes
import 'package:flutter/services.dart';
import 'package:get/get.dart'; // Required for Get.context
import 'package:url_launcher/url_launcher_string.dart'; // Required for launchUrlString

// Utility class for device-related functionalities.
class TDeviceUtils {
  /// Hides the soft keyboard if it's open.
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// Sets the system status bar color.
  static Future<void> setStatusBarColor(Color color) async {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: color),
    );
  }

  /// Checks if the device is in landscape orientation.
  static bool isLandscapeOrientation(BuildContext context) {
    final viewInsets = View.of(context).viewInsets;
    return viewInsets.bottom == 0;
  }

  /// Checks if the device is in portrait orientation.
  static bool isPortraitOrientation(BuildContext context) {
    final viewInsets = View.of(context).viewInsets;
    return viewInsets.bottom != 0;
  }

  /// Toggles the full-screen immersive mode.
  static void setFullScreen(bool enable) {
    SystemChrome.setEnabledSystemUIMode(
      enable ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  /// Gets the screen height in logical pixels.
  static double getScreenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  /// Gets the screen width in logical pixels.
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Gets the device pixel ratio.
  static double getPixelRatio() {
    return MediaQuery.of(Get.context!).devicePixelRatio;
  }

  /// Gets the height of the system status bar.
  static double getStatusBarHeight() {
    return MediaQuery.of(Get.context!).padding.top;
  }

  /// Gets the height of the bottom navigation bar.
  static double getBottomNavigationBarHeight() {
    return kBottomNavigationBarHeight; // Standard Flutter constant
  }

  /// Gets the height of the AppBar.
  static double getAppBarHeight() {
    return kToolbarHeight; // Standard Flutter constant
  }

  /// Gets the height of the keyboard.
  static double getKeyboardHeight() {
    final viewInsets = MediaQuery.of(Get.context!).viewInsets;
    return viewInsets.bottom;
  }

  /// Checks if the keyboard is visible.
  static Future<bool> isKeyboardVisible() async {
    final viewInsets = View.of(Get.context!).viewInsets;
    return viewInsets.bottom > 0;
  }

  /// Checks if the device is a physical device (not a simulator/emulator).
  static Future<bool> isPhysicalDevice() async {
    // Uses defaultTargetPlatform from flutter/foundation.dart
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Triggers a brief vibration.
  static void vibrate(Duration duration) {
    HapticFeedback.vibrate();
    Future.delayed(duration, () => HapticFeedback.vibrate());
  }

  /// Sets the preferred screen orientations.
  static Future<void> setPreferredOrientations(
    List<DeviceOrientation> orientations,
  ) async {
    await SystemChrome.setPreferredOrientations(orientations);
  }

  /// Hides the system status bar.
  static void hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  /// Shows the system status bar.
  static void showStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  /// Checks for an active internet connection.
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Checks if the current platform is iOS.
  static bool isIOS() {
    return Platform.isIOS;
  }

  /// Checks if the current platform is Android.
  static bool isAndroid() {
    return Platform.isAndroid;
  }

  /// Launches a URL using the url_launcher package.
  static void launchUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
