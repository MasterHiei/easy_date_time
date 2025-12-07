import 'package:timezone/timezone.dart';

import 'easy_date_time_config.dart';
import 'easy_date_time_init.dart';
import 'exceptions/exceptions.dart';

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
/// final utc = shanghai.inUtc();
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

  /// Extracts timezone offset from an ISO 8601 string.
  /// Returns the offset as Duration, or null if no offset found.
  static Duration? _extractTimezoneOffset(String input) {
    // Pattern: +HH:MM, -HH:MM, +HHMM, -HHMM at end of string
    final match = RegExp(r'([+-])(\d{2}):?(\d{2})$').firstMatch(input);
    if (match == null) return null;

    final sign = match.group(1) == '+' ? 1 : -1;
    final hours = int.parse(match.group(2)!);
    final minutes = int.parse(match.group(3)!);

    return Duration(hours: sign * hours, minutes: sign * minutes);
  }

  /// Formats a Duration offset as a timezone offset string (e.g., +05:17).
  static String _formatOffset(Duration offset) {
    final totalMinutes = offset.inMinutes;
    final sign = totalMinutes >= 0 ? '+' : '-';
    final absMinutes = totalMinutes.abs();
    final hours = absMinutes ~/ 60;
    final minutes = absMinutes % 60;

    return '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// Extracts original time components from an ISO 8601 string,
  /// before any timezone conversion.
  static ({
    int year,
    int month,
    int day,
    int hour,
    int minute,
    int second,
    int millisecond,
    int microsecond
  })? _extractOriginalTimeComponents(String input) {
    // Remove timezone suffix for parsing
    final withoutTz = input.replaceAll(RegExp(r'[+-]\d{2}:?\d{2}$'), '');

    // Pattern: YYYY-MM-DDTHH:MM:SS.sss or YYYY-MM-DD HH:MM:SS.sss
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2}):(\d{2})(?:\.(\d+))?',
    ).firstMatch(withoutTz);

    if (match == null) {
      // Try date-only pattern
      final dateMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(
        withoutTz,
      );
      if (dateMatch != null) {
        return (
          year: int.parse(dateMatch.group(1)!),
          month: int.parse(dateMatch.group(2)!),
          day: int.parse(dateMatch.group(3)!),
          hour: 0,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
      }

      return null;
    }

    // Parse fractional seconds
    final fractionStr = match.group(7) ?? '0';
    final fraction = fractionStr.padRight(6, '0');
    final millisecond = int.parse(fraction.substring(0, 3));
    final microsecond = int.parse(fraction.substring(3, 6));

    return (
      year: int.parse(match.group(1)!),
      month: int.parse(match.group(2)!),
      day: int.parse(match.group(3)!),
      hour: int.parse(match.group(4)!),
      minute: int.parse(match.group(5)!),
      second: int.parse(match.group(6)!),
      millisecond: millisecond,
      microsecond: microsecond,
    );
  }

  /// Finds an IANA timezone that matches the given UTC offset.
  ///
  /// Returns null if no matching timezone is found or if timezone
  /// database is not initialized.
  static Location? _findLocationForOffset(Duration offset) {
    if (!isTimeZoneInitialized) {
      return null;
    }

    // Common timezone mappings for efficiency (most used offsets)
    // When multiple regions share an offset, we pick a representative one.
    // The fallback search will find others if this one doesn't match.
    final offsetMinutes = offset.inMinutes;
    final commonMappings = <int, String>{
      // UTC
      0: 'UTC',
      // Europe (Standard + DST)
      60: 'Europe/Paris', // CET (Central European winter)
      120: 'Europe/Paris', // CEST (Central European summer)
      180: 'Europe/Moscow', // MSK
      // Middle East / South Asia
      240: 'Asia/Dubai', // GST (+4)
      270: 'Asia/Kabul', // +4:30
      300: 'Asia/Karachi', // PKT (+5)
      330: 'Asia/Kolkata', // IST (+5:30)
      345: 'Asia/Kathmandu', // +5:45
      360: 'Asia/Dhaka', // BST (+6)
      390: 'Asia/Yangon', // +6:30
      420: 'Asia/Bangkok', // ICT (+7)
      // East Asia
      480: 'Asia/Shanghai', // CST (+8)
      540: 'Asia/Tokyo', // JST (+9)
      570: 'Australia/Adelaide', // ACST (+9:30)
      // Oceania (Standard + DST)
      600: 'Australia/Sydney', // AEST (+10)
      630: 'Australia/Lord_Howe', // +10:30
      660: 'Pacific/Noumea', // +11
      720: 'Pacific/Auckland', // NZST (+12)
      780: 'Pacific/Apia', // +13
      // Americas (Standard + DST)
      -180: 'America/Sao_Paulo', // BRT (-3)
      -240: 'America/New_York', // EDT (summer, -4)
      -300: 'America/New_York', // EST (winter, -5)
      -360: 'America/Chicago', // CST (winter, -6)
      -420: 'America/Denver', // MST (winter, -7)
      -480: 'America/Los_Angeles', // PST (winter, -8)
      -540: 'America/Anchorage', // AKST (-9)
      -600: 'Pacific/Honolulu', // HST (-10)
    };

    final mappedName = commonMappings[offsetMinutes];
    if (mappedName != null) {
      try {
        return getLocation(mappedName);
      } catch (_) {
        // Continue to fallback
      }
    }

    // Fallback: search all locations (more expensive)
    try {
      for (final name in timeZoneDatabase.locations.keys) {
        final loc = getLocation(name);
        if (loc.currentTimeZone.offset == offset.inMilliseconds) {
          return loc;
        }
      }
    } catch (_) {
      // Database not available
    }

    return null;
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
  /// - `12/01/2025` (US format: MM/DD/YYYY)
  /// - `01/12/2025` (European format: DD/MM/YYYY) - ambiguous, not recommended
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

  /// Regex pattern for YYYY/MM/DD format.
  /// Allows loose matching for separator options but enforces strict year/month/day structure.
  static final _slashYMDPattern =
      RegExp(r'^(\d{4})[./-](\d{1,2})[./-](\d{1,2})(.*)$');

  /// Attempts to normalize common date formats to ISO 8601.
  ///
  /// Returns null if normalization is not possible or input is too complex.
  static String? _tryNormalizeFormat(String input) {
    // Limit input length to prevent ReDoS attacks and processing of unreasonably large strings
    if (input.length > 50) {
      return null;
    }

    // Pattern: YYYY/MM/DD or YYYY/MM/DD HH:MM:SS
    // Adjusts to allow dot and dash separators in this fallback logic too for consistency
    final slashMatch = _slashYMDPattern.firstMatch(input);
    if (slashMatch != null) {
      final year = slashMatch.group(1)!;
      final month = slashMatch.group(2)!.padLeft(2, '0');
      final day = slashMatch.group(3)!.padLeft(2, '0');
      final time = slashMatch.group(4)?.trim() ?? '';

      // Validate logical ranges to fail early on obvious nonsense
      if (int.parse(month) > 12 || int.parse(day) > 31) {
        return null;
      }

      if (time.isEmpty) {
        return '$year-$month-$day';
      }

      // Handle time part: " 10:30:00" -> "T10:30:00"
      // If it already has T, leave it. If it has space, replace with T.
      final timeNormalized = time.startsWith('T') ? time : 'T${time.trim()}';

      return '$year-$month-$day$timeNormalized';
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
  EasyDateTime inUtc() {
    return EasyDateTime._(
      TZDateTime.from(_tzDateTime.toUtc(), getLocation('UTC')),
    );
  }

  /// Returns this datetime converted to the system's local timezone.
  EasyDateTime inLocalTime() {
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
  bool isAtSameMoment(EasyDateTime other) =>
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
  // JSON Serialization
  // ============================================================

  /// Creates an [EasyDateTime] from a JSON value (ISO 8601 string).
  ///
  /// Compatible with standard serialization - uses ISO 8601 format just
  /// like [DateTime]. Works seamlessly with json_serializable, freezed, etc.
  ///
  /// ```dart
  /// final dt = EasyDateTime.fromJson('2025-12-01T10:30:00+0900');
  /// ```
  factory EasyDateTime.fromJson(String json) {
    return EasyDateTime.parse(json);
  }

  /// Converts this [EasyDateTime] to a JSON value (ISO 8601 string).
  ///
  /// Compatible with standard serialization - produces ISO 8601 format
  /// just like [DateTime]. Works seamlessly with json_serializable, freezed, etc.
  ///
  /// ```dart
  /// final json = dt.toJson();
  /// // '2025-12-01T10:30:00.000+0900'
  /// ```
  String toJson() => toIso8601String();

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

  // ============================================================
  // Date Utilities
  // ============================================================

  /// Returns a new [EasyDateTime] with time set to 00:00:00.000.
  ///
  /// Useful for date-only comparisons or getting the start of a day.
  ///
  /// ```dart
  /// final now = EasyDateTime.now();  // 2025-12-01 14:30:00
  /// final date = now.dateOnly;       // 2025-12-01 00:00:00
  /// ```
  EasyDateTime get dateOnly => copyWith(
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );

  /// Alias for [dateOnly]. Returns start of the day (00:00:00.000).
  ///
  /// ```dart
  /// final dayStart = EasyDateTime.now().startOfDay;
  /// ```
  EasyDateTime get startOfDay => dateOnly;

  /// Returns end of the day (23:59:59.999999).
  ///
  /// ```dart
  /// final dayEnd = EasyDateTime.now().endOfDay;
  /// ```
  EasyDateTime get endOfDay => copyWith(
        hour: 23,
        minute: 59,
        second: 59,
        millisecond: 999,
        microsecond: 999,
      );

  /// Returns the first day of the current month at 00:00:00.
  ///
  /// ```dart
  /// final dt = EasyDateTime(2025, 12, 15);
  /// final monthStart = dt.startOfMonth;  // 2025-12-01 00:00:00
  /// ```
  EasyDateTime get startOfMonth => copyWith(
        day: 1,
        hour: 0,
        minute: 0,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );

  /// Returns the last day of the current month at 23:59:59.999999.
  ///
  /// Correctly handles months with different lengths and leap years.
  ///
  /// ```dart
  /// final dt = EasyDateTime(2025, 2, 15);
  /// final monthEnd = dt.endOfMonth;  // 2025-02-28 23:59:59.999999
  /// ```
  EasyDateTime get endOfMonth {
    // Get the first day of next month, then subtract 1 day
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final firstOfNextMonth =
        EasyDateTime(nextYear, nextMonth, 1, 0, 0, 0, 0, 0, location);

    return firstOfNextMonth.subtract(const Duration(microseconds: 1));
  }

  /// Returns the next day at the same time.
  ///
  /// ```dart
  /// final tomorrow = EasyDateTime.now().tomorrow;
  /// ```
  EasyDateTime get tomorrow => add(const Duration(days: 1));

  /// Returns the previous day at the same time.
  ///
  /// ```dart
  /// final yesterday = EasyDateTime.now().yesterday;
  /// ```
  EasyDateTime get yesterday => subtract(const Duration(days: 1));

  /// Returns `true` if this date is today (ignoring time).
  ///
  /// ```dart
  /// if (appointment.isToday) {
  ///   print('You have an appointment today!');
  /// }
  /// ```
  bool get isToday => _isSameDay(EasyDateTime.now(location: location));

  /// Returns `true` if this date is tomorrow (ignoring time).
  bool get isTomorrow =>
      _isSameDay(EasyDateTime.now(location: location).tomorrow);

  /// Returns `true` if this date is yesterday (ignoring time).
  bool get isYesterday =>
      _isSameDay(EasyDateTime.now(location: location).yesterday);

  /// Checks if this date has the same year, month, and day as [other].
  bool _isSameDay(EasyDateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Returns a date-only string in YYYY-MM-DD format.
  ///
  /// ```dart
  /// final dateStr = EasyDateTime.now().toDateString();  // '2025-12-01'
  /// ```
  String toDateString() {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');

    return '$y-$m-$d';
  }

  /// Returns a time-only string in HH:MM:SS format.
  ///
  /// ```dart
  /// final timeStr = EasyDateTime.now().toTimeString();  // '14:30:00'
  /// ```
  String toTimeString() {
    final h = hour.toString().padLeft(2, '0');
    final min = minute.toString().padLeft(2, '0');
    final s = second.toString().padLeft(2, '0');

    return '$h:$min:$s';
  }
}
