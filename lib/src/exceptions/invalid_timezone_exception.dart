/// Exception thrown when an invalid timezone location is provided.
///
/// This occurs when trying to use a timezone identifier that doesn't exist
/// in the IANA timezone database.
///
/// **Solution**: Use [getLocation()] with a valid IANA timezone identifier:
///
/// ```dart
/// // Valid
/// final tokyo = getLocation('Asia/Tokyo');
///
/// // Invalid - will throw
/// final invalid = getLocation('Invalid/Timezone');
/// ```
class InvalidTimeZoneException implements Exception {
  /// The invalid timezone identifier that was provided.
  final String timeZoneId;

  /// The error message explaining why the timezone is invalid.
  final String message;

  /// Creates a new [InvalidTimeZoneException].
  InvalidTimeZoneException({required this.timeZoneId, required this.message});

  @override
  String toString() => 'InvalidTimeZoneException: "$timeZoneId" - $message';
}
