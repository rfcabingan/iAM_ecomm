/// Utility class for form field validation.
class IAMValidator {
  /// Validates an email address.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Invalid email format.';
    }

    return null;
  }

  /// Validates a password with security rules.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter.';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter.';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number.';
    }

    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }

  /// Validates a Philippine phone number.
  ///
  /// Accepts:
  /// - `09XXXXXXXXX` (local format)
  /// - `+639XXXXXXXXX` (international format)
  /// Rejects anything else.
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required.';
    }

    // Trim spaces
    final trimmedValue = value.trim();

    // Philippine number patterns:
    // 09XXXXXXXXX → 11 digits starting with 09
    // +639XXXXXXXXX → 13 characters starting with +639
    final phLocalPattern = RegExp(r'^09\d{9}$');
    final phIntlPattern = RegExp(r'^\+639\d{9}$');

    if (!phLocalPattern.hasMatch(trimmedValue) &&
        !phIntlPattern.hasMatch(trimmedValue)) {
      return 'Invalid Philippine phone number format.';
    }

    return null;
  }

  /// Validates a required field.
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  /// Validates that two passwords match.
  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password.';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }

    return null;
  }
}
