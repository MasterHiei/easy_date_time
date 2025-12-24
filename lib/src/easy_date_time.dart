import 'package:timezone/timezone.dart';

import 'date_time_unit.dart';
import 'easy_date_time_config.dart' as config;
import 'easy_date_time_init.dart' as init;
import 'exceptions/exceptions.dart';

part 'easy_date_time_formatting.dart';
part 'easy_date_time_parsing.dart';
part 'easy_date_time_utilities.dart';

/// A timezone-aware DateTime implementation.
///
/// [EasyDateTime] implements Dart's [DateTime] interface, extending it with
/// full IANA timezone support. Unlike [DateTime] which only supports UTC and
/// local time, [EasyDateTime] can represent any IANA timezone while remaining
/// fully compatible with all APIs that accept [DateTime].
///
/// **Key characteristics:**
/// - Implements [DateTime] — can be used anywhere DateTime is expected
/// - Supports any IANA timezone (Asia/Tokyo, America/New_York, etc.)
/// - Preserves original time values when parsing (no implicit UTC conversion)
/// - Immutable and safe to pass between isolates
///
/// ## Creating instances
///
/// ```dart
/// // Current time (uses global default or local time)
/// final now = EasyDateTime.now();
///
/// // Current time in a specific timezone
/// final shanghai = EasyDateTime.now(location: TimeZones.shanghai);
///
/// // Specific date/time (uses global default or local time)
/// final meeting = EasyDateTime(2025, 12, 1, 14, 30);
///
/// // Specific date/time in a timezone
/// final chinaTime = EasyDateTime(2025, 12, 1, 14, 30,
///   location: TimeZones.shanghai,
/// );
/// ```
///
/// ## Global timezone setting
///
/// ```dart
/// // Set global default timezone to China
/// EasyDateTime.setDefaultLocation(TimeZones.shanghai);
///
/// // All operations now default to China time (UTC+8)
/// final now = EasyDateTime.now(); // Shanghai time
/// ```
///
/// ## Timezone conversion
///
/// ```dart
/// final shanghai = EasyDateTime.now(location: TimeZones.shanghai);
/// final utc = shanghai.toUtc();
/// final newYork = shanghai.inLocation(TimeZones.newYork);
/// // Shanghai 20:00 = UTC 12:00 = New York 07:00
/// ```
///
/// ## Arithmetic operations
///
/// ```dart
/// final now = EasyDateTime.now();
/// final tomorrow = now + Duration(days: 1);
/// final lastWeek = now - Duration(days: 7);
/// final diff = tomorrow.difference(now); // Duration(days: 1)
/// ```
/// {@template easyDateTime}
/// This class is immutable and can be safely used as a value object.
/// {@endtemplate}
class EasyDateTime implements DateTime {
  /// The underlying TZDateTime from the timezone package.
  final TZDateTime _tzDateTime;

  /// Validates that [isUtc] and [location] are mutually exclusive.
  ///
  /// Throws [ArgumentError] if both are specified.
  static void _validateUtcLocation(bool isUtc, Location? location) {
    if (isUtc && location != null) {
      throw ArgumentError.value(
        location,
        'location',
        'Cannot specify location when isUtc is true',
      );
    }
  }

