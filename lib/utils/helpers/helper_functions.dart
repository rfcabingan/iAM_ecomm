import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Utility class for helper functions used throughout the app.
class IAMHelperFunctions {
  // --------------------------------------------------
  // COLOR FUNCTIONS
  // --------------------------------------------------

  /// Returns a [Color] object based on the given string name.
  ///
  /// Example:
  /// ```dart
  /// THelperFunctions.getColor('blue'); // => Colors.blue
  /// ```
  static Color? getColor(String value) {
    if (value.trim().isEmpty) return null;

    switch (value.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'pink':
        return Colors.pink;
      case 'grey':
        return Colors.grey;
      case 'purple':
        return Colors.purple;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'brown':
        return Colors.brown;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'amber':
        return Colors.amber;
      case 'orange':
        return Colors.orange;
      default:
        return null;
    }
  }

  // --------------------------------------------------
  // UI / NAVIGATION FUNCTIONS
  // --------------------------------------------------

  /// Displays a [SnackBar] with the provided [message].
  static void showSnackBar(String message) {
    final context = Get.context;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Displays an alert dialog with a [title] and [message].
  static void showAlert(String title, String message) {
    final context = Get.context;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Navigates to a new screen using [MaterialPageRoute].
  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // --------------------------------------------------
  //  TEXT FUNCTIONS
  // --------------------------------------------------

  /// Truncates [text] to a maximum [maxLength] and appends '...' if needed.
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // --------------------------------------------------
  //  THEME / DEVICE INFO FUNCTIONS
  // --------------------------------------------------

  /// Returns true if the current theme is dark mode.
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Gets the current screen size.
  static Size screenSize() => MediaQuery.of(Get.context!).size;

  /// Gets the current screen height.
  static double screenHeight() => MediaQuery.of(Get.context!).size.height;

  /// Gets the current screen width.
  static double screenWidth() => MediaQuery.of(Get.context!).size.width;

  // --------------------------------------------------
  // LIST / DATE UTILITIES
  // --------------------------------------------------

  /// Formats a [DateTime] to a readable string using a custom format.
  ///
  /// Example:
  /// ```dart
  /// THelperFunctions.getFormattedDate(DateTime.now(), format: 'dd MMM yyyy');
  /// ```
  static String getFormattedDate(
    DateTime date, {
    String format = 'dd MMM yyyy',
  }) {
    return DateFormat(format).format(date);
  }

  /// Removes duplicate elements from a list.
  static List<T> removeDuplicates<T>(List<T> list) => list.toSet().toList();

  /// Wraps a list of widgets into rows with [rowSize] items each.
  static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
    final wrappedList = <Widget>[];

    for (var i = 0; i < widgets.length; i += rowSize) {
      final endIndex = (i + rowSize > widgets.length)
          ? widgets.length
          : i + rowSize;
      wrappedList.add(Row(children: widgets.sublist(i, endIndex)));
    }

    return wrappedList;
  }
}
