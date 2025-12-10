import 'package:timezone/timezone.dart';

import 'easy_date_time_config.dart';
import 'easy_date_time_init.dart';
import 'exceptions/exceptions.dart';

part 'easy_date_time_parsing.dart';
part 'easy_date_time_utilities.dart';
part 'easy_date_time_formatting.dart';

/// A timezone-aware DateTime implementation.
///
/// [EasyDateTime] wraps Dart's [DateTime] to provide timezone-aware operations.
/// Unlike [DateTime] which only supports UTC and local time, [EasyDateTime]
/// can represent any IANA timezone.
///
/// **This class is immutable and thread-safe.**
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
/// setDefaultLocation(TimeZones.shanghai);
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
class EasyDateTime implements Comparable<EasyDateTime> {
  /// The underlying TZDateTime from the timezone package.
  final TZDateTime _tzDateTime;

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
          location ?? effectiveDefaultLocation,
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
  /// ```dart
  /// // Uses global default or local timezone
  /// final now = EasyDateTime.now();
  ///
  /// // Explicitly specify timezone
  /// final nowInTokyo = EasyDateTime.now(location: getLocation('Asia/Tokyo'));
  /// ```
  factory EasyDateTime.now({Location? location}) {
    return EasyDateTime._(TZDateTime.now(location ?? effectiveDefaultLocation));
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
      TZDateTime.from(dateTime, location ?? effectiveDefaultLocation),
    );
  }

  /// Creates an [EasyDateTime] from milliseconds since Unix epoch.
  ///
  /// If [location] is not provided, uses the global default or local timezone.
  factory EasyDateTime.fromMillisecondsSinceEpoch(
    int milliseconds, {
    Location? location,
  }) {
    return EasyDateTime._(
      TZDateTime.fromMillisecondsSinceEpoch(
        location ?? effectiveDefaultLocation,
        milliseconds,
      ),
    );
  }

  /// Creates an [EasyDateTime] from seconds since Unix epoch.
  ///
  /// This is useful for parsing Unix timestamps from backend APIs that return
  /// seconds (common in Python, Go, Rust, and Unix-based systems).
  ///
  /// If [location] is not provided, uses the global default or local timezone.
  ///
  /// ```dart
  /// // Backend returns: {"created_at": 1733644200}
  /// final dt = EasyDateTime.fromSecondsSinceEpoch(1733644200);
  /// ```
  factory EasyDateTime.fromSecondsSinceEpoch(
    int seconds, {
    Location? location,
  }) {
    return EasyDateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      location: location,
    );
  }

  /// Creates an [EasyDateTime] from microseconds since Unix epoch.
  ///
  /// If [location] is not provided, uses the global default or local timezone.
  factory EasyDateTime.fromMicrosecondsSinceEpoch(
    int microseconds, {
    Location? location,
  }) {
    return EasyDateTime._(
      TZDateTime.fromMicrosecondsSinceEpoch(
        location ?? effectiveDefaultLocation,
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
  /// // Explicit location converts to that timezone
  /// final inNY = EasyDateTime.parse(
  ///   '2025-12-01T10:30:00Z',
  ///   location: getLocation('America/New_York'),
  /// );
  /// print(inNY.hour); // 5 (10:00 UTC → 05:00 NY)
  /// ```
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
        effectiveDefaultLocation,
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
  int get year => _tzDateTime.year;

  /// The month component (1-12).
  int get month => _tzDateTime.month;

  /// The day of the month component (1-31).
  int get day => _tzDateTime.day;

  /// The hour component (0-23).
  int get hour => _tzDateTime.hour;

  /// The minute component (0-59).
  int get minute => _tzDateTime.minute;

  /// The second component (0-59).
  int get second => _tzDateTime.second;

  /// The millisecond component (0-999).
  int get millisecond => _tzDateTime.millisecond;

  /// The microsecond component (0-999).
  int get microsecond => _tzDateTime.microsecond;

  /// The day of the week (1 = Monday, 7 = Sunday).
  int get weekday => _tzDateTime.weekday;

  /// The timezone [Location] of this datetime.
  Location get location => _tzDateTime.location;

  /// The name of the timezone (e.g., 'Asia/Tokyo').
  String get locationName => _tzDateTime.location.name;

  /// Whether this datetime is in UTC.
  bool get isUtc => _tzDateTime.isUtc;

  /// The timezone offset from UTC.
  Duration get timeZoneOffset => _tzDateTime.timeZoneOffset;

  /// The timezone name abbreviation (e.g., 'JST', 'EST').
  String get timeZoneName => _tzDateTime.timeZoneName;

  /// Milliseconds since Unix epoch (January 1, 1970 UTC).
  int get millisecondsSinceEpoch => _tzDateTime.millisecondsSinceEpoch;

  /// Microseconds since Unix epoch (January 1, 1970 UTC).
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
  EasyDateTime toUtc() {
    return EasyDateTime._(
      TZDateTime.from(_tzDateTime.toUtc(), getLocation('UTC')),
    );
  }

  /// Returns this datetime converted to the system's local timezone.
  ///
  /// This is consistent with [DateTime.toLocal].
  EasyDateTime toLocal() {
    return EasyDateTime._(TZDateTime.from(_tzDateTime.toLocal(), local));
  }

  /// Converts to a standard [DateTime].
  DateTime toDateTime() => _tzDateTime;

  // ============================================================
  // Arithmetic Operations
  // ============================================================

  /// Returns a new [EasyDateTime] with the [duration] added.
  EasyDateTime add(Duration duration) {
    return EasyDateTime._(_tzDateTime.add(duration));
  }

  /// Returns a new [EasyDateTime] with the [duration] subtracted.
  EasyDateTime subtract(Duration duration) {
    return EasyDateTime._(_tzDateTime.subtract(duration));
  }

  /// Returns the [Duration] between this and [other].
  Duration difference(EasyDateTime other) {
    return _tzDateTime.difference(other._tzDateTime);
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
  bool operator <(EasyDateTime other) =>
      microsecondsSinceEpoch < other.microsecondsSinceEpoch;

  /// Returns `true` if this is after [other].
  bool operator >(EasyDateTime other) =>
      microsecondsSinceEpoch > other.microsecondsSinceEpoch;

  /// Returns `true` if this is before or at the same moment as [other].
  bool operator <=(EasyDateTime other) =>
      microsecondsSinceEpoch <= other.microsecondsSinceEpoch;

  /// Returns `true` if this is after or at the same moment as [other].
  bool operator >=(EasyDateTime other) =>
      microsecondsSinceEpoch >= other.microsecondsSinceEpoch;

  // ============================================================
  // Comparison
  // ============================================================

  /// Returns `true` if this is before [other].
  bool isBefore(EasyDateTime other) =>
      microsecondsSinceEpoch < other.microsecondsSinceEpoch;

  /// Returns `true` if this is after [other].
  bool isAfter(EasyDateTime other) =>
      microsecondsSinceEpoch > other.microsecondsSinceEpoch;

  /// Returns `true` if this and [other] represent the same moment in time.
  ///
  /// Two [EasyDateTime]s can be at the same moment even if they are in
  /// different timezones.
  ///
  /// This is consistent with [DateTime.isAtSameMomentAs].
  bool isAtSameMomentAs(EasyDateTime other) =>
      microsecondsSinceEpoch == other.microsecondsSinceEpoch;

  @override
  int compareTo(EasyDateTime other) {
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EasyDateTime &&
        microsecondsSinceEpoch == other.microsecondsSinceEpoch;
  }

  @override
  int get hashCode => microsecondsSinceEpoch.hashCode;

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
}