  /// Creates an [EasyDateTime] from the given components.
  ///
  /// If [location] is not provided, uses the global default timezone
  /// (set via [setDefaultLocation]) or the system's local timezone.
  ///
  /// ## DST Boundary Behavior
  ///
  /// - **Spring Forward (Gap):** If you create a time during the "skipped hour"
  ///   (e.g., 2:30 AM when clocks jump from 2:00→3:00 AM), the time is
  ///   automatically adjusted forward to the next valid time.
  /// - **Fall Back (Overlap):** If you create a time during the "repeated hour"
  ///   (e.g., 1:30 AM that occurs twice), the DST time (before fall back) is used.
  ///
  /// **Throws [TimeZoneNotInitializedException]** if [EasyDateTime.initializeTimeZone]
  /// has not been called at app startup.
  ///
  /// ```dart
  /// // Uses global default or local timezone
  /// final dt = EasyDateTime(2025, 12, 25, 10, 30);
  ///
  /// // Explicitly specify timezone
  /// final dt = EasyDateTime(2025, 12, 25, 10, 30,
  ///   location: getLocation('Asia/Shanghai'),
  /// );
  /// ```
  EasyDateTime(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
    Location? location,
  ]) : _tzDateTime = TZDateTime(
          location ?? config.effectiveDefaultLocation,
          year,
          month,
          day,
          hour,
          minute,
          second,
          millisecond,
          microsecond,
        );

  /// Creates an [EasyDateTime] from an existing [TZDateTime].
  EasyDateTime._(this._tzDateTime);

  /// Creates an [EasyDateTime] representing the current time.
  ///
  /// If [location] is not provided, uses the global default timezone
  /// (set via [setDefaultLocation]) or the system's local timezone.
  ///
  /// **Important**: Call [initializeTimeZone] before using this method
  /// if you need proper timezone support.
  ///
  /// **Throws [TimeZoneNotInitializedException]** if [EasyDateTime.initializeTimeZone]
  /// has not been called at app startup.
  ///
  /// ```dart
  /// // Uses global default or local timezone
  /// final now = EasyDateTime.now();
  ///
  /// // Explicitly specify timezone
  /// final nowInTokyo = EasyDateTime.now(location: getLocation('Asia/Tokyo'));
  /// ```
  factory EasyDateTime.now({Location? location}) {
    return EasyDateTime._(
        TZDateTime.now(location ?? config.effectiveDefaultLocation));
  }

  /// Creates a UTC [EasyDateTime] representing the current moment.
  ///
  /// This is equivalent to `EasyDateTime.now(location: TimeZones.utc)`.
  ///
  /// Unlike [now] which uses the global default timezone, this method
  /// always returns UTC time. This is useful for timestamps that should
  /// be timezone-agnostic.
  ///
  /// This method provides equivalent functionality to [DateTime.timestamp].
  ///
  /// ```dart
  /// final utcNow = EasyDateTime.timestamp();
  /// print(utcNow.locationName); // 'UTC'
  /// print(utcNow.timeZoneOffset); // Duration.zero
  /// ```
  factory EasyDateTime.timestamp() {
    return EasyDateTime._(TZDateTime.now(getLocation('UTC')));
  }

  /// Creates an [EasyDateTime] in UTC from the given components.
  ///
  /// ```dart
  /// final utc = EasyDateTime.utc(2025, 12, 25, 10, 30);
  /// ```
  factory EasyDateTime.utc(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  ]) {
    return EasyDateTime._(TZDateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    ));
  }

  /// Creates an [EasyDateTime] from a standard [DateTime].
  ///
  /// The [dateTime] is interpreted as a moment in time, and the resulting
  /// [EasyDateTime] represents that same moment in the specified [location].
  ///
  /// If [location] is not provided, uses the global default or local timezone.
  ///
  /// ```dart
  /// final dt = DateTime.utc(2025, 12, 25, 10, 0);
  /// final tokyo = EasyDateTime.fromDateTime(dt,
  ///   location: getLocation('Asia/Tokyo'),
  /// );
  /// print(tokyo.hour); // 19 (UTC+9)
  /// ```
  factory EasyDateTime.fromDateTime(DateTime dateTime, {Location? location}) {
    return EasyDateTime._(
      TZDateTime.from(dateTime, location ?? config.effectiveDefaultLocation),
    );
  }

  /// Creates an [EasyDateTime] from milliseconds since Unix epoch.
  ///
  /// The [milliseconds] value is interpreted as the number of milliseconds
  /// since January 1, 1970 00:00:00 UTC (Unix epoch).
  ///
  /// ## Parameters
  ///
  /// - [location]: The timezone to display the result in. If not provided,
  ///   uses the global default (set via [setDefaultLocation]) or local timezone.
  /// - [isUtc]: If `true`, returns a UTC datetime. This is provided for
  ///   compatibility with [DateTime.fromMillisecondsSinceEpoch].
  ///
  /// **Note**: [isUtc] and [location] are mutually exclusive. Specifying both
  /// throws an [ArgumentError].
  ///
  /// ## Examples
  ///
  /// ```dart
  /// // Basic usage (uses default/local timezone)
  /// final dt = EasyDateTime.fromMillisecondsSinceEpoch(1735689600000);
  ///
  /// // With explicit UTC (DateTime compatible)
  /// final utc = EasyDateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  ///
  /// // With explicit timezone
  /// final tokyo = EasyDateTime.fromMillisecondsSinceEpoch(
  ///   ms,
  ///   location: TimeZones.tokyo,
  /// );
  /// ```
  factory EasyDateTime.fromMillisecondsSinceEpoch(
    int milliseconds, {
    Location? location,
    bool isUtc = false,
  }) {
    _validateUtcLocation(isUtc, location);
    if (isUtc) {
      return EasyDateTime._(
        TZDateTime.fromMillisecondsSinceEpoch(
          getLocation('UTC'),
          milliseconds,
        ),
      );
    }

    return EasyDateTime._(
      TZDateTime.fromMillisecondsSinceEpoch(
        location ?? config.effectiveDefaultLocation,
        milliseconds,
      ),
    );
  }

  /// Creates an [EasyDateTime] from seconds since Unix epoch.
  ///
  /// This is useful for parsing Unix timestamps from backend APIs that return
  /// seconds (common in Python, Go, Rust, and Unix-based systems).
  ///
  /// ## Parameters
  ///
  /// - [location]: The timezone to display the result in. If not provided,
  ///   uses the global default (set via [setDefaultLocation]) or local timezone.
  /// - [isUtc]: If `true`, returns a UTC datetime. This is provided for
  ///   compatibility with [DateTime.fromMillisecondsSinceEpoch].
  ///
  /// **Note**: [isUtc] and [location] are mutually exclusive. Specifying both
  /// throws an [ArgumentError].
  ///
  /// ## Examples
  ///
  /// ```dart
  /// // Basic usage (uses default/local timezone)
  /// final dt = EasyDateTime.fromSecondsSinceEpoch(1733644200);
  ///
  /// // With explicit UTC
  /// final utc = EasyDateTime.fromSecondsSinceEpoch(1733644200, isUtc: true);
  ///
  /// // With explicit timezone
  /// final tokyo = EasyDateTime.fromSecondsSinceEpoch(
  ///   1733644200,
  ///   location: TimeZones.tokyo,
  /// );
  /// ```
  factory EasyDateTime.fromSecondsSinceEpoch(
    int seconds, {
    Location? location,
    bool isUtc = false,
  }) {
    _validateUtcLocation(isUtc, location);
    if (isUtc) {
      return EasyDateTime._(
        TZDateTime.fromMillisecondsSinceEpoch(
          getLocation('UTC'),
          seconds * 1000,
        ),
      );
    }

    return EasyDateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      location: location,
    );
  }

  /// Creates an [EasyDateTime] from microseconds since Unix epoch.
  ///
  /// ## Parameters
  ///
  /// - [location]: The timezone to display the result in. If not provided,
  ///   uses the global default (set via [setDefaultLocation]) or local timezone.
  /// - [isUtc]: If `true`, returns a UTC datetime. This is provided for
  ///   compatibility with [DateTime.fromMicrosecondsSinceEpoch].
  ///
  /// **Note**: [isUtc] and [location] are mutually exclusive. Specifying both
  /// throws an [ArgumentError].
  ///
  /// ## Examples
  ///
  /// ```dart
  /// // Basic usage (uses default/local timezone)
  /// final dt = EasyDateTime.fromMicrosecondsSinceEpoch(1733644200000000);
  ///
  /// // With explicit UTC
  /// final utc = EasyDateTime.fromMicrosecondsSinceEpoch(
  ///   1733644200000000,
  ///   isUtc: true,
  /// );
  ///
  /// // With explicit timezone
  /// final tokyo = EasyDateTime.fromMicrosecondsSinceEpoch(
  ///   1733644200000000,
  ///   location: TimeZones.tokyo,
  /// );
  /// ```
  factory EasyDateTime.fromMicrosecondsSinceEpoch(
    int microseconds, {
    Location? location,
    bool isUtc = false,
  }) {
    _validateUtcLocation(isUtc, location);
    if (isUtc) {
      return EasyDateTime._(
        TZDateTime.fromMicrosecondsSinceEpoch(
          getLocation('UTC'),
          microseconds,
        ),
      );
    }

    return EasyDateTime._(
      TZDateTime.fromMicrosecondsSinceEpoch(
        location ?? config.effectiveDefaultLocation,
        microseconds,
      ),
    );
  }

  /// Parses an ISO 8601 formatted string and creates an [EasyDateTime].
  ///
  /// ## Time Preservation Principle
  ///
  /// This method **preserves the original time values** from the input string.
  /// If you parse `"10:30:00+08:00"`, you get `hour=10`, not `hour=2` (UTC).
  ///
  /// - Strings with timezone offset (e.g., `+08:00`): A matching IANA timezone
  ///   is found and the original time values are preserved.
  /// - Strings ending with `Z`: Treated as UTC, time values preserved.
  /// - Strings without timezone: Uses the global default timezone.
  ///
  /// ## Supported Formats
  ///
  /// - `2025-12-01T10:30:00+08:00` (with offset → hour=10)
  /// - `2025-12-01T10:30:00Z` (UTC → hour=10)
  /// - `2025-12-01T10:30:00` (uses default timezone)
  /// - `2025-12-01` (date only, time=00:00:00)
  ///
  /// ## Examples
  ///
  /// ```dart
  /// // Time values are preserved
  /// final dt = EasyDateTime.parse('2025-12-01T10:30:00+08:00');
  /// print(dt.hour); // 10 (not 2!)
  ///
  /// final inNY = EasyDateTime.parse(
  ///   '2025-12-01T10:30:00Z',
  ///   location: getLocation('America/New_York'),
  /// );
  /// print(inNY.hour); // 5 (10:00 UTC → 05:00 NY)
  /// ```
  ///
  /// **Throws [TimeZoneNotInitializedException]** if [EasyDateTime.initializeTimeZone]
  /// has not been called at app startup.
  ///
  /// See also:
  /// - [tryParse] for safe parsing of user input.
  factory EasyDateTime.parse(String dateTimeString, {Location? location}) {
    final trimmed = dateTimeString.trim();

    try {
      // First, use DateTime.parse for validation and basic parsing
      final dt = DateTime.parse(trimmed);

      // If location is explicitly provided, convert to that timezone
      if (location != null) {
        return EasyDateTime.fromDateTime(dt.toUtc(), location: location);
      }

      // Extract offset from string to determine how to handle it
      final offsetInfo = _extractTimezoneOffset(trimmed);

      if (offsetInfo != null) {
        // String has explicit offset - preserve original time values
        final originalTime = _extractOriginalTimeComponents(trimmed);
        if (originalTime != null) {
          // Find matching IANA timezone for this offset
          final matchingLocation = _findLocationForOffset(offsetInfo);

          if (matchingLocation != null) {
            return EasyDateTime._(TZDateTime(
              matchingLocation,
              originalTime.year,
              originalTime.month,
              originalTime.day,
              originalTime.hour,
              originalTime.minute,
              originalTime.second,
              originalTime.millisecond,
              originalTime.microsecond,
            ));
          }

          // No matching timezone found - throw exception
          // This indicates invalid or corrupted data with a non-standard offset
          final offsetStr = _formatOffset(offsetInfo);
          throw InvalidTimeZoneException(
            timeZoneId: offsetStr,
            message: 'No IANA timezone found for offset $offsetStr. '
                'Valid timezone offsets are defined in the IANA database.',
          );
        }
      }

      // UTC indicator (Z)
      if (trimmed.toUpperCase().endsWith('Z')) {
        return EasyDateTime._(TZDateTime.utc(
          dt.year,
          dt.month,
          dt.day,
          dt.hour,
          dt.minute,
          dt.second,
          dt.millisecond,
          dt.microsecond,
        ));
      }

      // No timezone indicator - use effective default location with original values
      return EasyDateTime._(TZDateTime(
        config.effectiveDefaultLocation,
        dt.year,
        dt.month,
        dt.day,
        dt.hour,
        dt.minute,
        dt.second,
        dt.millisecond,
        dt.microsecond,
      ));
    } on FormatException catch (e) {
      throw InvalidDateFormatException(
        source: dateTimeString,
        message: e.message,
        offset: e.offset,
      );
    }
  }

  /// Tries to parse a date/time string, returning `null` if parsing fails.
  ///
  /// This method first attempts ISO 8601 parsing. If that fails, it tries
  /// common alternative formats.
  ///
  /// ## Supported Formats
  ///
  /// **ISO 8601 (primary):**
  /// - `2025-12-01T10:30:00Z`
  /// - `2025-12-01T10:30:00+09:00`
  /// - `2025-12-01 10:30:00`
  /// - `2025-12-01`
  ///
  /// **Common alternatives (fallback):**
  /// - `2025/12/01 10:30:00` (slash separator)
  /// - `2025/12/01` (slash separator, date only)
  ///
  /// ## Examples
  ///
  /// ```dart
  /// // Returns EasyDateTime for valid input
  /// final dt = EasyDateTime.tryParse('2025-12-01T10:30:00Z');
  ///
  /// // Returns null for invalid input
  /// final invalid = EasyDateTime.tryParse('not-a-date'); // null
  ///
  /// // Handles common formats
  /// final slashFormat = EasyDateTime.tryParse('2025/12/01 10:30:00');
  /// ```
  static EasyDateTime? tryParse(String dateTimeString, {Location? location}) {
    // Trim whitespace
    final input = dateTimeString.trim();
    if (input.isEmpty) {
      return null;
    }

    // Try ISO 8601 first (most common and unambiguous)
    try {
      return EasyDateTime.parse(input, location: location);
    } catch (_) {
      // Continue to fallback formats
    }

    // Try common alternative formats
    final normalized = _tryNormalizeFormat(input);
    if (normalized != null) {
      try {
        return EasyDateTime.parse(normalized, location: location);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  // ============================================================
  // Properties
  // ============================================================

  /// The year component.
  @override
  int get year => _tzDateTime.year;

  /// The month component (1-12).
  @override
  int get month => _tzDateTime.month;

  /// The day of the month component (1-31).
  @override
  int get day => _tzDateTime.day;

  /// The hour component (0-23).
  @override
  int get hour => _tzDateTime.hour;

  /// The minute component (0-59).
  @override
  int get minute => _tzDateTime.minute;

  /// The second component (0-59).
  @override
  int get second => _tzDateTime.second;

  /// The millisecond component (0-999).
  @override
  int get millisecond => _tzDateTime.millisecond;

  /// The microsecond component (0-999).
  @override
  int get microsecond => _tzDateTime.microsecond;

  /// The day of the week (1 = Monday, 7 = Sunday).
  @override
  int get weekday => _tzDateTime.weekday;

  /// The timezone [Location] of this datetime.
  Location get location => _tzDateTime.location;

  /// The name of the timezone (e.g., 'Asia/Tokyo').
  String get locationName => _tzDateTime.location.name;

  /// Whether this datetime is in UTC.
  @override
  bool get isUtc => _tzDateTime.isUtc;

  /// The timezone offset from UTC.
  @override
  Duration get timeZoneOffset => _tzDateTime.timeZoneOffset;

  /// The timezone name abbreviation (e.g., 'JST', 'EST').
  @override
  String get timeZoneName => _tzDateTime.timeZoneName;

  /// Milliseconds since Unix epoch (January 1, 1970 UTC).
  @override
  int get millisecondsSinceEpoch => _tzDateTime.millisecondsSinceEpoch;

  /// Microseconds since Unix epoch (January 1, 1970 UTC).
  @override
  int get microsecondsSinceEpoch => _tzDateTime.microsecondsSinceEpoch;

  // ============================================================
  // Timezone Conversion
  // ============================================================

  /// Returns this datetime converted to the specified [location].
  ///
  /// ```dart
  /// final tokyo = EasyDateTime.now(location: getLocation('Asia/Tokyo'));
  /// final newYork = tokyo.inLocation(getLocation('America/New_York'));
  /// ```
  EasyDateTime inLocation(Location location) {
    return EasyDateTime._(TZDateTime.from(_tzDateTime, location));
  }

  /// Returns this datetime converted to UTC.
  ///
  /// This is consistent with [DateTime.toUtc].
  @override
  EasyDateTime toUtc() {
    return EasyDateTime._(
      TZDateTime.from(_tzDateTime.toUtc(), getLocation('UTC')),
    );
  }

  /// Returns this datetime converted to the system's local timezone.
  ///
  /// This is consistent with [DateTime.toLocal].
  @override
  EasyDateTime toLocal() {
    return EasyDateTime._(TZDateTime.from(_tzDateTime.toLocal(), local));
  }

  /// Converts to a standard [DateTime].
  DateTime toDateTime() => _tzDateTime;

  // ============================================================
  // Arithmetic Operations
  // ============================================================

  /// Returns a new [EasyDateTime] with the [duration] added.
  @override
  EasyDateTime add(Duration duration) {
    return EasyDateTime._(_tzDateTime.add(duration));
  }

  /// Returns a new [EasyDateTime] with the [duration] subtracted.
  @override
  EasyDateTime subtract(Duration duration) {
    return EasyDateTime._(_tzDateTime.subtract(duration));
  }

  /// Returns the [Duration] between this and [other].
  @override
  Duration difference(DateTime other) {
    return _tzDateTime.difference(other);
  }

  // ============================================================
  // Operators
  // ============================================================

  /// Adds [duration] to this datetime.
  ///
  /// ```dart
  /// final tomorrow = now + Duration(days: 1);
  /// ```
  EasyDateTime operator +(Duration duration) => add(duration);

  /// Subtracts [duration] from this datetime.
  ///
  /// ```dart
  /// final yesterday = now - Duration(days: 1);
  /// ```
  EasyDateTime operator -(Duration duration) => subtract(duration);

  /// Returns `true` if this is before [other].
  bool operator <(DateTime other) =>
      microsecondsSinceEpoch < other.microsecondsSinceEpoch;

  /// Returns `true` if this is after [other].
  bool operator >(DateTime other) =>
      microsecondsSinceEpoch > other.microsecondsSinceEpoch;

  /// Returns `true` if this is before or at the same moment as [other].
  bool operator <=(DateTime other) =>
      microsecondsSinceEpoch <= other.microsecondsSinceEpoch;

  /// Returns `true` if this is after or at the same moment as [other].
  bool operator >=(DateTime other) =>
      microsecondsSinceEpoch >= other.microsecondsSinceEpoch;

  // ============================================================
  // Comparison
  // ============================================================

  /// Returns `true` if this is before [other].
  @override
  bool isBefore(DateTime other) =>
      microsecondsSinceEpoch < other.microsecondsSinceEpoch;

  /// Returns `true` if this is after [other].
  @override
  bool isAfter(DateTime other) =>
      microsecondsSinceEpoch > other.microsecondsSinceEpoch;

  /// Returns `true` if this and [other] represent the same moment in time.
  ///
  /// Two [EasyDateTime]s can be at the same moment even if they are in
  /// different timezones.
  ///
  /// This is consistent with [DateTime.isAtSameMomentAs].
  @override
  bool isAtSameMomentAs(DateTime other) =>
      microsecondsSinceEpoch == other.microsecondsSinceEpoch;

  @override
  int compareTo(DateTime other) {
    return microsecondsSinceEpoch.compareTo(other.microsecondsSinceEpoch);
  }

  // ============================================================
  // Formatting
  // ============================================================

  /// Returns an ISO 8601 string representation.
  ///
  /// ```dart
  /// print(dt.toIso8601String()); // '2025-12-01T10:30:00.000+0900'
  /// ```
  @override
  String toIso8601String() => _tzDateTime.toIso8601String();

  @override
  String toString() => _tzDateTime.toString();

  // ============================================================
  // Parsing from ISO 8601
  // ============================================================

  /// Creates an [EasyDateTime] from an ISO 8601 formatted string.
  ///
  /// This is equivalent to [parse] but with a more explicit name.
  ///
  /// ```dart
  /// final dt = EasyDateTime.fromIso8601String('2025-12-01T10:30:00+0900');
  /// ```
  factory EasyDateTime.fromIso8601String(String dateTimeString) {
    return EasyDateTime.parse(dateTimeString);
  }

  // ============================================================
  // Equality
  // ============================================================

  /// Returns `true` if [other] represents the same moment and timezone type.
  ///
  /// This is consistent with [DateTime.==] which compares both the moment
  /// in time and the timezone classification (UTC vs non-UTC).
  ///
  /// ```dart
  /// final utc = EasyDateTime.utc(2025, 1, 1, 0, 0);
  /// final local = EasyDateTime.parse('2025-01-01T08:00:00+08:00');
  ///
  /// utc == local;                  // false (different timezone type)
  /// utc.isAtSameMomentAs(local);   // true (same absolute instant)
  /// ```
  ///
  /// Use [isAtSameMomentAs] to compare absolute instants regardless of timezone.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // we can compare with both EasyDateTime specifically and then general DateTime
    // * for now the code is identical and we compare both microsecondsSinceEpoch and isUtc
    if (other is EasyDateTime) {
      return microsecondsSinceEpoch == other.microsecondsSinceEpoch &&
          isUtc == other.isUtc;
    }

    return other is DateTime &&
        microsecondsSinceEpoch == other.microsecondsSinceEpoch &&
        isUtc == other.isUtc;
  }
  
  /// The hash code for this [EasyDateTime].
  ///
  /// Two [EasyDateTime] objects that are [==] have the same hash code.
  @override
  int get hashCode => Object.hash(microsecondsSinceEpoch, isUtc);

  // ============================================================
  // Utility Methods
  // ============================================================

  /// Creates a copy of this [EasyDateTime] with the specified fields replaced.
  ///
  /// **Note:** This method follows Dart's [DateTime] overflow behavior.
  /// If the resulting date is invalid (e.g., February 31), it will overflow
  /// to the next valid date.
  ///
  /// ```dart
  /// final jan31 = EasyDateTime.utc(2025, 1, 31);
  /// final feb = jan31.copyWith(month: 2);
  /// print(feb);  // 2025-03-03 (Feb 31 overflows to Mar 3)
  /// ```
  ///
  /// For month/year changes that should clamp to valid dates, use
  /// [copyWithClamped] instead.
  EasyDateTime copyWith({
    Location? location,
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return EasyDateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
      location ?? this.location,
    );
  }

  /// Creates a copy with the day clamped to the valid range for the target month.
  ///
  /// Unlike [copyWith], this method ensures the resulting date is always valid
  /// by clamping the day to the last day of the target month if necessary.
  ///
  /// ```dart
  /// final jan31 = EasyDateTime.utc(2025, 1, 31);
  ///
  /// // copyWith overflows
  /// print(jan31.copyWith(month: 2));        // 2025-03-03
  ///
  /// // copyWithClamped clamps to month end
  /// print(jan31.copyWithClamped(month: 2)); // 2025-02-28
  /// print(jan31.copyWithClamped(month: 4)); // 2025-04-30
  /// ```
  ///
  /// This is useful for month/year arithmetic where you want to stay within
  /// the target month:
  ///
  /// ```dart
  /// final date = EasyDateTime.utc(2025, 1, 31);
  /// final nextMonth = date.copyWithClamped(month: date.month + 1);
  /// print(nextMonth);  // 2025-02-28 (not March!)
  /// ```
  EasyDateTime copyWithClamped({
    Location? location,
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    final targetYear = year ?? this.year;
    final targetMonth = month ?? this.month;
    final targetDay = day ?? this.day;

    // Calculate the last day of the target month
    final lastDayOfMonth = DateTime(targetYear, targetMonth + 1, 0).day;

    // Clamp the day to valid range
    final clampedDay = targetDay > lastDayOfMonth ? lastDayOfMonth : targetDay;

    return EasyDateTime(
      targetYear,
      targetMonth,
      clampedDay,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
      location ?? this.location,
    );
  }

  /// Returns a new [EasyDateTime] set to the start of the specified [unit].
  ///
  /// ```dart
  /// final dt = EasyDateTime(2025, 6, 15, 14, 30, 45);
  ///
  /// dt.startOf(DateTimeUnit.day);   // 2025-06-15 00:00:00
  /// dt.startOf(DateTimeUnit.month); // 2025-06-01 00:00:00
  /// dt.startOf(DateTimeUnit.year);  // 2025-01-01 00:00:00
  /// ```
  EasyDateTime startOf(DateTimeUnit unit) {
    return switch (unit) {
      DateTimeUnit.year => EasyDateTime(year, 1, 1, 0, 0, 0, 0, 0, location),
      DateTimeUnit.month =>
        EasyDateTime(year, month, 1, 0, 0, 0, 0, 0, location),
      DateTimeUnit.week => _startOfWeek(),
      DateTimeUnit.day =>
        EasyDateTime(year, month, day, 0, 0, 0, 0, 0, location),
      DateTimeUnit.hour =>
        EasyDateTime(year, month, day, hour, 0, 0, 0, 0, location),
      DateTimeUnit.minute =>
        EasyDateTime(year, month, day, hour, minute, 0, 0, 0, location),
      DateTimeUnit.second =>
        EasyDateTime(year, month, day, hour, minute, second, 0, 0, location),
    };
  }

  /// Returns a new [EasyDateTime] set to the end of the specified [unit].
  ///
  /// ```dart
  /// final dt = EasyDateTime(2025, 6, 15, 14, 30, 45);
  ///
  /// dt.endOf(DateTimeUnit.day);   // 2025-06-15 23:59:59.999999
  /// dt.endOf(DateTimeUnit.month); // 2025-06-30 23:59:59.999999
  /// dt.endOf(DateTimeUnit.year);  // 2025-12-31 23:59:59.999999
  /// ```
  EasyDateTime endOf(DateTimeUnit unit) {
    return switch (unit) {
      DateTimeUnit.year =>
        EasyDateTime(year, 12, 31, 23, 59, 59, 999, 999, location),
      DateTimeUnit.month =>
        EasyDateTime(year, month + 1, 0, 23, 59, 59, 999, 999, location),
      DateTimeUnit.week => _endOfWeek(),
      DateTimeUnit.day =>
        EasyDateTime(year, month, day, 23, 59, 59, 999, 999, location),
      DateTimeUnit.hour =>
        EasyDateTime(year, month, day, hour, 59, 59, 999, 999, location),
      DateTimeUnit.minute =>
        EasyDateTime(year, month, day, hour, minute, 59, 999, 999, location),
      DateTimeUnit.second => EasyDateTime(
          year, month, day, hour, minute, second, 999, 999, location),
    };
  }

  /// Returns the Monday of the current week at 00:00:00.000000.
  EasyDateTime _startOfWeek() {
    final daysToSubtract = weekday - DateTime.monday;

    return EasyDateTime(
      year,
      month,
      day - daysToSubtract,
      0,
      0,
      0,
      0,
      0,
      location,
    );
  }

  /// Returns the Sunday of the current week at 23:59:59.999999.
  EasyDateTime _endOfWeek() {
    final daysToAdd = DateTime.sunday - weekday;

    return EasyDateTime(
      year,
      month,
      day + daysToAdd,
      23,
      59,
      59,
      999,
      999,
      location,
    );
  }

  // ============================================================
  // DateTime Compatibility Constants
  // ============================================================

  /// Weekday constants for 'drop in' compatibility with [DateTime].
  ///
  /// These values follow ISO 8601 standard:
  /// - [monday] = 1
  /// - [sunday] = 7
  static const int monday = DateTime.monday;

  /// See [monday] for weekday constant documentation.
  static const int tuesday = DateTime.tuesday;

  /// See [monday] for weekday constant documentation.
  static const int wednesday = DateTime.wednesday;

  /// See [monday] for weekday constant documentation.
  static const int thursday = DateTime.thursday;

  /// See [monday] for weekday constant documentation.
  static const int friday = DateTime.friday;

  /// See [monday] for weekday constant documentation.
  static const int saturday = DateTime.saturday;

  /// See [monday] for weekday constant documentation.
  static const int sunday = DateTime.sunday;

  /// Number of days per week.
  static const int daysPerWeek = DateTime.daysPerWeek;

  /// Month constants for 'drop in' compatibility with [DateTime].
  ///
  /// Values range from 1 ([january]) to 12 ([december]).
  static const int january = DateTime.january;

  /// See [january] for month constant documentation.
  static const int february = DateTime.february;

  /// See [january] for month constant documentation.
  static const int march = DateTime.march;

  /// See [january] for month constant documentation.
  static const int april = DateTime.april;

  /// See [january] for month constant documentation.
  static const int may = DateTime.may;

  /// See [january] for month constant documentation.
  static const int june = DateTime.june;

  /// See [january] for month constant documentation.
  static const int july = DateTime.july;

  /// See [january] for month constant documentation.
  static const int august = DateTime.august;

  /// See [january] for month constant documentation.
  static const int september = DateTime.september;

  /// See [january] for month constant documentation.
  static const int october = DateTime.october;

  /// See [january] for month constant documentation.
  static const int november = DateTime.november;

  /// See [january] for month constant documentation.
  static const int december = DateTime.december;

  /// Number of months per year.
  static const int monthsPerYear = DateTime.monthsPerYear;

  // These static methods provide convenient class-level access to the global timezone
  // configuration functions. Using `EasyDateTime.setDefaultLocation()` instead of the
  // global `setDefaultLocation()` makes it clearer which package the functionality
  // belongs to, improving code readability and maintainability.

  /// Sets the global default timezone for all [EasyDateTime] operations.
  ///
  /// This is **optional**. If not set, [EasyDateTime] uses the system's
  /// local timezone.
  ///
  /// ```dart
  /// EasyDateTime.setDefaultLocation(TimeZones.shanghai);
  /// final now = EasyDateTime.now(); // Shanghai time
  /// ```
  static void setDefaultLocation(Location? location) =>
      config.internalSetDefaultLocation(location);

  /// Gets the current global default timezone.
  ///
  /// Returns `null` if no default has been set.
  static Location? getDefaultLocation() => config.internalGetDefaultLocation();

  /// Clears the global default timezone.
  ///
  /// After calling this, [EasyDateTime] will use the system's local timezone.
  static void clearDefaultLocation() => config.internalClearDefaultLocation();

  /// Gets the effective default location for EasyDateTime operations.
  ///
  /// Priority:
  /// 1. User-set global default (via [setDefaultLocation])
  /// 2. System local timezone
  ///
  /// **Throws [TimeZoneNotInitializedException]** if [initializeTimeZone]
  /// has not been called.
  static Location get effectiveDefaultLocation =>
      config.effectiveDefaultLocation;

  /// Initializes the IANA timezone database.
  ///
  /// **Must be called before using [EasyDateTime].**
  ///
  /// Call once at app startup:
  /// ```dart
  /// void main() {
  ///   EasyDateTime.initializeTimeZone();
  ///   runApp(MyApp());
  /// }
  /// ```
  static void initializeTimeZone() => init.internalInitializeTimeZone();

  /// Checks if the IANA timezone database has been initialized.
  ///
  /// Returns `true` if [EasyDateTime.initializeTimeZone] has been called successfully.
  ///
  ///
  static bool get isTimeZoneInitialized => init.internalIsTimeZoneInitialized;
}
