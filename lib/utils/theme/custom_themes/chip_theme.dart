import 'package:flutter/material.dart';

class IAMChipTheme {
  IAMChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: Colors.grey[200],
    labelStyle: const TextStyle(color: Colors.black),
    selectedColor: Colors.amber[200],
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: Colors.white,
  );

  static ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: Colors.grey[400],
    labelStyle: const TextStyle(color: Colors.white),
    selectedColor: Colors.amber[200],
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    checkmarkColor: Colors.white,
  );
}
