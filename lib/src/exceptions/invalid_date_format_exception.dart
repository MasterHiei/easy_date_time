/// Exception thrown when an invalid date string is provided for parsing.
///
/// The [parse()] method throws this when the input string doesn't match
/// any supported date format (ISO 8601, YYYY/MM/DD format, etc.).
///
/// **Solution**: Use [tryParse()] to safely handle potentially invalid dates:
///
/// ```dart
/// final dateStr = getUserInput();
/// final parsed = EasyDateTime.tryParse(dateStr);
/// if (parsed == null) {
///   print('Invalid date format');
/// }
/// ```
class InvalidDateFormatException implements FormatException {
  /// The input string that couldn't be parsed.
  @override
  final String source;

  /// The error message describing the parsing failure.
  @override
  final String message;

  /// The offset in the string where parsing failed (if available).
  @override
  final int? offset;

  /// Creates a new [InvalidDateFormatException].
  InvalidDateFormatException({
    required this.source,
    required this.message,
    this.offset,
  });

  @override
  String toString() {
    final offsetStr = offset != null ? ' at offset $offset' : '';

    return 'InvalidDateFormatException: $message in "$source"$offsetStr';
  }
}
