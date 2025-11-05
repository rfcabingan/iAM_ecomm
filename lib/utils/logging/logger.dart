import 'package:logger/logger.dart';

/// Utility class for managing logs and logging levels using the 'logger' package.
class IAMLogger {
  // Static final instance of the Logger
  static final Logger _logger = Logger(
    // Setup PrettyPrinter for readable logs
    printer: PrettyPrinter(),
    // Customize the log levels based on your needs
    level: Level.debug,
  ); // Logger

  /// Log a message at the debug level.
  static void debug(String message) {
    _logger.d(message);
  }

  /// Log a message at the info level.
  static void info(String message) {
    _logger.i(message);
  }

  /// Log a message at the warning level.
  static void warning(String message) {
    _logger.w(message);
  }

  /// Log a message at the error level, including the error object and stack trace.
  static void error(String message, [dynamic error]) {
    _logger.e(message, error: error, stackTrace: StackTrace.current);
  }
}
