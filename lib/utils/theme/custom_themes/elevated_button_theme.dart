import 'package:flutter/material.dart';

class IAMElevatedButtonTheme {
  IAMElevatedButtonTheme._();

  /// -- Light Theme
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: Colors.amber[400],
      disabledForegroundColor: Colors.grey[300],
      disabledBackgroundColor: Colors.grey[300],
      side: BorderSide(color: Colors.amber[300]!),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  /// -- Dark Theme
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: Colors.amber[200],
      disabledForegroundColor: Colors.grey[300],
      disabledBackgroundColor: Colors.grey[300],
      side: BorderSide(color: Colors.amber[200]!),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
