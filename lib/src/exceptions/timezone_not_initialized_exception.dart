/// Exception thrown when timezone initialization is required but hasn't been performed.
///
/// This typically occurs when calling timezone-dependent operations before
/// calling [initializeTimeZone()] from the `timezone` package.
///
/// **Solution**: Call `initializeTimeZone()` at the start of your main() function:
///
/// ```dart
/// void main() {
///   initializeTimeZone(); // Required for timezone support
///   runApp(MyApp());
/// }
/// ```
class TimeZoneNotInitializedException implements Exception {
  /// The error message explaining why the exception was thrown.
  final String message;

  /// Creates a new [TimeZoneNotInitializedException].
  TimeZoneNotInitializedException(this.message);

  @override
  String toString() => 'TimeZoneNotInitializedException: $message';
}
