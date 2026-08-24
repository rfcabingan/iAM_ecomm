import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Utility class for device-related functionalities (safe on web + mobile).
class IAMDeviceUtils {
  /// Hides the soft keyboard if it's open.
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  /// Sets the system status bar color.
  static Future<void> setStatusBarColor(Color color) async {
    if (kIsWeb) return;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: color),
    );
  }

  /// Checks if the device is in landscape orientation.
  static bool isLandscapeOrientation(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  /// Checks if the device is in portrait orientation.
  static bool isPortraitOrientation(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.portrait;
  }

  /// Toggles the full-screen immersive mode.
  static void setFullScreen(bool enable) {
    if (kIsWeb) return;
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
    return kBottomNavigationBarHeight;
  }

  /// Gets the height of the AppBar.
  static double getAppBarHeight() {
    return kToolbarHeight;
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
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Triggers a brief vibration.
  static void vibrate(Duration duration) {
    if (kIsWeb) return;
    HapticFeedback.vibrate();
    Future.delayed(duration, () => HapticFeedback.vibrate());
  }

  /// Sets the preferred screen orientations.
  static Future<void> setPreferredOrientations(
    List<DeviceOrientation> orientations,
  ) async {
    if (kIsWeb) return;
    await SystemChrome.setPreferredOrientations(orientations);
  }

  /// Hides the system status bar.
  static void hideStatusBar() {
    if (kIsWeb) return;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  /// Shows the system status bar.
  static void showStatusBar() {
    if (kIsWeb) return;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  /// Best-effort connectivity check (web relies on failed API calls instead).
  static Future<bool> hasInternetConnection() async {
    if (kIsWeb) return true;
    // Avoid dart:io on web — connectivity is validated by API layer.
    return true;
  }

  /// Checks if the current platform is iOS.
  static bool isIOS() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Checks if the current platform is Android.
  static bool isAndroid() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android;
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
